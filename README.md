# Wallpaper switching on i3 made easy

Stily.sh is a Bash script that aims to automate the tedious process of finding new wallpapers, downloading and switching them via the i3 config. **Styly.sh** can search for specific wallpapers from unsplash or download
a random image from the specified subreddits.

![Preview](preview.png)

## Install
    ```
git clone https://github.com/thevinter/styli.sh
cd styli.sh
./styli.sh
    ```

## Usage 
    ```
# To set a random 1920x1080 background
$ ./styli.sh

# To specify a desired width or height
$ ./styli.sh -w 1080 -h 720
$ ./styli.sh -w 2560
$ ./styli.sh -h 1440

# To set a wallpaper based on a search term
$ ./styli.sh -s island 
$ ./styli.sh -s sea -w 1080

# To get a random wallpaper from one of the set subreddits
# NOTE: The width/height/search parameters DON't work with reddit
$ ./styli.sh -l reddit
    ```

## Custom subreddits
To manage custom subreddits just edit the ```subreddits``` file by placing all your desired communities, one for each newline

