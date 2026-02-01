{ pkgs, config, ... }:

let
  # Font path needs to be dynamic based on the nix store
  jetbrainsMono = pkgs.nerd-fonts.jetbrains-mono;
  fontPath = "${jetbrainsMono}/share/fonts/truetype/NerdFonts/JetBrainsMono/JetBrainsMonoNerdFontMono-Medium.ttf";
  javaX11LibPath = pkgs.lib.makeLibraryPath [
    pkgs.libxkbcommon
    pkgs.xorg.libX11
    pkgs.xorg.libxcb
    pkgs.xorg.libXt
    pkgs.xorg.libXtst
    pkgs.xorg.libXi
    pkgs.xorg.libXext
    pkgs.xorg.libXinerama
    pkgs.xorg.libXrender
    pkgs.xorg.libXfixes
    pkgs.xorg.libXrandr
    pkgs.xorg.libXcursor
  ];
in
{
  # The priv.lua file will be created by agenix activation
  # See secrets.nix for the secret definition

  xdg.configFile = {
    "waywall/init.lua".text = ''
      local toggles = require("toggles")
      local bg_col = "#000000"
      local toggle_bg_picture = toggles.toggle_bg_picture

      local primary_col = "#26bb98"
      local secondary_col = "#ff00ff"

      local ninbot_anchor = "topright" -- topleft, top, topright, left, right, bottomleft, bottomright
      local ninbot_opacity = 1 -- 0 to 1

      local emote_downloader = require("fetch_emotes")
      local chat = require("chat")
      local chat1 = chat("Flammable_Bunny", 15, 700, 16)

      local e_count = 		{ enabled = true, x = 1500, y = 400, size = 7}
      local thin_pie = 		{ enabled = true, x = 1490, y = 645, size = 1}
      local thin_percent =	{ enabled = true, x = 1568, y = 1050, size = 8}
      local tall_pie = 		{ enabled = true, x = 1490, y = 645, size = 1}
      local tall_percent =	{ enabled = true, x = 1568, y = 1050, size = 8}

      local keybinds = require("keybinds")
      local paths = require("paths")

      local res_1440 = toggles.res_1440
      local toggle_paceman = toggles.toggle_paceman
      local toggle_lingle = toggles.toggle_lingle

      local thin_key = keybinds.thin_key
      local wide_key = keybinds.wide_key
      local tall_key = keybinds.tall_key
      local show_ninbot_key = keybinds.show_ninbot_key
      local toggle_fullscreen_key = keybinds.toggle_fullscreen_key
      local open_ninbot_key = keybinds.open_ninbot_key
      local toggle_remaps_key = keybinds.toggle_remaps_key
      local open_chat_key = keybinds.open_chat_key
      local emote_key = keybinds.emote_key

      local remaps_text_config = { text = "REBINDS OFF", x = 100, y = 100, size = 2 }

      -- DON'T CHANGE ANYTHING AFTER THIS UNLESS YOU KNOW WHAT YOU"RE DOING


      local bg_path      = paths.bg_path
      local pacem_path   = paths.pacem_path
      local nb_path      = paths.nb_path
      local overlay_path = paths.overlay_path
      local lingle_path  = paths.lingle_path

      local keyboard_remaps = require("remaps").remapped_kb
      local other_remaps = require("remaps").normal_kb
      local remaps_active = toggles.remaps_active

      local function build_remaps(active_normal)
          local m = {}
          for k,v in pairs(keyboard_remaps) do m[k] = v end
          if active_normal then
              for k,v in pairs(other_remaps) do m[k] = v end
          end
          return m
      end

      local waywall = require("waywall")
      local helpers = require("waywall.helpers")

      local config = {
          input = {
              layout = "us",
              repeat_rate = 40,
              repeat_delay = 300,
      		remaps = build_remaps(true),
              sensitivity = 0.3077,
              confine_pointer = false,
          },
          theme = {
              background = bg_col,
      		background_png = toggle_bg_picture and bg_path or nil,
              ninb_anchor = ninbot_anchor,
              ninb_opacity = ninbot_opacity,
      		font_path = "${fontPath}",
              font_size = 25,
          },
          experimental = {
              debug = false,
              jit = false,
              tearing = true,
              force_composition = true,
              subprocess_dri_prime = "1",
      		  scene_add_text = true,

          },
      }


      --*********************************************************************************************** PACEMAN
      local is_pacem_running = function()
      	local handle = io.popen("pgrep -f 'paceman..*'")
      	local result = handle:read("*l")
      	handle:close()
      	return result ~= nil
      end

      local exec_pacem = function()
      	if not is_pacem_running() then
      		waywall.exec("java -jar " .. pacem_path .. " --nogui")
      	end
      end

      --*********************************************************************************************** LINGLE
      local is_lingle_running = function()
      	local handle = io.popen("pgrep -f 'lingle..*'")
      	local result = handle:read("*l")
      	handle:close()
      	return result ~= nil
      end

      local exec_lingle = function()
      	if not is_lingle_running() then
      		waywall.exec("java -jar " .. lingle_path .. " --nogui")
      	end
      end

      --*********************************************************************************************** NINJABRAIN
      local is_ninb_running = function()
      	local handle = io.popen("pgrep -f 'Ninjabrain.*jar'")
      	local result = handle:read("*l")
      	handle:close()
      	return result ~= nil
      end

      local exec_ninb = function()
      	if not is_ninb_running() then
      		-- Force X11 so the window is managed by Waywall's nested Xwayland (and doesn't pop out
      		-- as a Wayland client on the host compositor).
      		waywall.exec("env -u WAYLAND_DISPLAY -u WAYLAND_SOCKET _JAVA_AWT_WM_NONREPARENTING=1 LD_LIBRARY_PATH=${javaX11LibPath} java -Dswing.defaultlaf=javax.swing.plaf.metal.MetalLookAndFeel -Dawt.useSystemAAFontSettings=on -jar " .. nb_path)
      	end
      end

      --*********************************************************************************************** MIRRORS
      local make_mirror = function(options)
      	local this = nil

      	return function(enable)
      		if enable and not this then
      			this = waywall.mirror(options)
      		elseif this and not enable then
      			this:close()
      			this = nil
      		end
      	end
      end

      local mirrors = {
          e_counter = make_mirror({
      		src = { x = 13, y = 37, w = 37, h = 9 },
      		dst = { x = e_count.x, y = e_count.y, w = 37*e_count.size, h = 9*e_count.size },
      		color_key = {
      			input = "#dddddd",
      			output = primary_col,
      		},
      	}),


          thin_pie_all = make_mirror({
      		src = { x = 10, y = 694, w = 340, h = 178 },
      		dst = { x = thin_pie.x, y = thin_pie.y, w = 420*thin_pie.size, h = 423*thin_pie.size },
          }),
          thin_pie_entities = make_mirror({
      		src = { x = 10, y = 694, w = 340, h = 178 },
      		dst = { x = thin_pie.x, y = thin_pie.y, w = 420*thin_pie.size, h = 423*thin_pie.size },
      		color_key = {
      			input = "#E446C4",
      			output = secondary_col,
      		},
      	}),
          thin_pie_unspecified = make_mirror({
      		src = { x = 10, y = 694, w = 340, h = 178 },
      		dst = { x = thin_pie.x, y = thin_pie.y, w = 420*thin_pie.size, h = 423*thin_pie.size },
      		color_key = {
      			input = "#46CE66",
      			output = secondary_col,
      		},
      	}),
          thin_pie_blockentities = make_mirror({
      		src = { x = 10, y = 694, w = 340, h = 178 },
      		dst = { x = thin_pie.x, y = thin_pie.y, w = 420*thin_pie.size, h = 423*thin_pie.size },
      		color_key = {
      			input = "#ec6e4e",
      			output = primary_col,
      		},
      	}),
      	thin_pie_destroyProgress = make_mirror({
      		src = { x = 10, y = 694, w = 340, h = 178 },
      		dst = { x = thin_pie.x, y = thin_pie.y, w = 420*thin_pie.size, h = 423*thin_pie.size },
      		color_key = {
      			input = "#CC6C46",
      			output = secondary_col,
      		},
      	}),
      	thin_pie_prepare = make_mirror({
      		src = { x = 10, y = 694, w = 340, h = 178 },
      		dst = { x = thin_pie.x, y = thin_pie.y, w = 420*thin_pie.size, h = 423*thin_pie.size },
      		color_key = {
      			input = "#464C46",
      			output = secondary_col,
      		},
      	}),


      	thin_percent_all = make_mirror({
      		src = { x = 257, y = 879, w = 33, h = 25 },
      		dst = { x = thin_percent.x, y = thin_percent.y, w = 33*thin_percent.size, h = 25*thin_percent.size },
          }),
      	thin_percent_blockentities = make_mirror({
      		src = { x = 257, y = 879, w = 33, h = 25 },
      		dst = { x = thin_percent.x, y = thin_percent.y, w = 33*thin_percent.size, h = 25*thin_percent.size },
      		color_key = {
      			input = "#e96d4d",
      			output = secondary_col,
      		},
          }),
      	thin_percent_unspecified = make_mirror({
      		src = { x = 257, y = 879, w = 33, h = 25 },
      		dst = { x = thin_percent.x, y = thin_percent.y, w = 33*thin_percent.size, h = 25*thin_percent.size },
      		color_key = {
      			input = "#45cb65",
      			output = secondary_col,
      		},
          }),


      	tall_pie_all = make_mirror({
      		src = { x = 44, y = 15978, w = 340, h = 178 },
      		dst = { x = tall_pie.x, y = tall_pie.y, w = 420*tall_pie.size, h = 423*tall_pie.size },
      	}),
      	tall_pie_entities = make_mirror({
      		src = { x = 44, y = 15978, w = 340, h = 178 },
      		dst = { x = tall_pie.x, y = tall_pie.y, w = 420*tall_pie.size, h = 423*tall_pie.size },
      		color_key = {
      			input = "#E446C4",
      			output = secondary_col,
      		},
      	}),
          tall_pie_unspecified = make_mirror({
      		src = { x = 44, y = 15978, w = 340, h = 178 },
      		dst = { x = tall_pie.x, y = tall_pie.y, w = 420*tall_pie.size, h = 423*tall_pie.size },
      		color_key = {
      			input = "#46CE66",
      			output = secondary_col,
      		},
      	}),
          tall_pie_blockentities = make_mirror({
      		src = { x = 44, y = 15978, w = 340, h = 178 },
      		dst = { x = tall_pie.x, y = tall_pie.y, w = 420*tall_pie.size, h = 423*tall_pie.size },
      		color_key = {
      			input = "#ec6e4e",
      			output = primary_col,
      		},
      	}),
      	tall_pie_destroyProgress = make_mirror({
      		src = { x = 44, y = 15978, w = 340, h = 178 },
      		dst = { x = tall_pie.x, y = tall_pie.y, w = 420*tall_pie.size, h = 423*tall_pie.size },
      		color_key = {
      			input = "#CC6C46",
      			output = secondary_col,
      		},
      	}),
      	tall_pie_prepare = make_mirror({
      		src = { x = 44, y = 15978, w = 340, h = 178 },
      		dst = { x = tall_pie.x, y = tall_pie.y, w = 420*tall_pie.size, h = 423*tall_pie.size },
      		color_key = {
      			input = "#464C46",
      			output = secondary_col,
      		},
      	}),


      	tall_percent_all = make_mirror({
      		src = { x = 291, y = 16163, w = 33, h = 25 },
      		dst = { x = tall_percent.x, y = tall_percent.y, w = 33*tall_percent.size, h = 25*tall_percent.size },
          }),
      	tall_percent_blockentities = make_mirror({
      		src = { x = 291, y = 16163, w = 33, h = 25 },
      		dst = { x = tall_percent.x, y = tall_percent.y, w = 33*tall_percent.size, h = 25*tall_percent.size },
      		color_key = {
      			input = "#e96d4d",
      			output = secondary_col,
      		},
          }),
      	tall_percent_unspecified = make_mirror({
      		src = { x = 291, y = 16163, w = 33, h = 25 },
      		dst = { x = tall_percent.x, y = tall_percent.y, w = 33*tall_percent.size, h = 25*tall_percent.size },
      		color_key = {
      			input = "#45cb65",
      			output = secondary_col,
      		},
          }),


      	eye_measure = make_mirror({
      		src = { x = 162, y = 7902, w = 60, h = 580 },
      		dst = { x = 94, y = 470, w = 900, h = 500 },
      	}),
      }


      --*********************************************************************************************** BOATEYE
      local make_image = function(path, dst)
      	local this = nil

      	return function(enable)
      		if enable and not this then
      			this = waywall.image(path, dst)
      		elseif this and not enable then
      			this:close()
      			this = nil
      		end
      	end
      end

      local images = {
      	measuring_overlay = make_image(overlay_path, {
      		dst = res_1440
      			and { x = 94, y = 470, w = 900, h = 500 }
      			or  { x = 30, y = 340, w = 700, h = 400 },
      		}),
      }


      --*********************************************************************************************** MANAGING MIRRORS
      local show_mirrors = function(eye, f3, tall, thin)

      	images.measuring_overlay(eye)
      	mirrors.eye_measure(eye)

      	if e_count.enabled then
          	mirrors.e_counter(f3)
      	end

      	if thin_pie.enabled then
      		-- mirrors.thin_pie_all(thin)
      		mirrors.thin_pie_entities(thin)
      		mirrors.thin_pie_unspecified(thin)
      		mirrors.thin_pie_blockentities(thin)
      		mirrors.thin_pie_destroyProgress(thin)
      		mirrors.thin_pie_prepare(thin)
      	end

      	if thin_percent.enabled then
      		-- mirrors.thin_percent_all(thin)
      		mirrors.thin_percent_blockentities(thin)
      		mirrors.thin_percent_unspecified(thin)
      	end

      	if tall_pie.enabled then
      		-- mirrors.tall_pie_all(tall)
      		mirrors.tall_pie_entities(tall)
      		mirrors.tall_pie_unspecified(tall)
      		mirrors.tall_pie_blockentities(tall)
      		mirrors.tall_pie_destroyProgress(tall)
      		mirrors.tall_pie_prepare(tall)
      	end

      	if tall_percent.enabled then
      		-- mirrors.tall_percent_all(tall)
      		mirrors.tall_percent_blockentities(tall)
      		mirrors.tall_percent_unspecified(tall)
      	end


      end


      --*********************************************************************************************** STATES
      local thin_enable = function()
          show_mirrors(false, true, false, true)
      end

      local tall_enable = function()
      	show_mirrors(true, true, true, false)
      end
      local wide_enable = function()
      	show_mirrors(false, false, false, false)
      end

      local res_disable = function()
          show_mirrors(false, false, false, false)
      end


      --*********************************************************************************************** RESOLUTIONS
      local make_res = function(width, height, enable, disable)
      	return function()
      		local active_width, active_height = waywall.active_res()

      		if active_width == width and active_height == height then
      			waywall.set_resolution(0, 0)
      			disable()
      		else
      			waywall.set_resolution(width, height)
      			enable()
      		end
      	end
      end


      local resolutions = {
      	thin = make_res(350, 1100, thin_enable, res_disable),
      	tall = make_res(384, 16384, tall_enable, res_disable),
      	wide = make_res(2560, 400, wide_enable, res_disable),
      }

      local rebind_text = nil

      local function ensure_rebind_text()
          if not rebind_text then
              rebind_text = waywall.text({
                  text = " ",
                  x = remaps_text_config.x,
                  y = remaps_text_config.y,
                  color = "#FFFFFFFF",
                  size = remaps_text_config.size,
                  layer = "overlay",
              })
          end
      end


      --*********************************************************************************************** KEYBINDS
      config.actions = {
      	[thin_key] = function()
      		resolutions.thin()
      	end,

      	[wide_key] = function()
      		resolutions.wide()
      	end,

      	[tall_key] = function()
      		resolutions.tall()
      	end,

      	[show_ninbot_key] = function()
      		helpers.toggle_floating()
      	end,

      	[toggle_fullscreen_key] = waywall.toggle_fullscreen,

      	[open_ninbot_key] = function()
      		exec_ninb()
      		if toggle_lingle then exec_lingle() end
      		if toggle_paceman then exec_pacem() end
      	end,

      [toggle_remaps_key] = function()
          remaps_active = not remaps_active
          waywall.set_remaps(remaps_active and keyboard_remaps or other_remaps)

          ensure_rebind_text()

          if remaps_active then
              rebind_text:set_text(" ")
              rebind_text:set_color("#FFFFFF00")
          else
              rebind_text:set_text(remaps_text_config.text)
              rebind_text:set_color("#FFFFFFFF")
          end
      end,


      	[emote_key] = function()
              emote_downloader.Fetch("01K5Z5EVFM8Q8015A4HA8R334S")
          end,

      	[open_chat_key] = function()
      	    chat1:open()
      	end,
      }


      return config
    '';

    "waywall/keybinds.lua".text = ''
      local keybinds = {
          thin_key = "*-APOSTROPHE",
          wide_key = "*-6",
          tall_key = "*-TAB",
          show_ninbot_key = "*-GRAVE",
          toggle_fullscreen_key = "Shift-O",
          open_ninbot_key = "Shift-P",
          toggle_remaps_key = "SEMICOLON",
          open_chat_key = "Shift-U",
          emote_key = "Shift-Y",
      }

      return keybinds
    '';

    "waywall/paths.lua".text = ''
      local toggles = require("toggles")

      local home = os.getenv("HOME")
      local waywall_config = home .. "/.config/waywall/"

      local paths = {
          bg_path = toggles.toggle_bg_picture and (home .. "/Pictures/Wallpapers/rabbit forest.png") or nil,
          pacem_path   = home .. "/mcsr/paceman-tracker-0.7.1.jar",
          nb_path      = home .. "/mcsr/Ninjabrain-Bot-1.5.1.jar",
          overlay_path = home .. "/.config/waywall/images/measuring_overlay.png",
          lingle_path  = home .. "/IdeaProjects/Lingle/build/libs/Lingle-v1.0.0.jar",
      }

      return paths
    '';

    "waywall/toggles.lua".text = ''
      local toggles = {
      	toggle_bg_picture = true,
          toggle_paceman = true,
          toggle_lingle = false,
          res_1440 = true,
          remaps_active = true,
      }

      return toggles
    '';

    "waywall/remaps.lua".text = ''
      return {
      remapped_kb = {

      },

      normal_kb = {
      	["R"] = "F3",

      },

      }
    '';

    # chat.lua - Twitch chat overlay
    "waywall/chat.lua".source = ./waywall/chat.lua;

    # fetch_emotes.lua - 7TV emote fetcher
    "waywall/fetch_emotes.lua".source = ./waywall/fetch_emotes.lua;

    # Third-party Lua libraries
    "waywall/dkjson.lua".source = ./waywall/dkjson.lua;
    "waywall/utf8.lua".source = ./waywall/utf8.lua;

    # Static images directory
    "waywall/images/measuring_overlay.png".source = ./waywall/images/measuring_overlay.png;
  };

  # Ensure mutable directories exist and generate priv.lua from secret
  home.activation.waywallSetup = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p $HOME/.config/waywall/emotes

    # Generate priv.lua from agenix secret if it exists
    if [ -f /run/agenix/waywall-oauth ]; then
      OAUTH_TOKEN=$(cat /run/agenix/waywall-oauth)
      cat > $HOME/.config/waywall/priv.lua << 'PRIV_EOF'
local PRIV = {}

PRIV.IRC_IP = "irc.chat.twitch.tv"
PRIV.IRC_PORT = 6667
PRIV.IRC_USERNAME = "Flammable_Bunny"
PRIV_EOF
      echo "PRIV.IRC_TOKEN = \"$OAUTH_TOKEN\"" >> $HOME/.config/waywall/priv.lua
      echo "" >> $HOME/.config/waywall/priv.lua
      echo "return PRIV" >> $HOME/.config/waywall/priv.lua
      chmod 600 $HOME/.config/waywall/priv.lua
    fi
  '';
}
