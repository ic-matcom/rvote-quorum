#!/bin/bash
set -e

echo '> generate e-voting.pdf.'
pandoc -f markdown+example_lists+link_attributes e-voting.md -o e-voting.pdf --citeproc
echo '> generate e-voting.tex.'
pandoc -f markdown+example_lists+link_attributes e-voting.md -o e-voting.tex --citeproc --standalone

echo '> generate quorum.pdf.'
pandoc -f markdown+example_lists+link_attributes quorum.md -o quorum.pdf --citeproc
echo '> generate quorum.tex.'
pandoc -f markdown+example_lists+link_attributes quorum.md -o quorum.tex --citeproc --standalone