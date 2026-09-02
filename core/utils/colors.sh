#!/usr/bin/env bash

# light colors
BLACK=$'\e[1;30m'
GRAY=$'\e[0;90m'
BLUE=$'\e[1;34m'
GREEN=$'\e[1;32m'
CYAN=$'\e[1;36m'
RED=$'\e[1;31m'
PURPLE=$'\e[1;35m'
YELLOW=$'\e[1;33m'
NC=$'\e[1;37m' # no color or white

# dark colors
D_BLACK=$'\e[0;30m'
D_BLUE=$'\e[0;34m'
D_GREEN=$'\e[0;32m'
D_CYAN=$'\e[0;36m'
D_RED=$'\e[0;31m'
D_PURPLE=$'\e[0;35m'
D_YELLOW=$'\e[0;33m'
D_NC=$'\e[0;37m' # no color or white

# grayscale ramp (diamond banner — 232 near black → 255 near white)
GRAY_0=$'\e[38;5;232m'
GRAY_1=$'\e[38;5;233m'
GRAY_2=$'\e[38;5;234m'
GRAY_3=$'\e[38;5;235m'
GRAY_4=$'\e[38;5;236m'
GRAY_5=$'\e[38;5;237m'
GRAY_6=$'\e[38;5;238m'
GRAY_7=$'\e[38;5;239m'
GRAY_8=$'\e[38;5;240m'
GRAY_9=$'\e[38;5;241m'
GRAY_10=$'\e[38;5;242m'
GRAY_11=$'\e[38;5;243m'
GRAY_12=$'\e[38;5;244m'
GRAY_13=$'\e[38;5;245m'
GRAY_14=$'\e[38;5;246m'
GRAY_15=$'\e[38;5;247m'
GRAY_16=$'\e[38;5;248m'
GRAY_17=$'\e[38;5;249m'
GRAY_18=$'\e[38;5;250m'
GRAY_19=$'\e[38;5;251m'
GRAY_20=$'\e[38;5;252m'
GRAY_21=$'\e[38;5;253m'
GRAY_22=$'\e[38;5;254m'
GRAY_23=$'\e[38;5;255m'

# background colors
BG_BLACK=$(setterm -background black)
BG_BLUE=$(setterm -background blue)
BG_GREEN=$(setterm -background green)
BG_CYAN=$(setterm -background cyan)
BG_RED=$(setterm -background red)
BG_YELLOW=$(setterm -background yellow)
BG_WHITE=$(setterm -background white)
