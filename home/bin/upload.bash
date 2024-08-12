#!/usr/bin/env bash

if [ "$1" = "" ]; then
    printf "No arguments specified."
    printf "Usage:"
    printf "upload.bash <file|directory>"
    printf "... | transfer <file_name>"
    return 1
fi

if ! tty -s; then
    # curl --upload-file "-" "https://transfer.sh/$1"
    return
fi

file="$1"
file_name=$(basename "$file")

if [ ! -e "$file" ]; then
    echo "$file: No such file or directory" >&2
    return 1
fi

cat <<EOF
1 - 1h
2 - 12h
3 - 24h
4 - 72h
EOF
read -rp "Time: " answer
TIME=0
case "$answer" in
"1") TIME="1h" ;;
"2") TIME="12h" ;;
"3") TIME="24h" ;;
"4") TIME="72h" ;;
*) exit 1 ;;
esac

if [ -d "$file" ]; then
    output="/tmp/$file_name.7z"
    if [ -r "$output" ]; then
        rm "$output"
    fi

    7z a -mx9 "$output" "$file"
    # curl --upload-file "$output" "https://transfer.sh/$file_name.7z"
    curl --request POST -F "reqtype=fileupload" -F "time=$TIME" -F "fileToUpload=@$file_name.7z" https://litterbox.catbox.moe/resources/internals/api.php <"$output"
    rm "$output"
else
    # curl --upload-file "$file" "https://transfer.sh/$file_name"
    curl --request POST -F "reqtype=fileupload" -F "time=$TIME" -F "fileToUpload=@$file_name" https://litterbox.catbox.moe/resources/internals/api.php <"$file"
fi
