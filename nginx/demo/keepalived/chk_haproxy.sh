#!/usr/bin/env bash

curl -sf --max-time 2 http://127.0.0.1:80/healthz > /dev/null
if [ $? -ne 0 ]; then
    exit 1
fi
exit 0