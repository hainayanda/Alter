#!/bin/bash

set -eo pipefail

xcodebuild -workspace Example/Alter.xcworkspace \
            -scheme Alter-Example \
            -destination platform=iOS\ Simulator,OS=13.3,name=iPhone\ 11 \
            clean test | xcpretty
