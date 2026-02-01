INSTALL INSTRUCTIONS FOR ME 

sudo mount /dev/sXX1 /mnt/usb

nix-shell -p git --run "git clone https://github.com/Flammable-Bunny/nix.git /tmp/nix && /tmp/nix/scripts/install.sh --auto"
