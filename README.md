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

You can change the two sinks in the plugin settings. The display names can be defined in the regular DMS settings.


## External Toggle

DMS IPC does not expose plugin functions directly. To trigger the toggle
externally (e.g. from a compositor keybind), use the file watcher approach:

```bash
echo "1" > /tmp/audio-switcher-toggle
```

Example Hyprland keybind:

```ini
bind = $mod, F9, exec, echo "1" > /tmp/audio-switcher-toggle
```
