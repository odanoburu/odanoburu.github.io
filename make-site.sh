#!/bin/bash

SCRIPTDIR=$(dirname "$(realpath "$0")")

if [[ "$1" != "" ]]; then
    FORCE="t"
else
    FORCE="nil"
fi

emacs --batch --no-init-file --load "$SCRIPTDIR/publish.el" --eval "(org-publish-all $FORCE)"
