#!/usr/bin/env bash

set -e

ALIVE_FILE=/tmp/staying_alive
INACTIVE_FILE=/tmp/idlecheck

SESSION_COUNT=$(who | grep -v tmux -c || true)

# Check how many non-tmux sessions there are
if [ "$SESSION_COUNT" -eq 0 ]; then
  # There are no active sessions. Check if this instance
  # shoud be left untouched.
  if [ -f "$ALIVE_FILE" ]; then
    exit 0
  fi

  # This check runs on a schedule. It is possible that
  # it became idle just before the check. We create
  # a check file on the first detection, but only act
  # on the second detection.
  if [ -f "$INACTIVE_FILE" ]; then
    sudo shutdown -h 0
  else
    touch $INACTIVE_FILE
  fi
else
  # Unconditionally remove the check file
  rm -rf $INACTIVE_FILE
fi
