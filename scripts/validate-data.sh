#!/bin/bash

NAME_LISTS_DIR_PATH="$(pwd)/name-lists"

# Validate XML structure
grep -Pzo "\n\s*<(/[^>]*)>.*\n\s*<\1>\n" --recursive "${NAME_LISTS_DIR_PATH}" # Double tags
grep -Pzo "\n\s*<([^>]*)>\s*\n\s*</\1>\n" --recursive "${NAME_LISTS_DIR_PATH}" # Empty tags
grep -Pzo "\n\s*</Characters>\n\s*<Characters>\s*\n" --recursive "${NAME_LISTS_DIR_PATH}" # Multiple <Characters> tags
grep -Pzo "\n\s*<Values>\n\s*<Url>" --recursive "${NAME_LISTS_DIR_PATH}" # <Url> inside <Values>

grep -n "<Url>https://github.com" --recursive "${NAME_LISTS_DIR_PATH}" # Non-raw GitHub URLs
