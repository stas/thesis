#!/usr/bin/env bash

pandoc --latex-engine=xelatex -H ./tex/settings.tex -V fontsize=12pt \
  -V documentclass:book -V papersize:a4paper -V classoption:openright \
  --chapters \
  before/*.md \
  -o thesis.pdf
