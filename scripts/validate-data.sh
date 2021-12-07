#!/bin/bash

# Validate XML structure
grep -Pzo "\n\s*<(/[^>]*)>.*\n\s*<\1>\n" name-lists/*/**.xml # Double tags
grep -Pzo "\n\s*<([^>]*)>\s*\n\s*</\1>\n" name-lists/*/**.xml # Empty tags
