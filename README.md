# Audio Switcher — DMS Plugin

A [Dank Material Shell](https://danklinux.com) plugin that adds a bar pill for
quickly switching between two audio output devices (e.g. headset and stereo
speakers).

## Features

- Toggles between two configured Pipewire sinks
- Shows the current device name and an appropriate icon in the bar
- Animated label transition on switch
- Works in both horizontal and vertical bar orientations


## Configuration

You can change the two sinks in the plugin settings. The display names can be defined in the regular DMS settings. Each output's bar icon can be set in the plugin settings; Automatic uses the device description.


## External Toggle

The pill toggles through the DMS widget IPC, so any external trigger can call it:

```bash
dms ipc call widget toggle audioSwitcher
```

Example Hyprland keybind:

```ini
bind = $mod, F9, exec, dms ipc call widget toggle audioSwitcher
```

Example Niri keybind:

```kdl
Mod+F9 { spawn "dms" "ipc" "call" "widget" "toggle" "audioSwitcher"; }
```

## Screenshots

| Horizontal                   | Vertical                       | Settings                       |
| ---------------------- | ---------------------------------- | ---------------------------------- |
| <img width="122" height="42" alt="image" src="https://github.com/user-attachments/assets/957d1ecf-4dc9-4e3d-abce-db636c4608d2" />    | <img width="42" height="192" alt="image" src="https://github.com/user-attachments/assets/a3f56350-258d-4c27-a4cb-c096ee340a45" />             | <img  height="350" alt="image" src="https://github.com/user-attachments/assets/2b6f86af-95d1-42b4-b8fe-aef606fbb5df" /> |





