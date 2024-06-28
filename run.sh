#!/usr/bin/env bash

export ERL_AFLAGS="-kernel shell_history enabled"

echo -e "\n\n\033[1;32m Start Application in console\033[0;0m: \033[1;31m127.0.0.1\033[0;0m:\033[1;35m\033[0;0m\n"

iex -S mix
