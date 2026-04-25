# yatline-selected-size.yazi

A [yatline.yazi](https://github.com/imsi32/yatline.yazi) addon that shows the total size of selected files and directories. When a directory is selected, also shows the total recursive file count. Results are cached per path and update as you change the selection.

https://github.com/user-attachments/assets/90c3f8f1-1f0e-4f29-9ed7-0805caa0c6d8

## Requirements

- [yatline.yazi](https://github.com/imsi32/yatline.yazi)

## Installation

**Via ya pkg:**
```bash
ya pkg add pakhromov/yatline-selected-size
```

**Manual:**
```bash
git clone https://github.com/pakhromov/yatline-selected-size.yazi ~/.config/yazi/plugins/yatline-selected-size.yazi
```

Add to `~/.config/yazi/init.lua` **after** yatline's own setup:
```lua
require("yatline-selected-size"):setup()
```

Add the component to your yatline config:
```lua
{ type = "coloreds", custom = false, name = "selected-files-size" }
```

## Display

- **Files only selected** - shows total size (e.g. `1.2 MB`)
- **Directory selected** - shows recursive file count and total size (e.g. `42 files, 1.2 MB`)
- **Nothing selected** - component is hidden
