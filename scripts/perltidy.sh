#!/bin/sh

echo "Running perltidy..."
find . -name *.t -or -name *.pm -or -name *.pl -exec perltidy {} \;

echo "Deleting *.bak files..."
find . -name *.bak -exec rm -f {} \;

