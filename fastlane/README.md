fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew cask install fastlane`

# Available Actions
### clean
```
fastlane clean
```

### build
```
fastlane build
```

### build_tvos_target
```
fastlane build_tvos_target
```

### update_dependencies
```
fastlane update_dependencies
```

### archive
```
fastlane archive
```

### test
```
fastlane test
```

### is_latest_video_renderer
```
fastlane is_latest_video_renderer
```

### release_description
```
fastlane release_description
```

### travis_prerelease_sdk
```
fastlane travis_prerelease_sdk
```

### prerelease_sdk
```
fastlane prerelease_sdk
```
Make pre-release of VerizonVideoPartnerSDK
### release_sdk
```
fastlane release_sdk
```
Release current SDK version and bump project to provided version
### install_sourcery
```
fastlane install_sourcery
```
Install Sourcery
### run_sourcery
```
fastlane run_sourcery
```
Run Sourcery with params: sources, templates, output
### lint_current_podspec
```
fastlane lint_current_podspec
```

### build_tutorials
```
fastlane build_tutorials
```


----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
