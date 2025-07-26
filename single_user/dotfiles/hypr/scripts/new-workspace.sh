#!/bin/bash

# Get list of all used workspaces
used_ids=$(hyprctl workspaces -j | jq '.[].id' | sort -n)

# Find the lowest unused workspace ID (starting from 1)
new_id=1
for id in $used_ids; do
  if [ "$new_id" -lt "$id" ]; then
    break
  elif [ "$new_id" -eq "$id" ]; then
    new_id=$((new_id + 1))
  fi
done

# Switch to the new workspace
hyprctl dispatch workspace "$new_id"
