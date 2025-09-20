#!/usr/bin/env bash

if ! pgrep nginx > /dev/null; then
    exit 1
else
    exit 0
fi