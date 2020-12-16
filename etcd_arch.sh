#!/bin/bash

ARCH=`arch`

if [[ "$ARCH" == "x86_64" || "$ARCH" == "amd64" ]]; then
	echo amd64
elif [[ "$ARCH" == "aarch64" || "$ARCH" == "arm64" ]]; then
	echo arm64
else
	exit 1
fi

exit 0

