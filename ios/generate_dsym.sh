#!/bin/bash

# Script to generate dSYM for objective_c framework
# Run this after archiving if you get dSYM warnings

ARCHIVE_PATH="$1"

if [ -z "$ARCHIVE_PATH" ]; then
    echo "Usage: ./generate_dsym.sh <path_to_xcarchive>"
    exit 1
fi

FRAMEWORK_PATH="$ARCHIVE_PATH/Products/Applications/Runner.app/Frameworks/objective_c.framework/objective_c"

if [ -f "$FRAMEWORK_PATH" ]; then
    echo "Generating dSYM for objective_c framework..."
    dsymutil "$FRAMEWORK_PATH" -o "$ARCHIVE_PATH/dSYMs/objective_c.framework.dSYM"
    echo "dSYM generated successfully!"
else
    echo "Framework not found at: $FRAMEWORK_PATH"
    exit 1
fi
