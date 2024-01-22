#!/bin/bash

project_dir="/project"

# Run the gpt engineer script
gpt-engineer $project_dir "$@"

# Patch the permissions of the generated files to be owned by nobody except prompt file
for item in "$project_dir"/*; do
    if [[ "$item" != "$project_dir/prompt" ]]; then
        chown -R gpt-engineer:gpt-engineer "$item"
        chmod -R 755 "$item"
    fi
done

exec "$@"
