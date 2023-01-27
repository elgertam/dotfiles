#!/bin/sh

./boot.sh

darwin-rebuild switch --flake .
