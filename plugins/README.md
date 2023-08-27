# `styli.sh` plugins

To provide a way to significantly influence the behaviour of `styli.sh` without having to modify the core code (i.e. the `styli.sh` script),
in this version a plugin infrastructure is implemented.

## Plugin Types

There are two types of plugins:

1. wallpaper processing filters: \
  These are executed after parsing options and downloading the wallpaper, but before setting the wallpaper. That means to be effective, the plugin should simply modify the wallpaper (pointed to by `WALLPAPER`), and the wallpaper set function will then use the modified image automatically.
2. Function overrides: \
  These are prepared in the core script by defining a variable instead of a hard-coded function name. By having the plugin override the corresponding variable with a function name defined in the plugin file (which is sourced by the core script to register all its functions), the plugin becomes active.

## Usage

Plugins are simply called by adding the `-f | --filter` flag to the `styli.sh` invocation, e.g.

```
styli.sh -w 3840 -h 2160 -s "sea mountains sunset" -f "logo_overlay:$HOME/Pictures/wallpapers/logos/yourlogo-4k.png" -f "setwall_hyprpaper"
```

## Implementation/Workings

See the example scripts in `plugins/` to learn how these two types of plugins are defined (differently!).

Rougly it works like this:

All `-f ...` arguments are read into the `FILTERS` array.

Plugins are automatically "registered" by simply sourcing all shell scripts (ending in `.sh`) in the `plugins/` directory.

The sourcing takes place after argument parsing but before the processing pipeline begins. That means during plugin registration variables like `WALLPAPER` and `FILTERS` are already set and accessible.


### Processing Filters

_Processing filters_ will simply be called as a function, i.e. for
```
... -f filterfun:farg1:farg2
```
the function
```
filterfun farg1 farg2
```
will be called after downloading the wallpaper as usual.
The filter script (usually) would use the filer arguments and the `WALLPAPER` variable to process/modify the referenced image file, after which `styli.sh` sets the `WALLPAPER` as usual.

### Function Override Plugins

_Function override plugins_ will overwrite global variables used in `styli.sh` to refer to an alternative function that is implemented in a plugin script.

E.g. the `SETWALL` global variable will be set to the requested wallpaper-set function, e.g. `kde_cmd` if the `-k` flag was used. However, a custom wallpaper-set function can be set instead, by defining a plugin that defines a wallpaper-set function and setting `SETWALL` to that function's name.

For this to work, two conditions must be met:
1. The variables must be set _during_ the sourcing of the plugins
2. The corresponding plugin element must be _removed_ from the `FILTERS` array, because otherwise it will be evaluated later as a _processing plugin_ as well, which is not desired.

A convenience function `init()` to make this trivial is provided in `plugins/_lib.sh`.