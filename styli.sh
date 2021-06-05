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
reddit(){
    useragent="thevinter"
    timeout=60

    if [ ! -f "${confdir}/subreddits" ]
    then
        echo "Please install the subreddits file in ${confdir}"
        exit 2
    fi
    readarray subreddits < "${confdir}/subreddits"
    a=${#subreddits[@]}
    b=$(($RANDOM % $a))
    sub=${subreddits[$b]}
    sort=$2
    top_time=$3
    if [ -z $sort   ]; then
        sort="hot"
    fi

    if [ -z $top_time   ]; then
        top_time=""
    fi
    sub="$(echo -e "${sub}" | tr -d '[:space:]')"
    if [ ! -z $1 ]; then
        sub=$1
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
    wget -T $timeout -U "$useragent" --no-check-certificate -q -P down -O "${cachedir}/wallpaper.jpg" $target_url &>/dev/null

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
                          "
    exit 2
}
pywal=0
kde=false
PARSED_ARGUMENTS=$(getopt -a -n $0 -o h:w:s:l:b:r:c:d:pk --long search:,height:,width:,fehbg:,fehopt:,subreddit:,directory:,termcolor:,kde -- "$@")
VALID_ARGUMENTS=$?
if [ "$VALID_ARGUMENTS" != "0" ]; then
    usage
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
        -d | --directory) dir=${2} ; shift 2 ;;
        -p | --termcolor) pywal=1 ; shift ;;
        -k | --kde) kde=true ; shift ;;
        -- | '') shift; break ;;
        *) echo "Unexpected option: $1 - this should not happen." ; usage ;;
    esac
done
feh=(feh)
search="${search// /_}"
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
if [ ! -z $dir ]; then
    feh+=(--randomize $dir)
    "${feh[@]}"
else
    if [ $link = "reddit" ] || [ ! -z $sub ]
    then
        reddit "$sub"
        feh+=("${cachedir}/wallpaper.jpg")
        "${feh[@]}"
        if [ $pywal -eq 1 ]; then
            wal -c 
            wal -i "${cachedir}/wallpaper.jpg" -n
        fi 
    else
        if [ ! -z $height ] || [ ! -z $width ]; then
            link="${link}${width}x${height}";
        else
            link="${link}1920x1080";
        fi
        if [ ! -z $search ]
        then
            link="${link}/?${search}"
        fi
        wget -q -O "${cachedir}/wallpaper.jpg" "${link}"

        if [ $kde = true ]; then
            cp "${cachedir}/wallpaper.jpg" "${cachedir}/tmp.jpg"
            qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "var allDesktops = desktops();print (allDesktops);for (i=0;i<allDesktops.length;i++) {d = allDesktops[i];d.wallpaperPlugin = \"org.kde.image\";d.currentConfigGroup = Array(\"Wallpaper\", \"org.kde.image\", \"General\");d.writeConfig(\"Image\", \"file:${cachedir}/tmp.jpg\")}"
            qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "var allDesktops = desktops();print (allDesktops);for (i=0;i<allDesktops.length;i++) {d = allDesktops[i];d.wallpaperPlugin = \"org.kde.image\";d.currentConfigGroup = Array(\"Wallpaper\", \"org.kde.image\", \"General\");d.writeConfig(\"Image\", \"file:${cachedir}/wallpaper.jpg\")}"
            rm "${cachedir}/tmp.jpg"
        else
            feh+=("${cachedir}/wallpaper.jpg")
            "${feh[@]}"
        fi

        if [ $pywal -eq 1 ]; then
            wal -c 
            wal -i "${cachedir}/wallpaper.jpg" -n
        fi
    fi
fi
