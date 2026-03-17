#!/bin/bash
for i in {1..6}; do
    i3-msg workspace $i
done
i3-msg workspace 1
