#!/usr/bin/env bash

if [ "$1" = "--umbrella" ] || [ "$1" = "-u" ]
then
  while true; do
    inotifywait -e modify,move,create,delete apps/ && mix test --include integration
  done
else
  while true; do
    inotifywait -e modify,move,create,delete lib/ test/ && mix test --include integration
  done
fi

