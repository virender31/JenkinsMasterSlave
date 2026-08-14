#!/bin/bash
set -e
echo "===================================="
echo " TEST STAGE - Running on $(hostname)"
echo "===================================="
if [ -f build/artifact.txt ]; then
    echo "Artifact received via stash/unstash:"
    cat build/artifact.txt
    echo "PASS: sample_test_1"
    echo "PASS: sample_test_2"
    echo "All tests passed."
else
    echo "ERROR: No artifact found. Did the Build stage stash it correctly?"
    exit 1
fi
