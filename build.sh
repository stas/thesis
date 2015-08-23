#!/usr/bin/env bash

pandoc \
  --latex-engine=xelatex \
  -H ./tex/settings.tex \
  -V fontsize=11pt \
  -V documentclass:book \
  -V papersize:a4paper \
  -V classoption:twoside \
  --chapters \
  frontmatter/*.md \
  chapters/* \
  endmatter/*.md \
  -o thesis.pdf
