#!/bin/sh
set -e

git archive HEAD . --format=zip -o "$1.zip"

# adding pdf and updating class file so changes in cite style are reflected
zip -r "$1.zip" Thesis.pdf uhthesis.cls  