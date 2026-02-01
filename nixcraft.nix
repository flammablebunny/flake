{ inputs, pkgs, ... }:
let
  ranked-mrpack = pkgs.fetchurl {
    url = "https://redlime.github.io/MCSRMods/modpacks/v4/MCSRRanked-Linux-1.16.1-All.mrpack";
    hash = "sha256-mPerodqNklfLpeNzcJqe5g/wf9mGFwPNl7vApl/RggI=";
  };

  rsg-mrpack = pkgs.fetchurl {
    url = "https://cdn.modrinth.com/data/1uJaMUOm/versions/5icZYG8d/SpeedrunPack-mc1.16.1-v6.0.0.mrpack";
    hash = "sha256:1v0n7s5gzak5p9sqnbijzaxni503sjdarb9wnnxjcsjkqaww3hp5";
  };
in
{
  imports = [ inputs.nixcraft.homeModules.default ];

  nixcraft = {
    enable = true;

    server.instances = {};

    client.instances = {
      Ranked = {
        enable = true;

        mrpack = {
          enable = true;
          file = ranked-mrpack;
        };

        lwjglVersion = "3.3.3";
        mangohud.enable = true;

        java = {
          package = pkgs.jdk17;
          maxMemory = 4096;
          minMemory = 512;
        };

        waywall = {
          enable = true;
          binaryPath = "/home/bunny/IdeaProjects/waywall/builddir/waywall/waywall";
          glfwPath = "/home/bunny/mcsr/glfw/libglfw.so";
          rawCommand = "env WAYWALL_VK_PROXY_GAME=1 WAYWALL_VK_VENDOR=amd WAYWALL_DMABUF_ALLOW_MODIFIERS=1 WAYWALL_SUBPROC_DRI_PRIME=0 __GLX_VENDOR_LIBRARY_NAME=amd GBM_DEVICE=/dev/dri/renderD128 AMD_DEBUG=forcegtt,nodcc,nohyperz,nowc /home/bunny/IdeaProjects/waywall/builddir/waywall/waywall wrap -- env __GLX_VENDOR_LIBRARY_NAME=intel GBM_DEVICE=/dev/dri/renderD129 DRI_PRIME=1 $GAME_SCRIPT";
         # ZINK | rawCommand = "env __GLX_VENDOR_LIBRARY_NAME=amd GBM_DEVICE=/dev/dri/renderD128 /home/bunny/IdeaProjects/waywall/waywall-zink/builddir/waywall/waywall wrap -- env __GLX_VENDOR_LIBRARY_NAME=mesa WAYWALL_ZINK_FORCE_CPU_COPY=1 MESA_LOADER_DRIVER_OVERRIDE=zink GBM_DEVICE=/dev/dri/renderD129 DRI_PRIME=1 $GAME_SCRIPT"; 
         #  rawCommand = "env WAYWALL_VK_PROXY_GAME=1 WAYWALL_VK_VENDOR=amd __GLX_VENDOR_LIBRARY_NAME=amd GBM_DEVICE=/dev/dri/renderD128 /home/bunny/IdeaProjects/waywall/builddir/waywall/waywall wrap -- env __GLX_VENDOR_LIBRARY_NAME=intel GBM_DEVICE=/dev/dri/renderD129 DRI_PRIME=1 $GAME_SCRIPT";
        };

        binEntry = {
          enable = true;
          name = "ranked";
        };

        desktopEntry = {
          enable = true;
          name = "MCSR Ranked";
          icon = /home/bunny/.local/share/nixcraft/client/instances/Ranked/ranked.png;
        };

        account = {
          username = "Flammable_Bunny";
          accessTokenPath = "/home/bunny/.local/share/nixcraft/auth/access_token";
          skin = {
            file = /home/bunny/.local/share/nixcraft/skins/aroace.png;
            variant = "classic";
          };
        };
      };

      RSG = {
        enable = true;

        mrpack = {
          enable = true;
          file = rsg-mrpack;
        };

        lwjglVersion = "3.3.3";
        mangohud.enable = true;

        java = {
          package = pkgs.graalvmPackages.graalvm-oracle_17;
          maxMemory = 14000;
          minMemory = 11500;
        };

        waywall = {
          enable = true;
          binaryPath = "/home/bunny/IdeaProjects/waywall/builddir/waywall/waywall";
          glfwPath = "/home/bunny/mcsr/glfw/libglfw.so";
          rawCommand = "env __GLX_VENDOR_LIBRARY_NAME=amd GBM_DEVICE=/dev/dri/renderD128 AMD_DEBUG=forcegtt,nodcc,nohyperz,nowc /home/bunny/IdeaProjects/waywall/builddir/waywall/waywall wrap -- env __GLX_VENDOR_LIBRARY_NAME=intel GBM_DEVICE=/dev/dri/renderD129 DRI_PRIME=1 $GAME_SCRIPT";
        };

        binEntry = {
          enable = true;
          name = "rsg";
        };

        desktopEntry = {
          enable = true;
          name = "SeedQueue";
          icon = /home/bunny/.local/share/nixcraft/client/instances/RSG/RSG.png;
        };
      };
    };
  };
}
