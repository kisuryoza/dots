#!/usr/bin/env bash

ADDONS=(
    4103048 # uBlock Origin
    4116879 # LocalCDN
    4064884 # ClearURLs
    4072586 # Simple Translate
    4095037 # Dark Reader
    4116106 # LibRedirect
    4094956 # Country Flags & IP Whois
    3059971 # Image Search Options
    # 3917876 # Pixiv Toolkit
    3954396 # Catppuccin-mocha-red
)
DEST="/tmp/firefox-extension"

for addon in "${ADDONS[@]}"; do
    wget https://addons.mozilla.org/firefox/downloads/file/"$addon"

    unzip -qo "$addon" -d "$DEST"
    id=$(jq -r '.applications.gecko.id' "$DEST/manifest.json")
    if [[ "$id" == "null" ]]; then
        id=$(jq -r '.browser_specific_settings.gecko.id' "$DEST/manifest.json")
    fi
    mv "$addon" "$id.xpi"
done

rm -r "$DEST"
