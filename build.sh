#!/usr/bin/env bash

pandoc \
  --latex-engine=xelatex \
  -H ./tex/settings.tex \
  -V fontsize=11pt \
  -V documentclass:book \
  -V papersize:a4paper \
  -V classoption:openright \
  -V classoption:twoside \
  --chapters \
  before/*.md \
  chapter_*/* \
  after/*.md \
  -o thesis.pdf
