# Styli.sh - Wallpaper switching made easy

Styli.sh is a Bash script that aims to automate the tedious process of finding new wallpapers, downloading and switching them via the configs. **Styli.sh** can download random images from Picsum or the specified subreddits. If you have pywal it also can set automatically your terminal colors.

![Preview](preview.png)

## Requirements

This script is made to work with `feh`, `nitrogen`,
`XFCE`, `GNOME`, `KDE`, `Sway` or `SWWW`, having one of those is a requirement.

## Install

```
git clone https://github.com/thevinter/styli.sh
cd styli.sh
./styli.sh
```

## Usage

```
# To set a random background (automatically detects monitor resolution)
$ ./styli.sh

# Save the current image to ~/Pictures directory
$ ./styli.sh -sa

# To specify a desired width or height
$ ./styli.sh -w 1080 -h 720
$ ./styli.sh -w 2560
$ ./styli.sh -h 1440

# To get a random wallpaper from one of the set subreddits
# NOTE: The width/height parameters DON'T work with reddit
$ ./styli.sh -l reddit

# To get a random wallpaper from a custom subreddit
$ ./styli.sh -r <custom_reddit>
$ ./styli.sh -r wallpaperdump

# To use the builtin feh --bg options
$ ./styli.sh -b <option>
$ ./styli.sh -b bg-scale -r widescreen-wallpaper

# To add custom feh flags
$ ./styli.sh -c <flags>
$ ./styli.sh -c --no-xinerama -r widescreen-wallpaper

# To automatically set the terminal colors
$ ./styli.sh -p

# To use nitrogen instead of feh
$ ./styli.sh -n

# To update > 1 screens using nitrogen
$ ./styli.sh -n -m <number_of_screens>

# Choose a random background from a directory
$ ./styli.sh -d /path/to/dir
```

## KDE, GNOME, XFCE, Sway & SWWW

KDE, GNOME, XFCE, Sway and SWWW are natively supported without the need of feh. The script currently does not allow to scale the image.
To use their built-in background managers use the appropriate flag.

```
# GNOME
$ ./styli.sh -g

# XFCE
$ ./styli.sh -x

# KDE
$ ./styli.sh -k

# Hyprpaper (Hyprland)
$ ./styli.sh -hp

# Sway
$ ./styli.sh -y

# SWWW
$ ./styli.sh -sw

```

## Tips And Tricks

To set a new background every time you reboot your computer add the following to your `i3/config` file (or any other WM config)

```
exec_always path/to/script/styli.sh
```

To change background every hour launch the following command

```
crontab -e
```

and add the following to the opened file

```
@hourly path/to/script/styli.sh
```

## Custom subreddits

To manage custom subreddits just edit the `subreddits` file by placing there all your desired communities, one for each newline
