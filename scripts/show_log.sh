#!/bin/sh
xterm -geometry 155x25+0-0 -e tail -f logs/system.log &>/dev/null &
