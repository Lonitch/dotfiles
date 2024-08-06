#!/bin/zsh

current_engine=$(ibus engine)

if [ "$current_engine" = "xkb:us::eng" ]; then
    ibus engine libpinyin
else
    ibus engine xkb:us::eng
fi
