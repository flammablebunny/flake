{ pkgs, config, ... }:

let
  twitchUsername = "flammable_bunny";
  settingsPath = "/home/bunny/.config/Equicord/settings/settings.json";

  python = pkgs.python3.withPackages (ps: [ ps.requests ]);

  discordStreamingScript = pkgs.writeScript "discord-streaming-rpc.py" ''
    #!${python}/bin/python3
    import json
    import os
    import sys
    import subprocess
    import time
    import requests

    TWITCH_USER = "${twitchUsername}"
    SETTINGS_PATH = "${settingsPath}"

    def is_live():
        try:
            # Check uptime endpoint
            r = requests.get(f"https://decapi.me/twitch/uptime/{TWITCH_USER}", timeout=5)
            text = r.text.strip().lower()
            if "offline" not in text and text != "":
                return True
            # Fallback: check if viewers endpoint returns a number (means live)
            r2 = requests.get(f"https://decapi.me/twitch/viewercount/{TWITCH_USER}", timeout=5)
            text2 = r2.text.strip()
            if text2.isdigit():
                return True
            return False
        except:
            return False

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
        old_enabled = settings.get('plugins', {}).get('CustomRPC', {}).get('enabled', False)

        # Update both plugins and filteredPlugins sections
        for section in ['plugins', 'filteredPlugins']:
            if section in settings and 'CustomRPC' in settings[section]:
                if streaming:
                    settings[section]['CustomRPC'] = {
                        'enabled': True,
                        'type': 1,
                        'timestampMode': 1,
                        'streamLink': f'https://www.twitch.tv/{TWITCH_USER}',
                        'buttonOneURL': f'https://www.twitch.tv/{TWITCH_USER}',
                        'appName': 'Stream',
                        'details': title or 'Live on Twitch',
                        'imageBig': "",
                        'imageSmall': "",
                        'appID': '1202775579141607435',
                        'buttonOneText': 'Watch',
                    }
                else:
                    settings[section]['CustomRPC'] = {'enabled': False}

        # Check if state actually changed
        state_changed = (streaming and not old_enabled) or (not streaming and old_enabled)

        if not state_changed:
            print("No state change, skipping")
            return True

        if streaming:
            print(f"Set streaming RPC: {title}")
        else:
            print("Cleared streaming RPC")

        # Check if Discord is running
        discord_was_running = subprocess.run(['pgrep', '-f', 'Discord'], capture_output=True).returncode == 0

        # Kill Discord if running so we can write settings
        if discord_was_running:
            subprocess.run(['killall', 'Discord', 'discord', '.Discord-wrapped'], capture_output=True)
            time.sleep(1)

        try:
            with open(SETTINGS_PATH, 'w') as f:
                json.dump(settings, f, indent=2)
        except Exception as e:
            print(f"Failed to write settings: {e}")
            return False

        # Restart Discord if it was running
        if discord_was_running:
            env = os.environ.copy()
            # Ensure display variables are set for GUI
            if 'WAYLAND_DISPLAY' not in env:
                env['WAYLAND_DISPLAY'] = 'wayland-1'
            if 'XDG_RUNTIME_DIR' not in env:
                env['XDG_RUNTIME_DIR'] = f'/run/user/{os.getuid()}'
            subprocess.Popen(
                ['/etc/profiles/per-user/bunny/bin/discord'],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
                stdin=subprocess.DEVNULL,
                start_new_session=True,
                env=env
            )
            print("Restarted Discord")

        return True

    def main():
        live = is_live()

        if live:
            title = get_stream_title()
            game = get_stream_game()
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
