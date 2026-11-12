#!/usr/bin/env bash
if [[ ${1:-} == toggle ]]; then dunstctl set-paused toggle; fi
if [[ $(dunstctl is-paused) == true ]]; then printf '󱏧\n'; else printf '\n'; fi
