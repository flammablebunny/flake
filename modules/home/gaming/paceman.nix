{ config, ... }:

{
  # PaceMan config is generated from agenix secret on activation
  home.activation.pacemanSetup = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p $HOME/.config/PaceMan

    # Generate options.json from agenix secret if it exists
    if [ -f /run/agenix/paceman-key ]; then
      ACCESS_KEY=$(cat /run/agenix/paceman-key)
      cat > $HOME/.config/PaceMan/options.json << EOF
{
  "accessKey": "$ACCESS_KEY",
  "enabledForPlugin": false,
  "allowAnyWorldName": false,
  "resetStatsEnabled": true
}
EOF
      chmod 600 $HOME/.config/PaceMan/options.json
    fi
  '';
}
