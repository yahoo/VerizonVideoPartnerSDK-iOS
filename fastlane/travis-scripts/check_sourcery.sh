# Exit immediately if a command exits with a non-zero status
set -e

# If Sourcery installed, exit with success code
if which sourcery > /dev/null; then
    exit 0
fi

#If Sourcery absent, install via Fastlane
bundle exec fastlane install_sourcery
