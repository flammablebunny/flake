{ config, lib, pkgs, ... }:

let
  cfg = config.services.persist-backup;

  backupScript = pkgs.writeShellScript "persist-backup-watch" ''
    set -euo pipefail

    BACKUP_REPO="${cfg.backupRepo}"
    AGE_KEY="${cfg.ageKeyPath}"
    AGE_RECIPIENT="${cfg.ageRecipient}"
    WATCH_DIRS="${lib.concatStringsSep " " cfg.watchDirs}"

    # Ensure backup repo exists
    if [ ! -d "$BACKUP_REPO/.git" ]; then
      echo "Initializing backup repo at $BACKUP_REPO"
      mkdir -p "$BACKUP_REPO"
      cd "$BACKUP_REPO"
      ${pkgs.git}/bin/git init -b main
      ${pkgs.git}/bin/git remote add origin "${cfg.remoteUrl}" || true
    fi

    echo "Watching directories: $WATCH_DIRS"

    # Watch for changes and encrypt
    ${pkgs.inotify-tools}/bin/inotifywait -m -r \
      --format '%w%f %e' \
      -e modify,create,delete,moved_to,moved_from \
      $WATCH_DIRS 2>/dev/null | while read -r LINE; do

      FILE=$(echo "$LINE" | cut -d' ' -f1)
      EVENT=$(echo "$LINE" | cut -d' ' -f2-)

      # Skip temporary/cache files and large binary assets
      case "$FILE" in
        # Temp files
        *.swp|*.tmp|*~|*.log|*.cache)
          continue
          ;;
        # Version control
        */.git/*)
          continue
          ;;
        # Build artifacts
        */node_modules/*|*/target/*|*/__pycache__/*|*/.direnv/*|*/build/*|*/dist/*|*/.gradle/*|*/.idea/*)
          continue
          ;;
        # Large game/media assets
        *.jar|*.zip|*.tar|*.tar.gz|*.tar.xz|*.7z|*.rar)
          continue
          ;;
        *.mp4|*.mkv|*.avi|*.mov|*.webm)
          continue
          ;;
        *.iso|*.img|*.bin|*.exe|*.dll|*.so|*.so.*|*.run|*.AppImage)
          continue
          ;;
        # Minecraft-specific large files
        */libraries/*|*/versions/*|*/assets/indexes/*|*/assets/objects/*)
          continue
          ;;
        # Steam game files (too large)
        */.local/share/Steam/steamapps/common/*|*/.local/share/Steam/steamapps/downloading/*)
          continue
          ;;
        # JetBrains caches and system
        */caches/*|*/index/*|*/.cache/*|*/.local/share/JetBrains/*)
          continue
          ;;
        # Browser caches and large data
        */Cache/*|*/CachedData/*|*/GPUCache/*|*/ShaderCache/*|*/storage/default/*)
          continue
          ;;
        # DaVinci Resolve cache
        */.local/share/DaVinciResolve/*/CacheClip/*|*/Resolve*/CacheClip/*)
          continue
          ;;
        # OBS recording outputs (if stored in config)
        *.flv|*.ts)
          continue
          ;;
        # Spotify cache
        */.config/spotify/Users/*/cache/*)
          continue
          ;;
        # Python virtual environments
        */.venv/*|*/venv/*|*/.virtualenvs/*)
          continue
          ;;
        # Extracted installers
        */squashfs-root/*)
          continue
          ;;
        # NVIDIA/CUDA libraries
        */nvidia/*|*/cuda/*|*cublas*|*cudnn*|*cufft*|*cusparse*|*nccl*)
          continue
          ;;
        # AI session logs (can be huge)
        */.codex/sessions/*|*/.claude/projects/*/transcripts/*)
          continue
          ;;
      esac

      echo "[$EVENT] $FILE"

      # Get path relative to home
      REL_PATH="''${FILE#$HOME/}"
      DEST="$BACKUP_REPO/$REL_PATH.age"

      case "$EVENT" in
        *DELETE*|*MOVED_FROM*)
          # Remove encrypted file if source was deleted
          if [ -f "$DEST" ]; then
            rm -f "$DEST"
            echo "Removed: $REL_PATH.age"
          fi
          ;;
        *)
          # Compress and encrypt
          if [ -f "$FILE" ]; then
            mkdir -p "$(dirname "$DEST")"
            ${pkgs.zstd}/bin/zstd -c -q "$FILE" | ${pkgs.age}/bin/age -r "$AGE_RECIPIENT" -o "$DEST" -
            echo "Compressed+Encrypted: $REL_PATH -> $REL_PATH.age"
          fi
          ;;
      esac
    done
  '';

  pushScript = pkgs.writeShellScript "persist-backup-push" ''
    set -euo pipefail

    BACKUP_REPO="${cfg.backupRepo}"

    if [ ! -d "$BACKUP_REPO/.git" ]; then
      echo "Backup repo not initialized yet"
      exit 0
    fi

    cd "$BACKUP_REPO"

    # Check if there are changes
    ${pkgs.git}/bin/git add -A

    if ! ${pkgs.git}/bin/git diff --cached --quiet; then
      ${pkgs.git}/bin/git commit -m "auto: $(date -Iseconds)"
      echo "Committed changes"

      if [ -n "$(${pkgs.git}/bin/git remote)" ]; then
        ${pkgs.git}/bin/git push -u origin HEAD || echo "Push failed (remote may not be configured)"
      fi
    else
      echo "No changes to commit"
    fi
  '';

  restoreScript = pkgs.writeShellScript "persist-backup-restore" ''
    set -euo pipefail

    BACKUP_REPO="${cfg.backupRepo}"
    AGE_KEY="${cfg.ageKeyPath}"

    if [ ! -d "$BACKUP_REPO" ]; then
      echo "Backup repo not found at $BACKUP_REPO"
      echo "Clone it first: git clone <your-repo-url> $BACKUP_REPO"
      exit 1
    fi

    echo "Restoring from $BACKUP_REPO..."

    find "$BACKUP_REPO" -name "*.age" -type f | while read -r ENCRYPTED; do
      REL_PATH="''${ENCRYPTED#$BACKUP_REPO/}"
      DEST="$HOME/''${REL_PATH%.age}"

      echo "Decrypting: $REL_PATH -> ''${REL_PATH%.age}"
      mkdir -p "$(dirname "$DEST")"
      ${pkgs.age}/bin/age -d -i "$AGE_KEY" "$ENCRYPTED" | ${pkgs.zstd}/bin/zstd -d -c > "$DEST"
    done

    echo "Restore complete!"
  '';

  backupNowScript = pkgs.writeShellScript "persist-backup-now" ''
    set -euo pipefail

    BACKUP_REPO="${cfg.backupRepo}"
    AGE_KEY="${cfg.ageKeyPath}"
    AGE_RECIPIENT="${cfg.ageRecipient}"
    WATCH_DIRS="${lib.concatStringsSep " " cfg.watchDirs}"

    echo "Running manual backup..."

    # Initialize repo if needed
    if [ ! -d "$BACKUP_REPO/.git" ]; then
      echo "Initializing backup repo at $BACKUP_REPO"
      mkdir -p "$BACKUP_REPO"
      cd "$BACKUP_REPO"
      ${pkgs.git}/bin/git init -b main
      ${pkgs.git}/bin/git remote add origin "${cfg.remoteUrl}" || true
    fi

    # Check for age key
    if [ ! -f "$AGE_KEY" ]; then
      echo "No age key found at $AGE_KEY"
      exit 1
    fi

    echo "Compressing and encrypting files from: $WATCH_DIRS"
    file_count=0

    for dir in $WATCH_DIRS; do
      [ -d "$dir" ] || continue

      while IFS= read -r -d "" file; do
        # Skip unwanted files
        case "$file" in
          *.swp|*.tmp|*~|*.log|*.cache) continue ;;
          */.git/*|*/node_modules/*|*/target/*|*/__pycache__/*|*/.direnv/*|*/build/*|*/dist/*|*/.gradle/*|*/.idea/*) continue ;;
          *.jar|*.zip|*.tar|*.tar.gz|*.tar.xz|*.7z|*.rar) continue ;;
          *.mp4|*.mkv|*.avi|*.mov|*.webm|*.flv|*.ts) continue ;;
          *.iso|*.img|*.bin|*.exe|*.dll|*.so|*.so.*|*.run|*.AppImage) continue ;;
          */libraries/*|*/versions/*|*/assets/indexes/*|*/assets/objects/*) continue ;;
          */.local/share/Steam/steamapps/common/*|*/.local/share/Steam/steamapps/downloading/*) continue ;;
          */caches/*|*/index/*|*/.cache/*|*/.local/share/JetBrains/*) continue ;;
          */Cache/*|*/CachedData/*|*/GPUCache/*|*/ShaderCache/*|*/storage/default/*) continue ;;
          */.local/share/DaVinciResolve/*/CacheClip/*|*/Resolve*/CacheClip/*) continue ;;
          */.config/spotify/Users/*/cache/*) continue ;;
          */.venv/*|*/venv/*|*/.virtualenvs/*) continue ;;
          */squashfs-root/*) continue ;;
          */nvidia/*|*/cuda/*|*cublas*|*cudnn*|*cufft*|*cusparse*|*nccl*) continue ;;
          */.codex/sessions/*|*/.claude/projects/*/transcripts/*) continue ;;
        esac

        REL_PATH="''${file#$HOME/}"
        DEST="$BACKUP_REPO/$REL_PATH.age"

        # Only encrypt if source is newer or dest doesn't exist
        if [ ! -f "$DEST" ] || [ "$file" -nt "$DEST" ]; then
          mkdir -p "$(dirname "$DEST")"
          if ${pkgs.zstd}/bin/zstd -c -q "$file" | ${pkgs.age}/bin/age -r "$AGE_RECIPIENT" -o "$DEST" - 2>/dev/null; then
            file_count=$((file_count + 1))
            echo "[$file_count] $REL_PATH"
          fi
        fi
      done < <(find "$dir" -type f -print0 2>/dev/null)
    done

    echo "Encrypted $file_count files"

    # Commit and push
    cd "$BACKUP_REPO"
    ${pkgs.git}/bin/git add -A

    if ! ${pkgs.git}/bin/git diff --cached --quiet; then
      ${pkgs.git}/bin/git commit -m "backup: $(date -Iseconds)"
      echo "Committed changes"

      if [ -n "$(${pkgs.git}/bin/git remote)" ]; then
        ${pkgs.git}/bin/git push -u origin HEAD || echo "Push failed"
      fi
      echo "Backup complete!"
    else
      echo "No changes to backup"
    fi
  '';

in
{
  options.services.persist-backup = {
    enable = lib.mkEnableOption "Auto-encrypted git backup for user files";

    watchDirs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "$HOME/Documents"
        "$HOME/Downloads"
        "$HOME/Pictures"
        "$HOME/pro"
        "$HOME/Projects"
      ];
      description = "Directories to watch for changes";
    };

    backupRepo = lib.mkOption {
      type = lib.types.str;
      default = "$HOME/.local/share/flake-persistent";
      description = "Local path for the backup git repository";
    };

    remoteUrl = lib.mkOption {
      type = lib.types.str;
      default = "";
      example = "git@gitlab.com:username/flake-persistent.git";
      description = "Git remote URL for pushing backups";
    };

    ageKeyPath = lib.mkOption {
      type = lib.types.str;
      default = "$HOME/.config/agenix/key.txt";
      description = "Path to age private key for decryption";
    };

    ageRecipient = lib.mkOption {
      type = lib.types.str;
      description = "Age public key for encryption";
    };

    pushInterval = lib.mkOption {
      type = lib.types.str;
      default = "5min";
      description = "How often to push to remote (systemd timer format)";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.age
      pkgs.zstd
      pkgs.inotify-tools
      (pkgs.writeShellScriptBin "flake-restore" "${restoreScript}")
      (pkgs.writeShellScriptBin "flake-backup-now" "${backupNowScript}")
    ];

    # Watcher service
    systemd.user.services.persist-backup = {
      Unit = {
        Description = "Watch and encrypt user files for backup";
        After = [ "default.target" ];
      };

      Service = {
        Type = "simple";
        ExecStart = "${backupScript}";
        Restart = "always";
        RestartSec = "10";
      };

      Install.WantedBy = [ "default.target" ];
    };

    # Push timer
    systemd.user.timers.persist-backup-push = {
      Unit.Description = "Push encrypted backups to git";

      Timer = {
        OnUnitActiveSec = cfg.pushInterval;
        OnBootSec = "2min";
      };

      Install.WantedBy = [ "timers.target" ];
    };

    # Push service
    systemd.user.services.persist-backup-push = {
      Unit = {
        Description = "Push encrypted backups to git";
        After = [ "network-online.target" ];
        Wants = [ "network-online.target" ];
      };

      Service = {
        Type = "oneshot";
        ExecStart = "${pushScript}";
      };
    };

    # Backup on shutdown/logout
    systemd.user.services.persist-backup-shutdown = {
      Unit = {
        Description = "Backup files before shutdown";
        DefaultDependencies = false;
        Before = [ "shutdown.target" "reboot.target" "halt.target" ];
      };

      Service = {
        Type = "oneshot";
        ExecStart = "${backupNowScript}";
        TimeoutStartSec = "120";
      };

      Install.WantedBy = [ "shutdown.target" "reboot.target" "halt.target" ];
    };

  };
}
