{ inputs, pkgs, ... }:
let
  ranked-mrpack = pkgs.fetchurl {
    url = "https://redlime.github.io/MCSRMods/modpacks/v4/MCSRRanked-Linux-1.16.1.mrpack";
    hash = "sha256:10lqn5m3gxm8dzjw71abzp0cjq1pn3gd5mf30zgzawb81ilqbcsx";
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

        java = {
          package = pkgs.jdk17;
          maxMemory = 4096;
          minMemory = 512;
        };

        waywall.enable = true;

        binEntry = {
          enable = true;
          name = "ranked";
        };

        desktopEntry = {
          enable = true;
          name = "MCSR Ranked";
        };
      };

      RSG = {
        enable = true;

        mrpack = {
          enable = true;
          file = rsg-mrpack;
        };

        java = {
          package = pkgs.graalvmPackages.graalvm-oracle_17;
          maxMemory = 14000;
          minMemory = 11500;
          extraArguments = [
            "-XX:+UnlockExperimentalVMOptions"
            "-XX:+AlwaysPreTouch"
            "-XX:+UseZGC"
            "-XX:+UseNUMA"
            "-Dgraal.TuneInlinerExploration=1"
            "-XX:MaxInlineLevel=25"
            "-XX:CompileThreshold=100"
            "-XX:+TieredCompilation"
            "-XX:TieredStopAtLevel=4"
            "-XX:+UseBiasedLocking"
            "-XX:+EliminateLocks"
            "-XX:+OptimizeStringConcat"
            "-XX:+ExplicitGCInvokesConcurrent"
            "-XX:ReservedCodeCacheSize=768m"
            "-XX:+InlineSynchronizedMethods"
            "-XX:+TrustFinalNonStaticFields"
            "-XX:+UseCondCardMark"
            "-XX:+UseFPUForSpilling"
            "-XX:+UseFastUnorderedTimeStamps"
            "-XX:+OptimizeFill"
            "-XX:+UseLargePages"
            "-XX:ZUncommitDelay=10"
            "-XX:+ZUncommit"
            "-XX:+EnableJVMCI"
            "-XX:+EagerJVMCI"
            "-Dgraal.CompileGraalWithC1Only=false"
            "-Dgraal.OptAssumptions=false"
            "-Djdk.graal.CompilerConfiguration=enterprise"
            "-Djdk.graal.ShowConfiguration=info"
            "-Djdk.graal.SpectrePHTBarriers=AllTargets"
            "-Djdk.graal.Vectorization=true"
            "-Djdk.graal.OptDuplication=true"
            "-Djdk.graal.CompilationFailureAction=Diagnose"
            "-Dengine.CompilerThreads=32"
          ];
        };

        waywall.enable = true;

        binEntry = {
          enable = true;
          name = "rsg";
        };

        desktopEntry = {
          enable = true;
          name = "SeedQueue";
        };
      };
    };
  };
}
