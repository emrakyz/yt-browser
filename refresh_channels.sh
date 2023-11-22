#!/bin/dash

while ! ping -c 1 9.9.9.9 > /dev/null 2>&1; do sleep 0.5; done

DATA_DIR="$HOME/.cache/youtube_channels"
CHANNEL_LIST="$HOME/.local/share/channels.txt"
mkdir -p "$DATA_DIR" && touch "$CHANNEL_LIST"

error_handling() {
    [ -s "$CHANNEL_LIST" ] || {
	    notify-send "You don't have any channels in 'channels.txt'."
	    exit 1
    }
    grep -q "^.*=https://www.youtube.com/@[[:alnum:]]*/videos$" "$CHANNEL_LIST" || {
	    notify-send "'channels.txt' formatting is wrong."
	    exit 1
    }
}

compare_data() {
  local channel_name="$1"
  local data_file="${DATA_DIR}/${channel_name}.tsv"
  local old_data_file="${DATA_DIR}/${channel_name}_old.tsv"

    [ -e "$old_data_file" ] && {
    old_urls=$(cut -f2 "$old_data_file")
    new_urls=$(cut -f2 "$data_file")

    echo "$old_urls" | sort > temp1
    echo "$new_urls" | sort > temp2
    new_videos=$(comm -13 temp1 temp2 | wc -l)
    rm temp1 temp2

    [ "$new_videos" -gt 0 ] && notify-send -u critical "$channel_name | $new_videos videos"
  }
}

update_data() {
  local channel_name="$1"
  local channel_url="$2"
  local data_file="${DATA_DIR}/${channel_name}.tsv"
  local old_data_file="${DATA_DIR}/${channel_name}_old.tsv"

  mv "$data_file" "$old_data_file" 2>/dev/null

  yt-dlp -j --flat-playlist --skip-download --extractor-args youtubetab:approximate_date "$channel_url" | jq -r '[.title, .url, .view_count, .duration, .upload_date] | @tsv' > "$data_file"
}

update_all_channels() {
  while IFS="=" read -r channel_name channel_url; do
    update_data "$channel_name" "$channel_url" &
  done < "$CHANNEL_LIST"

  wait

  while IFS="=" read -r channel_name channel_url; do
    compare_data "$channel_name"
  done < "$CHANNEL_LIST"
}

error_handling
update_all_channels
