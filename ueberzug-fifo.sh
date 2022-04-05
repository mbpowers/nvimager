#!/bin/bash

# modified from "https://github.com/nvim-telescope/telescope-media-files.nvim/blob/master/scripts/vimg"
# which comes from "https://github.com/cirala/vifmimg/issues?q=is%3Aissue"

case $(uname) in
 Darwin)
     echo "Not supported"
     exit
	;;
esac

SCRIPT=`realpath $0`

readonly BASH_BINARY="$(which bash)"
declare -x UEBERZUG_FIFO="$(mktemp --dry-run --suffix "vimg-$$-ueberzug")"
declare -x PREVIEW_ID="preview"

declare -x TMP_FOLDER="${XDG_CACHE_HOME}/nvimager"
mkdir -p $TMP_FOLDER

function start_ueberzug {
    mkfifo "${UEBERZUG_FIFO}"
    tail --follow "$UEBERZUG_FIFO" | ueberzug layer --silent --parser bash &
}

function finalise {
    3>&- \
        exec
    &>/dev/null \
        rm "${UEBERZUG_FIFO}"
    &>/dev/null \
        kill $(jobs -p)
}


# draw_preview(type, path, x, y, width, height, cover)
function draw_preview {

    if [[ "$1" == "imagepreview" ]]; then
        >"${UEBERZUG_FIFO}" declare -A -p cmd=( \
            [action]=add [identifier]="${PREVIEW_ID}" \
            [x]="${4}" [y]="${5}" \
            [width]="${6}" [height]="${7}" \
            [path]="${2}" [scaler]="${3}")

    elif [[ "$1" == "gifpreview" ]]; then
        file="${2##*/}"
        path="${PWD}/$2"; path="${path// /_}"; path="${path//\//_}" #replace space and / into _
        path="${TMP_FOLDER}/${path}"

        echo -ne "Loading preview... 0%\r"
        frame_total=$(identify -format "%n\n" $2 | head -1)
        IFS=$'\n' read -r -d '' -a ticks < <(identify -format "%T\n" $2 && printf '\0'); unset IFS
        [[ $(ls ${path}/ 2>/dev/null | wc -l) -ne $frame_total ]] \
          && (mkdir -p ${path} && convert -coalesce -resize 720x480\> "$2" "${path}/${file}.png"&disown)

        frame_index=0
        while true; do
          frame_extracted=$(ls -1 ${path}/ 2>/dev/null| wc -l)
          if [[ $frame_extracted -lt $frame_total ]]; then
            echo -ne "Loading preview... $((frame_extracted*100/frame_total))%\r"
          else
            echo -ne "                     \r"
            >"${UEBERZUG_FIFO}" declare -A -p cmd=( \
                [action]=add [identifier]="${PREVIEW_ID}" \
                [x]="${4}" [y]="${5}" \
                [width]="${6}" [height]="${7}" \
                [path]="${path}/${file}-${frame_index}.png" [scaler]="${3}")
            delay=$(bc <<< "scale=2; ${ticks[$frame_index]}/100") # 1 tick == 1/100s
            sleep $delay
          fi
          frame_index=$((frame_index + 1))
          [[ $frame_index -ge $frame_total ]] && frame_index=0
        done

    # Image Thumbnail for Video
    # elif [[ "$1" == "videopreview" ]]; then
    #     path="${2##*/}"
    #     echo -e "Loading preview..\nFile: $path"
    #     ffmpegthumbnailer -i "$2" -o "${TMP_FOLDER}/${path}.png" -s 0 -q 10 # fast png thumbnail
    #     >"${UEBERZUG_FIFO}" declare -A -p cmd=( \
    #         [action]=add [identifier]="${PREVIEW_ID}" \
    #         [x]="${4}" [y]="${5}" \
    #         [width]="${6}" [height]="${7}" \
    #         [path]="${TMP_FOLDER}/${path}.png"  [scaler]="${3}")

    # GIF Thumbnail for Video
    elif [[ "$1" == "videopreview" ]]; then
        file="${2##*/}"
        [ ! -f "${TMP_FOLDER}/${file}.gif" ] && ../thumbnailer.sh "$2"
            # https://www.reddit.com/r/ffmpeg/comments/gx9j4h/how_can_i_detect_scene_changes_and_grab_2_seconds/?utm_source=reddit&utm_medium=usertext&utm_name=ffmpeg&utm_content=t1_gqkofmx
            # ffmpeg -i "$2" -vsync vfr -vf \
            # "select=if(gt(scene\,0.5)*(isnan(prev_selected_t)+gte(t-prev_selected_t\,2))\,st(1\,t)*0*st(2\,ld(2)+1)\,if(ld(1)*lt(ld(2)\,4)\,between(t\,ld(1)+2\,ld(1)+4))), \
            # scale=320:180:force_original_aspect_ratio=decrease:flags=bicubic+full_chroma_inp:sws_dither=none,framestep=2,setpts=N/(12*TB)" \
            # -an -sn -map_metadata -1 -compression_level 5 -q:v 75 -loop 0 -f gif -y "${TMP_FOLDER}/${file}".gif
            # ffmpeg -ss 5 -i "$2" -t 10 -pix_fmt rgb24 ${TMP_FOLDER}/${path}.gif

        file="${file##*/}.gif"
        path="${PWD}/${TMP_FOLDER}/${path}"; path="${path// /_}"; path="${path//\//_}" #replace space and / into _
        path="${TMP_FOLDER}/${path}_${file}"

        echo -ne "Loading preview... 0%\r"
        frame_total=$(identify -format "%n\n" ${TMP_FOLDER}/$file | head -1)
        IFS=$'\n' read -r -d '' -a ticks < <(identify -format "%T\n" ${TMP_FOLDER}/$file && printf '\0'); unset IFS
        [[ $(ls ${path}/ 2>/dev/null | wc -l) -ne $frame_total ]] \
          && (mkdir -p ${path} && convert -coalesce -resize 720x480\> ${TMP_FOLDER}/"$file" "${path}/${file}.png"&disown)

        frame_index=0
        while true; do
          frame_extracted=$(ls -1 ${path}/ 2>/dev/null| wc -l)
          if [[ $frame_extracted -lt $frame_total ]]; then
            echo -ne "Loading preview... $((frame_extracted*100/frame_total))%\r"
          else
            echo -ne "                     \r"
            >"${UEBERZUG_FIFO}" declare -A -p cmd=( \
                [action]=add [identifier]="${PREVIEW_ID}" \
                [x]="${4}" [y]="${5}" \
                [width]="${6}" [height]="${7}" \
                [path]="${path}/${file}-${frame_index}.png"  [scaler]="${3}")
            delay=$(bc <<< "scale=2; ${ticks[$frame_index]}/100") # 1 tick == 1/100s
            sleep $delay
          fi
          frame_index=$((frame_index + 1))
          [[ $frame_index -ge $frame_total ]] && frame_index=0
        done

    elif [[ "$1" == "pdfpreview" ]]; then
        path="${2##*/}"
        echo -e "Loading preview..\nFile: $path"
        [[ ! -f "${TMP_FOLDER}/${path}.png" ]] && pdftoppm -png -singlefile "$2" "${TMP_FOLDER}/${path}"
        >"${UEBERZUG_FIFO}" declare -A -p cmd=( \
            [action]=add [identifier]="${PREVIEW_ID}" \
            [x]="${4}" [y]="${5}" \
            [width]="${6}" [height]="${7}" \
            [path]="${TMP_FOLDER}/${path}.png" [scaler]="${3}")

    fi
}

# draw_preview(type, path, cover, x, y, width, height)
function parse_options {
    extension="${1##*.}"
    case $extension in
        jpg | png | jpeg | webp) draw_preview imagepreview "$1" $2 $3 $4 $5 $6 ;;
        gif) draw_preview gifpreview "$1" $2 $3 $4 $5 $6 ;;
        avi | mp4 | wmv | dat | 3gp | ogv | mkv | mpg | mpeg | vob |  m2v | mov | webm | mts | m4v | rm  | qt | divx) draw_preview videopreview "$1" $2 $3 $4 $5 $6 ;;
        pdf | epub) draw_preview pdfpreview "$1" $2 $3 $4 $5 $6 ;;
        *) echo -n "unknown file $1" ;;
    esac
}

trap finalise EXIT
start_ueberzug
parse_options "${@}"
read
