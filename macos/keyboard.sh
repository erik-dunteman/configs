#!/usr/bin/env bash
# macOS keyboard tuning. Run once, then log out/in (or reboot) for all of it to take.
set -euo pipefail

# Key repeat rate. Each unit is ~15ms; the UI slider stops at 2 (fastest),
# but fractional values are honored. 2.5 -> ~37ms, a touch slower than fastest.
#   InitialKeyRepeat=15 -> ~225ms before the first repeat
defaults write -g KeyRepeat -float 2.5
defaults write -g InitialKeyRepeat -int 15

# Disable the press-and-hold accent popup so holding a key actually repeats.
# NOTE: currently UNSET on Erik's machine — enable if the built-in laptop
# keyboard shows the accent menu instead of repeating.
# (The Oryx/ZSA external board handles repeat in firmware, so this only
# affects the built-in keyboard.)
defaults write -g ApplePressAndHold -bool false

echo "Done. Log out and back in for the changes to fully apply."
