#!/bin/zsh
# use this script if you prefer ibus
current_engine=$(ibus engine)

if [ "$current_engine" = "xkb:us::eng" ]; then
    ibus engine libpinyin
else
    ibus engine xkb:us::eng
fi
