#!/bin/bash
# https://gist.github.com/Voldrix/84a01b602e5d6c53c2b67e156bf26a10
#Creates an animated thumbnail of a video clip
#This script uses scene cuts instead of fixed time intervals, and does not work well for videos with few/infrequent scene cuts
if [ -z "$1" ];then echo "Usage: <Video Files...> [outputs to same dir as input]" &>2;exit 1;fi

numOfScenes=8 #max number of scenes
sceneLength=1.5 #length of each scene in seconds
sceneDelay=1.7 #time (seconds) after a frame cut to start scene (to avoid transition effects)

for i;do
  meta=($(ffprobe -v 0 -select_streams V:0 -show_entries stream=r_frame_rate:format=duration -of default=nw=1:nk=1 "$i"))
  framerate=$(bc <<< "scale=3;${meta[0]}/2")
  sceneSpacer=$(bc <<< "scale=3;${meta[1]}/(($numOfScenes-1)*2)") #min time between scene selection

  ffmpeg -nostdin -ss $sceneSpacer -i "$i" -vsync vfr -vf \
      "select=if(gt(scene\,0.5)*(isnan(prev_selected_t)+gte(t-prev_selected_t\,$sceneSpacer))\, \
      st(1\,t)*0*st(2\,ld(2)+1)\,if(ld(1)*lte(ld(2)\,$numOfScenes)\,between(t\,ld(1)+$sceneDelay\, \
      ld(1)+$sceneDelay+$sceneLength))),scale=320:180:force_original_aspect_ratio=decrease:force_divisible_by=2:flags=bicubic+full_chroma_inp:sws_dither=none, \
      framestep=2,setpts=N/($framerate*TB),split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" \
      -an -sn -map_chapters -1 -map_metadata -1 -hide_banner -compression_level 5 -q:v 75 -loop 0 -f gif -y $XDG_CACHE_HOME/nvimager/${i##*/}.gif

done
