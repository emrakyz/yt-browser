#!/bin/sh
while ! ping -c 1 "9.9.9.9" > "/dev/null" 2>&1; do sleep "0.5"; done

dd="${XDG_CACHE_HOME}/ychannels"
chl="${XDG_DATA_HOME}/channels"
ctg="${XDG_DATA_HOME}/categories"

p() { printf "%s\n" "${@}"; }

[ ! -s "${chl}" ] && [ ! -s "${ctg}" ] && {
        p \
                "Luke Smith=https://www.youtube.com/@LukeSmithxyz/videos" \
                "Mental Outlaw=https://www.youtube.com/@MentalOutlaw/videos" \
                > "${chl}"
        p "Tech=Luke Smith|Mental Outlaw" > "${ctg}"
}

mkdir -p "${dd}" && touch "${chl}"
n() { notify-send -i "${XDG_CONFIG_HOME}/dunst/yt.png" -u "critical" "${1}"; }
comd() {
        chn="${1}"
        df="${dd}/${chn}.tsv"
        odf="${dd}/${chn}_old.tsv"
        [ -f "${odf}" ] && {
                ou="$(cut -f2 "${odf}")"
                nu="$(cut -f2 "${df}")"
                p "${ou}" | sort > "t1"
                p "${nu}" | sort > "t2"
                nv="$(comm -13 "t1" "t2" | wc -l)"
                rm -f "t1" "t2"
                [ "${nv}" -gt "0" ] && n "${chn} | ${nv} videos."
        }
}
ud() {
        chn="${1}"
        cu="${2}"
        df="${dd}/${chn}.tsv"
        odf="${dd}/${chn}_old.tsv"
        mv -f "${df}" "${odf}" 2> "/dev/null"
        yt-dlp -j --flat-playlist --skip-download --extractor-args \
                "youtubetab:approximate_date" "${cu}" |
                jq -r '[.title, .url, .view_count, .duration, .upload_date] | @tsv' > "${df}"
}
uac() {
        while IFS="=" read -r chn cu; do
                ud "${chn}" "${cu}" &
        done < "${chl}"
        wait
        while IFS="=" read -r chn cu; do
                comd "${chn}"
        done < "${chl}"

        avf="${dd}/all_videos.tsv"
        rm -f "${avf}"
        while IFS= read -r line; do
                cn="${line%%=*}"
                cat "${dd}/${cn}.tsv" >> "${avf}"
        done < "${chl}"
}
uac
