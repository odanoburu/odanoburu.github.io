#!/bin/bash

SCRIPTDIR=$(dirname "$(realpath "$0")")

if [[ "$1" != "" ]]; then
    FORCE="t"
else
    FORCE="nil"
fi

# htmlize is no longer distributed with emacs, so we need to add it
# manually to the load-path; this will break as soon as it is updated
# and the directory name changes, but alas I seldom update this blog
# and it is not cost-effective for me to find a better solution now :)
mkdir -p public/
emacs --batch --no-init-file --no-site-lisp --directory "~/.emacs.d/non-elpa/emacs-htmlize/" --load "$SCRIPTDIR/publish.el" --eval "(org-publish-all $FORCE)"
