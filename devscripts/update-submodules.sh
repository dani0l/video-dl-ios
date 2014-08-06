#!/bin/sh

echo "This will fetch and/or update the git submodules"

git submodule update --init --recursive
