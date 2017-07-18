#!/usr/bin/env bash
echo "Killing any testrpc clients..."
killall -s KILL  testrpc
echo "Starting testrpc client with mnemonic..."
testrpc -m "anchor try dismiss dizzy solid feel smoke wife lift pioneer column denial"
echo "testrpc running on http://localhost:8485..."
