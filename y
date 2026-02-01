[33m29b7cd7[m[33m ([m[1;36mHEAD[m[33m -> [m[1;32mmain[m[33m, [m[1;31morigin/main[m[33m, [m[1;31morigin/HEAD[m[33m)[m feat: massively debloat quickshell by removing unused toggles, variables, settings, sidebars, and more. also flake.lock bump and updated default nixos apps.
[33mb767cec[m feat: nest modules files more for orginization consistentcy and update flake.lock
[33m80d0a59[m fix/feat: update oauth key, fix streaming rich service, update waywall
[33mb6460d1[m fix: remove equibop for native discord because it works again
[33m082760d[m fix: added deps to quickshell launch command so that it actually starts with exec
[33m91fbe54[m fix: added deps to quickshell launch command so that it actually starts with exec
[33m2e2c4cc[m feat: added new nvim plugins, fixed nixcord not building
[33m41cc9c9[m fix: i forgot lowk
[33m352b18d[m fix: i forgot lowk
[33m18cc0eb[m fix: add bindl = [ to laptop keybinds to fix syntax error
[33mf987769[m add and remove: removed caelestia comletely, using a customized version of end4's quickshell config.
[33mde2f76d[m add: split up a few more hyprland config files to make slack a special workspace only on laptop
[33m948944f[m restructred hyprland conf files
[33m2938d44[m updated cord.nvim hash
[33m89d3d22[m made two different env hyprland files so that my laptop aspect ratio doesnt suck. also added slack to laptop apps.
[33me99b709[m add: swapped out stale error prone lazy nvim config for nvf config.
[33ma9a8088[m fix: different shell.json files for each system
[33m5408583[m added starship.nix and removed all but the wallpaper i acually use
[33m3af780a[m fix: installer script looking for age key wrong
[33m8932c42[m fix: installer script not working when root
[33m0c70dce[m fix: install script with new username.txt function for laptop
[33m0845a3a[m fix: make laptop username work properly
[33m3f05ab4[m fix: laptop username now pulls from /etc/nixos/username.txt for privacy.
[33m2e02cfa[m added loglevel=3 to boot perams
[33m28367ff[m added laptop hardware configuration
[33m9bf2d6f[m Delete .claude directory
[33ma98f479[m Restructred All Config Files
[33m54f3f35[m didnt really change anything notable just pushing to fix a rebuild error
[33m1913f74[m added tmpfs.nix to add tmpfs for minecraft
[33m6da5d29[m updated and improved install script
[33mdeb78f8[m i lowk forgot what i updated since last commit...
[33m8779bad[m updated intel-arc-b580.nix to dualgpu.nix
[33m715312f[m install scripts, encrtypted stuff, added los of .config files.
[33mf4bbbd0[m updated nixcord.nix with all plugins i want and their settings.
[33m001657e[m moved nvim config to home manager file
[33m6f50770[m fix: use custom caelestia.lua theme instead of external plugin
[33m232242a[m feat: add caelestia theme, visual plugins, fix doc/tags issue
[33m0d0dc13[m fix: correct plugin GitHub paths for telescope, nvim-cmp, LuaSnip, and nvim-lspconfig
[33m1e693ad[m test: manual LazyVim without auto-imports, add cord and noice
[33m7752d94[m fix: add back missing plugins (plenary, catppuccin, claude-code)
[33m35e10a7[m fix: keep only LazyVim, remove cord and noice
[33m389462a[m fix: keep LazyVim with cord, drop noice due to conflicts
[33m72da4c5[m test: LazyVim + noice only (no cord)
[33m832bd5b[m test: LazyVim + cord only (no noice)
[33md0b6588[m test: add LazyVim back with cord and noice
[33m72d85b1[m test: minimal config with just cord and noice, no LazyVim
[33mf68ab95[m test: disable LazyVim imports to isolate segfault
[33m01f202d[m fix: remove noice-nvim and nui-nvim from plugins list
[33m109bce3[m fix: disable presence.nvim - also causes segfault on load
[33m428cd48[m feat: replace cord.nvim with presence.nvim for Discord RPC
[33m4f831b5[m fix: disable noice.nvim and cord.nvim - both cause segfaults on load
[33m54449c1[m test: disable config/setup calls for noice and cord
[33m54b2003[m test: disable noice.nvim, enable cord.nvim to isolate segfault
[33meb05c89[m test: disable cord.nvim to isolate segfault cause
[33m91f54bc[m feat: re-enable noice.nvim and cord.nvim with proper configuration
[33m4535db0[m fix: add tree-sitter to extraPackages for treesitter parser compilation
[33mcc6e54c[m fix: keep lazyvim deps, only disable cord.nvim and noice.nvim
[33m2a676b1[m fix: eliminate segfaults by disabling problematic plugins with native builds
[33medda6ff[m fix: enable lazy auto-install to fix nvim initialization segfault
[33mbca7687[m feat: add nixcord with openasar and equicord
[33mfb66909[m Inital Commit 2
[33m1273fad[m Initial commit
