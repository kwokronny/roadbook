#!/bin/bash
JWT_SERCET=$(tr -cd '[:alnum:]' < /dev/urandom | head -c 32)
echo $JWT_SERCET > storage/jwt.pub