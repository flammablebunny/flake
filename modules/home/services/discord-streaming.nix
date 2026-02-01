{ pkgs, config, ... }:

let
  twitchUsername = "flammable_bunny";
  settingsPaths = [
    "/home/bunny/.config/Equicord/settings/settings.json"
    "/home/bunny/.config/discord/settings.json"
    "/home/bunny/.config/Discord/settings.json"
  ];
  settingsPathsJson = builtins.toJSON settingsPaths;

  python = pkgs.python3.withPackages (ps: [ ps.requests ]);

  discordStreamingScript = pkgs.writeScript "discord-streaming-rpc.py" ''
    #!${python}/bin/python3
    import json
    import os
    import sys
    import subprocess
    import time
    import requests
    from pathlib import Path

    TWITCH_USER = "${twitchUsername}"
    SETTINGS_PATHS = ${settingsPathsJson}
    TWITCH_GQL_CLIENT_ID = "kimne78kx3ncx6brgo4mv6wki5h1ko"
    DISCORD_BINARY = "/etc/profiles/per-user/bunny/bin/discord"
    DISCORD_PROCESS_PATTERNS = [
        "Discord-wrapped",
        "/bin/discord",
        "/bin/Discord",
    ]

    def choose_settings_path():
        for path in SETTINGS_PATHS:
            if os.path.exists(path) or os.path.islink(path):
                return path
        # Fall back to the first known location so we log a useful error.
        return SETTINGS_PATHS[0]

    SETTINGS_PATH = choose_settings_path()

    def guess_wayland_display(uid: int):
        runtime_dir = Path(f"/run/user/{uid}")
        if not runtime_dir.exists():
            return None
        candidates = sorted(runtime_dir.glob("wayland-*"))
        if not candidates:
            return None
        return candidates[0].name

    def discord_is_running():
        uid = str(os.getuid())
        for pattern in DISCORD_PROCESS_PATTERNS:
            result = subprocess.run(
                ["pgrep", "-u", uid, "-f", pattern],
                capture_output=True,
            )
            if result.returncode == 0:
                return True
        return False

    def stop_discord():
        uid = str(os.getuid())
        for pattern in DISCORD_PROCESS_PATTERNS:
            subprocess.run(
                ["pkill", "-u", uid, "-f", pattern],
                capture_output=True,
            )

    def fetch_stream_info_gql():
        try:
            payload = {
                "query": "query($login:String!){user(login:$login){stream{title viewersCount game{displayName}}}}",
                "variables": {"login": TWITCH_USER},
            }
            headers = {"Client-ID": TWITCH_GQL_CLIENT_ID}
            response = requests.post(
                "https://gql.twitch.tv/gql",
                json=payload,
                headers=headers,
                timeout=5,
            )
            data = response.json()
            stream = (
                data.get("data", {})
                .get("user", {})
                .get("stream")
            )
            if not stream:
                return None
            game = stream.get("game") or {}
            return {
                "title": stream.get("title") or "Live on Twitch",
                "game": game.get("displayName"),
            }
        except Exception:
            return None

    def is_live():
        stream_info = fetch_stream_info_gql()
        if stream_info is not None:
            return True, stream_info
        try:
            # Check uptime endpoint
            r = requests.get(f"https://decapi.me/twitch/uptime/{TWITCH_USER}", timeout=5)
            text = r.text.strip().lower()
            if "offline" not in text and text != "":
                return True, None
            # Fallback: check if viewers endpoint returns a number (means live)
            r2 = requests.get(f"https://decapi.me/twitch/viewercount/{TWITCH_USER}", timeout=5)
            text2 = r2.text.strip()
            if text2.isdigit():
                return True, None
            return False, None
        except Exception:
            return False, None

    def get_stream_title():
        try:
            r = requests.get(f"https://decapi.me/twitch/title/{TWITCH_USER}", timeout=5)
            title = r.text.strip()
            if title and "offline" not in title.lower():
                return title
        except:
            pass
        return f"Live on Twitch"

    def get_stream_game():
        try:
            r = requests.get(f"https://decapi.me/twitch/game/{TWITCH_USER}", timeout=5)
            game = r.text.strip()
            if game and "offline" not in game.lower():
                return game
        except:
            pass
        return None

    def update_settings(streaming: bool, title: str = None, game: str = None):
        # If settings.json is a symlink, replace it with a real file
        if os.path.islink(SETTINGS_PATH):
            real_target = os.path.realpath(SETTINGS_PATH)
            if os.path.exists(real_target):
                with open(real_target, 'r') as f:
                    content = f.read()
                os.unlink(SETTINGS_PATH)
                with open(SETTINGS_PATH, 'w') as f:
                    f.write(content)
                print(f"Converted symlink to real file")

        if not os.path.exists(SETTINGS_PATH):
            print(f"Settings file not found: {SETTINGS_PATH}")
            return False

        try:
            with open(SETTINGS_PATH, 'r') as f:
                settings = json.load(f)
        except json.JSONDecodeError as e:
            print(f"Failed to parse settings: {e}")
            return False

        # Check current state BEFORE modifying
        existing_rpc = settings.get('plugins', {}).get('CustomRPC', {})
        old_enabled = existing_rpc.get('enabled', False)
        expected_details = title or 'Live on Twitch'
        expected_link = f'https://www.twitch.tv/{TWITCH_USER}'
        details_changed = streaming and (
            existing_rpc.get('details') != expected_details or
            existing_rpc.get('streamLink') != expected_link
        )

        # Update both plugins and filteredPlugins sections
        for section in ['plugins', 'filteredPlugins']:
            if section in settings and 'CustomRPC' in settings[section]:
                if streaming:
                    settings[section]['CustomRPC'] = {
                        'enabled': True,
                        'type': 1,
                        'timestampMode': 1,
                        'streamLink': expected_link,
                        'buttonOneURL': expected_link,
                        'appName': 'Stream',
                        'details': expected_details,
                        'imageBig': "",
                        'imageSmall': "",
                        'appID': '1202775579141607435',
                        'buttonOneText': 'Watch',
                    }
                else:
                    settings[section]['CustomRPC'] = {'enabled': False}

        # Check if state actually changed
        state_changed = (streaming and not old_enabled) or (not streaming and old_enabled) or details_changed

        if not state_changed:
            print("No state change, skipping")
            return True

        if streaming:
            print(f"Set streaming RPC: {title}")
        else:
            print("Cleared streaming RPC")

        # Check if Discord is running
        discord_was_running = discord_is_running()

        # Kill Discord if running so we can write settings
        if discord_was_running:
            stop_discord()
            time.sleep(2)

        try:
            with open(SETTINGS_PATH, 'w') as f:
                json.dump(settings, f, indent=2)
        except Exception as e:
            print(f"Failed to write settings: {e}")
            return False

        # Restart Discord if it was running
        if discord_was_running:
            env = os.environ.copy()
            uid = os.getuid()
            # Ensure display variables are set for GUI
            env.setdefault('XDG_RUNTIME_DIR', f'/run/user/{uid}')
            if 'WAYLAND_DISPLAY' not in env:
                guessed_display = guess_wayland_display(uid)
                if guessed_display is not None:
                    env['WAYLAND_DISPLAY'] = guessed_display
            subprocess.Popen(
                [DISCORD_BINARY, '--start-minimized'],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
                stdin=subprocess.DEVNULL,
                start_new_session=True,
                env=env
            )
            print("Restarted Discord")

        return True

    def main():
        live, stream_info = is_live()

        if live:
            if stream_info is None:
                title = get_stream_title()
                game = get_stream_game()
            else:
                title = stream_info.get('title')
                game = stream_info.get('game')
            update_settings(True, title, game)
        else:
            update_settings(False)

    if __name__ == "__main__":
        main()
  '';
in {
  # Streaming status checker timer - runs every 30 seconds for faster detection
  systemd.user.timers.discord-streaming-check = {
    Unit.Description = "Check Twitch streaming status for Discord CustomRPC";
    Timer = {
      OnBootSec = "30s";
      OnUnitActiveSec = "30s";
    };
    Install.WantedBy = [ "timers.target" ];
  };

  systemd.user.services.discord-streaming-check = {
    Unit.Description = "Update Equicord CustomRPC from Twitch streaming status";
    Service = {
      Type = "oneshot";
      ExecStart = "${python}/bin/python3 ${discordStreamingScript}";
    };
  };
}
