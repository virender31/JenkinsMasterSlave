#!/bin/bash
set -e
echo "===================================="
echo " BUILD STAGE - Running on $(hostname)"
echo "===================================="
mkdir -p build
echo "Build artifact generated at $(date)" > build/artifact.txt
echo "Build complete. Artifact contents:"
cat build/artifact.txt
