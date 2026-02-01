{ pkgs, ... }:

{
  services.easyeffects = {
    enable = true;
  };

  # EasyEffects equalizer preset (Moondrop Blessing 3)
  xdg.configFile."easyeffects/db/equalizerrc".text = ''
    [soe][Equalizer#0]
    bypass=true
    outputGain=-1

    [soe][Equalizer#0#left]
    band0Frequency=105
    band0Gain=-0.3
    band0Q=0.7
    band0Type=5
    band1Frequency=40
    band1Gain=1.1
    band1Q=1.2
    band2Frequency=95
    band2Gain=1.8
    band2Q=0.66
    band3Frequency=1389
    band3Gain=-0.9
    band3Q=1.49
    band4Frequency=3118
    band4Gain=-2.2
    band4Q=3.67
    band5Frequency=4353
    band5Gain=-3.1
    band5Q=5.97
    band6Frequency=5278
    band6Gain=3.3
    band6Q=5.72
    band7Frequency=6052
    band7Gain=-1.7
    band7Q=6
    band8Frequency=7544
    band8Gain=2.2
    band8Q=2.12
    band9Frequency=10000
    band9Gain=-3.6
    band9Q=0.7
    band9Type=3

    [soe][Equalizer#0#right]
    band0Frequency=105
    band0Gain=-0.3
    band0Q=0.7
    band0Type=5
    band1Frequency=40
    band1Gain=1.1
    band1Q=1.2
    band2Frequency=95
    band2Gain=1.8
    band2Q=0.66
    band3Frequency=1389
    band3Gain=-0.9
    band3Q=1.49
    band4Frequency=3118
    band4Gain=-2.2
    band4Q=3.67
    band5Frequency=4353
    band5Gain=-3.1
    band5Q=5.97
    band6Frequency=5278
    band6Gain=3.3
    band6Q=5.72
    band7Frequency=6052
    band7Gain=-1.7
    band7Q=6
    band8Frequency=7544
    band8Gain=2.2
    band8Q=2.12
    band9Frequency=10000
    band9Gain=-3.6
    band9Q=0.7
    band9Type=3
  '';

  # Main EasyEffects config
  xdg.configFile."easyeffects/db/easyeffectsrc".text = ''
    [Presets]
    lastLoadedOutputPreset=Moondrop Blessing 3

    [StreamInputs]
    inputDevice=alsa_input.usb-3142_fifine_Microphone-00.analog-stereo

    [StreamOutputs]
    mostUsedPresets=Moondrop Blessing 3
    outputDevice=alsa_output.usb-Topping_DX1-00.HiFi__Headphones__sink
    plugins=equalizer#0
    usedPresets=Moondrop Blessing 3:10

    [Style]
    forceBreezeTheme=false

    [Window]
    autostartOnLogin=true
    height=654
    noWindowAfterStarting=true
    width=1189
  '';
}
