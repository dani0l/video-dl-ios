#!/bin/sh

echo "This will fetch and/or update the git submodules"

git submodule init && git submodule update
(
    cd python-embedded
    git submodule init && git submodule update
)
