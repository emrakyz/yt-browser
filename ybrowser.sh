#!/bin/sh
dd="${XDG_CACHE_HOME}/ychannels"
yd="${HOME}/ytvideos"
cl="${XDG_DATA_HOME}/categories"
chl="${XDG_DATA_HOME}/channels"
cld="${XDG_DATA_HOME}/clists"
mkdir -p "${dd}" "${yd}" "${cld}"
pr() { printf "%s\n" "${@}"; }

d() {
        i="$(cat)"
        l="$(pr "${i}" | wc -l)"
        [ "${l}" -gt "21" ] && l="21"
        [ "${i}" ] || l="0"
        x="$(pr "${i}" | wc -L)"
        [ "${x}" -gt "152" ] && x="152"
        chk="$(pr "${1}" | wc -L)"
        [ "${chk}" -gt "${x}" ] && x="${chk}"
        pr "${i}" | rofi -dmenu -i -l "${l}" -p "${1}" \
                -theme-str "window { width: calc(${x}ch + 4ch); }"
}

n() { notify-send -i "${XDG_CONFIG_HOME}/dunst/yt.png" "${1}"; }
sv() {
        df="${1}"
        so="${2}"
        case "${so}" in
                "@@sv") sort -nr -t"	" -k3 "${df}" ;;
                "@@sd") sort -nr -t"	" -k4 "${df}" ;;
                *) sort -nr -t"	" -k5 "${df}" ;;
        esac | hck -d '\t' -f1
}
gv() {
        cn="${1}"
        so="${2}"
        df="${dd}/${cn}.tsv"
        sv "${df}" "${so}"
}
vu() {
        cn="${1}"
        vt="${2}"
        df="${dd}/${cn}.tsv"
        rg -F "${vt}" "${df}" | hck -d '\t' -f2
}
ma() {
        pr "👀  WATCH" "📥  DOWNLOAD" "➡️  SEND TO A LIST" | d "Actions"
}
ca() {
        lsts="$(pr "${cld}"/* | sed 's|.*/||')"
        [ "${lsts}" = "*" ] && lsts=""
        pr "${lsts}" "🆕  CREATE LIST" "❌  DELETE LIST" | d "Lists"
}
lva() {
        pr "👀  WATCH" "📥  DOWNLOAD" "🗑️  DELETE" | d "Actions"
}
atl() {
        vt="${1}"
        cn="${2}"
        ln="${3}"
        pr "${cn}: ${vt}" >> "${cld}/${ln}"
}
clm() {
        while true; do
                lst="$(ca)"
                case "${lst}" in
                        "🆕  CREATE LIST")
                                nlst="$(pr | d "Name")"
                                [ "${nlst}" ] && touch "${cld}/${nlst}"
                                ;;
                        "❌  DELETE LIST")
                                dlst="$(fd -t "f" . "${cld}" -x basename | d "Delete List")"
                                [ "${dlst}" ] && rm -f "${cld}/${dlst}"
                                ;;
                        "") return ;;
                        *) cvm "${lst}" ;;
                esac
        done
}
cvm() {
        ln="${1}"
        while true; do
                vi=$(d "Videos" < "${cld}/${ln}")
                [ "${vi}" ] || return
                cn="${vi%%: *}"
                vt="${vi##*: }"
                clvm "${vt}" "${cn}" "${ln}"
        done
}
clvm() {
        vt="${1}"
        cn="${2}"
        ln="${3}"
        ac="$(lva)"
        case "${ac}" in
                "👀  WATCH") vp "${ac}" "${vt}" "${cn}" ;;
                "📥  DOWNLOAD") vp "${ac}" "${vt}" "${cn}" && n "Download finished" ;;
                "🗑️  DELETE") sed -i "/${vt}/d" "${cld}/${ln}" ;;
                *) return ;;
        esac
}
vp() {
        ac="${1}"
        vt="${2}"
        cn="${3}"
        vu="$(vu "${cn}" "${vt}")"
        case "${ac}" in
                "👀  WATCH") mpv --ytdl-format="bestvideo[height<=1440]+bestaudio" "${vu}" ;;
                "📥  DOWNLOAD")
                        cdd="${yd}/${cn}"
                        mkdir -p "${cdd}"
                        yt-dlp -o "${cdd}/%(title)s.%(ext)s" "${vu}"
                        n "Download finished"
                        ;;
        esac
}
gav() {
        so="${1}"
        avf="${dd}/all_videos.tsv"
        sv "${avf}" "${so}"
}
bac() {
        while vt="$(gav | d "Videos | Sort: @@s{v,d}")"; do
                [ "${vt}" ] || break
                [ "${vt}" = "@@sv" ] || [ "${vt}" = "@@sd" ] && {
                        vt=$(gav "${vt}" | d "Videos")
                        [ "${vt}" ] || continue
                }
                rg -lF "${vt}" "${dd}"/*.tsv | head -n "1" | while read -r "vf"; do
                        vam "${vt}" "$(basename "${vf}" .tsv)"
                        break
                done
        done
}
cm() {
        while true; do
                c="$(hck -Ld '=' -f1 "${cl}" | d "Categories")"
                [ "${c}" ] || return
                chm "${c}"
        done
}
chm() {
        c="${1}"
        IFS="|"
        ch="$(sed -n "s/^${c}=\(.*\)$/\1/p" "${cl}")"
        set -- ${ch}
        while true; do
                cn="$(pr "${@}" | d "Channels")"
                [ "${cn}" ] || return
                vm "${cn}"
        done
}
vm() {
        cn="${1}"
        while true; do
                vt=$(gv "${cn}" | d "Videos")
                [ "${vt}" ] || return
                [ "${vt}" = "@@sv" ] || [ "${vt}" = "@@sd" ] && {
                        so="${vt}"
                        vt="$(gv "${cn}" "${so}" | d "Videos")"
                }
                vam "${vt}" "${cn}"
        done
}
vam() {
        vt="${1}"
        cn="${2}"
        while [ "${vt}" ] && [ "${vt}" != "@@sv" ] && [ "${vt}" != "@@sd" ]; do
                ac="$(ma)"
                case "${ac}" in
                        "👀  WATCH") vp "${ac}" "${vt}" "${cn}" ;;
                        "📥  DOWNLOAD") vp "${ac}" "${vt}" "${cn}" && n "Download finished" ;;
                        "➡️  SEND TO A LIST")
                                ln="$(fd -t "f" . "${cld}" -x basename | d "Lists")"
                                [ "${ln}" ] && atl "${vt}" "${cn}" "${ln}" && n "${vt} > list: ${ln}"
                                ;;
                        *) return ;;
                esac
        done
}
mm() {
        pr "🌐  ALL CHANNELS" "🎭  CATEGORIES" "🔀  CUSTOM LISTS" \
                "$(hck -Ld "=" -f1 "${chl}")" | d "YouTube"
}
while true; do
        mc="$(mm)"
        case "${mc}" in
                "🌐  ALL CHANNELS") bac ;;
                "🎭  CATEGORIES") cm ;;
                "🔀  CUSTOM LISTS") clm ;;
                "") exit ;;
                *) vm "${mc}" ;;
        esac
done
