#!/bin/bash
set -e

bundle exec fastlane travis_prerelease_sdk branch:$TRAVIS_BRANCH is_pull_request:$TRAVIS_PULL_REQUEST github_api_token:$GITHUB_API_TOKEN podspec_path:"./podspecs/OathVideoPartnerSDK.podspec" swift_version:"4.2"
