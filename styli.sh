#!/bin/bash
link="https://source.unsplash.com/random/"
reddit(){
    useragent="thevinter"
    timeout=60

    readarray subreddits < subreddits
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
    subreddit="$(echo -e "${sub}" | tr -d '[:space:]')"
    url="https://www.reddit.com/r/$subreddit/$sort/.json?raw_json=1&t=$top_time"
    content=`wget -T $timeout -U "$useragent" -q -O - $url`
    urls=$(echo -n "$content"| jq -r '.data.children[]|select(.data.post_hint|test("image")?) | .data.preview.images[0].source.url')
    names=$(echo -n "$content"| jq -r '.data.children[]|select(.data.post_hint|test("image")?) | .data.title')
    ids=$(echo -n "$content"| jq -r '.data.children[]|select(.data.post_hint|test("image")?) | .data.id')
    arrURLS=($urls)
    arrNAMES=($names)
    arrIDS=($ids)
    wait # prevent spawning too many processes
    size=${#arrURLS[@]}
    idx=$(($RANDOM % $size))
    target_url=${arrURLS[$idx]}
    target_name=${arrNAMES[$idx]}
    target_id=${arrIDS[$idx]}
    echo $target_url
    ext=`echo -n "${target_url##*.}"|cut -d '?' -f 1`
    newname=`echo $target_name | sed "s/^\///;s/\// /g"`_"$subreddit"_$target_id.$ext
    wget -T $timeout -U "$useragent" --no-check-certificate -q -P down -O "wallpaper.jpg" $target_url &>/dev/null

}

while getopts h:w:s:l:b flag
do
    case "${flag}" in
        b) bgtype=${OPTARG};;
        s) search=${OPTARG};;
        h) height=${OPTARG};;
        w) width=${OPTARG};;
        l) link=${OPTARG};;
    esac
done

feh=(feh)

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
if [ $link = "reddit" ]
then
    reddit
    feh+=(wallpaper.jpg)
    "${feh[@]}"
else
    if [ ! -z $height ] || [ ! -z $width ]; then
        echo debug
        link="${link}${width}x${height}";
    else
        link="${link}1920x1080";
    fi
    if [ ! -z $search ]
    then
        link="${link}/?${search}"
    fi
    wget -q -O wallpaper $link
    feh+=(wallpaper)
    "${feh[@]}"
fi

