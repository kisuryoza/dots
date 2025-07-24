#!/usr/bin/env bash

if ! pacman -Q libnetfilter_queue &>/dev/null; then
    doas pacman -S libnetfilter_queue
fi

TMPZ="/tmp/zapret"
[[ -d "$TMPZ" ]] && rm -rf "$TMPZ"

git clone --depth 1 https://github.com/bol-van/zapret "$TMPZ" || exit 1

if [[ -d /opt/zapret ]]; then
    cp -v "/opt/zapret/ipset/zapret-hosts-user.txt" "$TMPZ/ipset/zapret-hosts-user.txt"
    cp -v "/opt/zapret/ipset/zapret-hosts-user-exclude.txt" "$TMPZ/ipset/zapret-hosts-user-exclude.txt"
    nvim -d "$TMPZ"/config.default /opt/zapret/config
    doas rm -rf /opt/zapret/
fi

FILES=(cloudflare.txt youtube.txt discord.txt ipset/zapret-hosts-user.txt ipset/zapret-hosts-user-exclude.txt)
cat <<EOF >"$TMPZ/cloudflare.txt"
173.245.48.0/20
103.21.244.0/22
103.22.200.0/22
103.31.4.0/22
141.101.64.0/18
108.162.192.0/18
190.93.240.0/20
188.114.96.0/20
197.234.240.0/22
198.41.128.0/17
162.158.0.0/15
104.16.0.0/13
104.24.0.0/14
172.64.0.0/13
131.0.72.0/22
EOF

cat <<EOF >"$TMPZ/youtube.txt"
yt3.ggpht.com
yt4.ggpht.com
yt3.googleusercontent.com
googlevideo.com
jnn-pa.googleapis.com
stable.dl2.discordapp.net
wide-youtube.l.google.com
youtube-nocookie.com
youtube-ui.l.google.com
youtube.com
youtubeembeddedplayer.googleapis.com
youtubekids.com
youtubei.googleapis.com
youtu.be
yt-video-upload.l.google.com
ytimg.com
ytimg.l.google.com
frankerfacez.com
ffzap.com
betterttv.net
7tv.app
7tv.io
EOF

cat <<EOF >"$TMPZ/discord.txt"
dis.gd
discord-attachments-uploads-prd.storage.googleapis.com
discord.app
discord.co
discord.com
discord.design
discord.dev
discord.gift
discord.gifts
discord.gg
discord.media
discord.new
discord.store
discord.status
discord-activities.com
discordactivities.com
discordapp.com
discordapp.net
discordcdn.com
discordmerch.com
discordpartygames.com
discordsays.com
discordsez.com
EOF

"$TMPZ"/install_easy.sh

(
    cd /opt/zapret/ || exit 1
    doas chown alex /opt/zapret/config "${FILES[@]}"
)
