#!/bin/bash
JWT_SERCET=$(tr -cd '[:alnum:]' < /dev/urandom | head -c 32)
echo $JWT_SERCET > storage/jwt.pub
echo "window.AMapKey=\"${AMAP_KEY}\"" > views/config.js