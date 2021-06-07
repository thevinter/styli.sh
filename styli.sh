#!/usr/bin/env bash
link="https://source.unsplash.com/random/"

if [ -z ${XDG_CONFIG_HOME+x} ]
then
    XDG_CONFIG_HOME="${HOME}/.config"
fi
if [ -z ${XDG_CACHE_HOME+x} ]
then
    XDG_CACHE_HOME="${HOME}/.cache"
fi
confdir="${XDG_CONFIG_HOME}/styli.sh"
if [ ! -d "${confdir}" ]
then
    mkdir -p "${confdir}"
fi
cachedir="${XDG_CACHE_HOME}/styli.sh"
if [ ! -d "${cachedir}" ]
then
    mkdir -p "${cachedir}"
fi

wallpaper="${cachedir}/wallpaper.jpg"

reddit(){
    useragent="thevinter"
    timeout=60

    sort=$2
    top_time=$3
    if [ -z $sort   ]; then
        sort="hot"
    fi

    if [ -z $top_time   ]; then
        top_time=""
    fi

    if [ ! -z $1 ]; then
        sub=$1
    else
        if [ ! -f "${confdir}/subreddits" ]
        then
            echo "Please install the subreddits file in ${confdir}"
            exit 2
        fi
        readarray subreddits < "${confdir}/subreddits"
        a=${#subreddits[@]}
        b=$(($RANDOM % $a))
        sub=${subreddits[$b]}
        sub="$(echo -e "${sub}" | tr -d '[:space:]')"
    fi

    url="https://www.reddit.com/r/$sub/$sort/.json?raw_json=1&t=$top_time"
    content=`wget -T $timeout -U "$useragent" -q -O - $url`
    urls=$(echo -n "$content"| jq -r '.data.children[]|select(.data.post_hint|test("image")?) | .data.preview.images[0].source.url')
    names=$(echo -n "$content"| jq -r '.data.children[]|select(.data.post_hint|test("image")?) | .data.title')
    ids=$(echo -n "$content"| jq -r '.data.children[]|select(.data.post_hint|test("image")?) | .data.id')
    arrURLS=($urls)
    arrNAMES=($names)
    arrIDS=($ids)
    wait # prevent spawning too many processes
    size=${#arrURLS[@]}
    if [ $size -eq 0 ]; then
        echo The current subreddit is not valid.
        exit 1
    fi
    idx=$(($RANDOM % $size))
    target_url=${arrURLS[$idx]}
    target_name=${arrNAMES[$idx]}
    target_id=${arrIDS[$idx]}
    ext=`echo -n "${target_url##*.}"|cut -d '?' -f 1`
    newname=`echo $target_name | sed "s/^\///;s/\// /g"`_"$subreddit"_$target_id.$ext
    wget -T $timeout -U "$useragent" --no-check-certificate -q -P down -O ${wallpaper} $target_url &>/dev/null
}

unsplash() {
    local search="${search// /_}"
    if [ ! -z $height ] || [ ! -z $width ]; then
        link="${link}${width}x${height}";
    else
        link="${link}1920x1080";
    fi

    if [ ! -z $search ]
    then
        link="${link}/?${search}"
    fi

    wget -q -O ${wallpaper} $link
}

usage(){
    echo "Usage: styli.sh [-s | --search <string>]
                          [-h | --height <height>]
                          [-w | --width <width>]
                          [-b | --fehbg <feh bg opt>]
                          [-c | --fehopt <feh opt>]
                          [-r | --subreddit <subreddit>]
                          [-l | --link <source>]
                          [-p | --termcolor]
                          [-d | --directory]
                          [-k | --kde]
                          [-x | --xfce]
                          [-g | --gnome]
                          [-y | --sway]
                          [-m | --monitors <monitor count (nitrogen)>]
                          [-n | --nitrogen]
    "
    exit 2
}

type_check() {
    mime_types=("image/bmp" "image/jpeg" "image/gif" "image/png" "image/heic")
    isType=false

    for requiredType in "${mime_types[@]}"
    do
        imageType=$(file --mime-type  ${wallpaper} | awk '{print $2}')
        if [ "$requiredType" = "$imageType" ]; then
            isType=true
            break
        fi
    done

    if [ $isType = false ]; then
        echo "MIME-Type missmatch. Downloaded file is not an image!"
        exit 1
    fi
}

select_random_wallpaper () {
    wallpaper=$(find $dir -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.svg" -o -iname "*.gif" \) -print | shuf -n 1)
}

pywal_cmd() {
    if [ $pywal -eq 1 ]; then
        wal -c
        wal -i ${wallpaper} -n -q
    fi
}

nitrogen_cmd() {
    for ((monitor=0; monitor < $monitors; monitor++))
    do
        local nitrogen=(nitrogen --save --head=${monitor})

        if [ ! -z $bgtype ]; then
            if [ $bgtype == 'bg-center' ]; then
                nitrogen+=(--set-centered)
            fi
            if [ $bgtype == 'bg-fill' ]; then
                nitrogen+=(--set-zoom-fill)
            fi
            if [ $bgtype == 'bg-max' ]; then
                nitrogen+=(--set-zoom)
            fi
            if [ $bgtype == 'bg-scale' ]; then
                nitrogen+=(--set-scaled)
            fi
            if [ $bgtype == 'bg-tile' ]; then
                nitrogen+=(--set-tiled)
            fi
        else
            nitrogen+=(--set-scaled)
        fi

        if [ ! -z $custom ]; then
            nitrogen+=($custom)
        fi

        nitrogen+=(${wallpaper})

        "${nitrogen[@]}"
    done
}

kde_cmd() {
    cp ${wallpaper} "${cachedir}/tmp.jpg"
    qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "var allDesktops = desktops();print (allDesktops);for (i=0;i<allDesktops.length;i++) {d = allDesktops[i];d.wallpaperPlugin = \"org.kde.image\";d.currentConfigGroup = Array(\"Wallpaper\", \"org.kde.image\", \"General\");d.writeConfig(\"Image\", \"file:${cachedir}/tmp.jpg\")}"
    qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "var allDesktops = desktops();print (allDesktops);for (i=0;i<allDesktops.length;i++) {d = allDesktops[i];d.wallpaperPlugin = \"org.kde.image\";d.currentConfigGroup = Array(\"Wallpaper\", \"org.kde.image\", \"General\");d.writeConfig(\"Image\", \"file:${wallpaper}\")}"
    rm "${cachedir}/tmp.jpg"
}

xfce_cmd() {
    connectedOutputs=$(xrandr | grep " connected" | sed -e "s/\([A-Z0-9]\+\) connected.*/\1/")
    activeOutput=$(xrandr | grep -e " connected [^(]" | sed -e "s/\([A-Z0-9]\+\) connected.*/\1/")
    connected=$(echo $connectedOutputs | wc -w)

    xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/image-path -n -t string -s  ~/Pictures/1.jpeg
    xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitorLVDS1/workspace0/last-image -n -t string -s  ~/Pictures/1.jpeg

    for i in $(xfconf-query -c xfce4-desktop -p /backdrop -l|egrep -e "screen.*/monitor.*image-path$" -e "screen.*/monitor.*/last-image$"); do
        xfconf-query -c xfce4-desktop -p $i -n -t string -s ${wallpaper}
        xfconf-query -c xfce4-desktop -p $i -s ${wallpaper}
    done
}

gnome_cmd() {
    gsettings set org.gnome.desktop.background picture-uri "file://${wallpaper}"
}

sway_cmd() {
    if [ ! -z $bgtype ]; then
        if [ $bgtype == 'bg-center' ]; then
            mode="center"
        fi
        if [ $bgtype == 'bg-fill' ]; then
            mode="fill"
        fi
        if [ $bgtype == 'bg-max' ]; then
            mode="fit"
        fi
        if [ $bgtype == 'bg-scale' ]; then
            mode="stretch"
        fi
        if [ $bgtype == 'bg-tile' ]; then
            mode="tile"
        fi
    else
        mode="stretch"
    fi
    swaymsg output "*" bg "${wallpaper}" "${mode}"
}

feh_cmd() {
    local feh=(feh)
    if [ ! -z $bgtype ]; then
        if [ $bgtype == 'bg-center' ]; then
            feh+=(--bg-center)
        fi
        if [ $bgtype == 'bg-fill' ]; then
            feh+=(--bg-fill)
        fi
        if [ $bgtype == 'bg-max' ]; then
            feh+=(--bg-max)
        fi
        if [ $bgtype == 'bg-scale' ]; then
            feh+=(--bg-scale)
        fi
        if [ $bgtype == 'bg-tile' ]; then
            feh+=(--bg-tile)
        fi
    else
        feh+=(--bg-scale)
    fi

    if [ ! -z $custom ]; then
        feh+=($custom)
    fi

    feh+=(${wallpaper})

    "${feh[@]}"
}

pywal=0
kde=false
xfce=false
gnome=false
nitrogen=false
sway=false
monitors=1

PARSED_ARGUMENTS=$(getopt -a -n $0 -o h:w:s:l:b:r:c:d:m:pknxgy --long search:,height:,width:,fehbg:,fehopt:,subreddit:,directory:,monitors:,termcolor:,kde,nitrogen,xfce,gnome,sway -- "$@")

VALID_ARGUMENTS=$?
if [ "$VALID_ARGUMENTS" != "0" ]; then
    usage
    exit
fi
while :
do
    case "${1}" in
        -b | --fehbg)     bgtype=${2} ; shift 2 ;;
        -s | --search)    search=${2} ; shift 2 ;;
        -h | --height)    height=${2} ; shift 2 ;;
        -w | --width)     width=${2} ; shift 2 ;;
        -l | --link)      link=${2} ; shift 2 ;;
        -r | --subreddit) sub=${2} ; shift 2 ;;
        -c | --fehopt)    custom=${2} ; shift 2 ;;
        -m | --monitors)  monitors=${2} ; shift 2 ;;
        -n | --nitrogen)  nitrogen=true ; shift ;;
        -d | --directory) dir=${2} ; shift 2 ;;
        -p | --termcolor) pywal=1 ; shift ;;
        -k | --kde) 	    kde=true ; shift ;;
        -x | --xfce)      xfce=true ; shift ;;
        -g | --gnome) 	  gnome=true ; shift ;;
        -y | --sway) 	  sway=true ; shift ;;
        -- | '') shift; break ;;
        *) echo "Unexpected option: $1 - this should not happen." ; usage ;;
    esac
done

if [ ! -z $dir ]; then
    select_random_wallpaper
elif [ $link = "reddit" ] || [ ! -z $sub ]; then
    reddit "$sub"
else
    unsplash
fi

type_check

if [ $kde = true ]; then
    kde_cmd
elif [ $xfce = true ]; then
    xfce_cmd
elif [ $gnome = true ]; then
    gnome_cmd
elif [ $nitrogen = true ]; then
    nitrogen_cmd
elif [ $sway = true ]; then
    sway_cmd
else
    feh_cmd
fi

pywal_cmd
