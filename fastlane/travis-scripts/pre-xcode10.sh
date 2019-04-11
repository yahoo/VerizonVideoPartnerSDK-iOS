#!/bin/bash
set -e

export IOS_SIMULATOR_UDID=`instruments -s devices | grep "iPhone 8 (12.2" | awk -F '[ ]' '{print $4}' | awk -F '[\[]' '{print $2}' | sed 's/.$//'`
xcrun simctl boot $IOS_SIMULATOR_UDID
