# How to start using Oath Video Partner SDK

## Integrate SDK with your project

You can integrate SDK in your project in several ways.

1. Cocoapods - look on Podfile example in this repository.
2. Carthage - look on Cartfile example in this repository.
3. Binary - grab packed framework directly from this repo

## Creating an `OVPSDK` object

TL;DR:
```swift
let sdk = OVPSDK.Provider.default.getSDK()
```

`OVPSDK` is a factory of `Player`s which share common settings and configurations.
But `OVPSDK` itself need to be configured properly.
`OVPSDK` should be initialized via config (`OVPSDK.Configuration`) which can be received from web service.

To do so you need to request `OVPSDK` future from an `OVPSDK.Provider`

### OVPSDK.Provider

This class is responsible for giving you a future to setted up OVPSDK object.
You can use devault provider (will work for most cases) or customize it. Do to so:
```swift
var provider = OVPSDK.Provider.default
provider.context.extra = ["site-section": "cars"]

let sdk = provider.getSDK()
```
Note: Contents of `extra` field is `JSON` aka `[String: Any]`
so you need provide something that can be eaten up by `JSONSerialization` object.

### OVPSDK.Context

Each `OVPSDK.Provider` instance contains `context` field which is used to match application and settings on web service.
In `default` provider we use current application context: `OVPSDK.Context.current`.

This context is completed with values available in your application plist, device information, etc.

`extra` portion of context is empty by default, however, you can pass any JSON compatible dictionary here.
Content of this dictionary will be treated by web service in app specific way.

### OVPSDK.Configuration

`OVPSDK.Provider` have another method `func getConfiguration() -> Future<Result<OVPSDK.Configuration>>`.

While preferred way to construct an `OVPSDK` is a provider, `OVPSDK` contains initializer with `Configuration` object.
You can use it when you want to alter recommended settings. For example:
```swift
func patch(config: OVPSDK.Configuration) -> OVPSDK.Configuration {
  var config = config
  config.features.isHLSEnabled = false
  return config
}

let sdk = provider.getConfiguration()
  .map(patch)
  .map(OVPSDK.init)
```

### Note
Content of `OVPSDK.Configuration` will change from version to version
as we are going to more and more web oriented (and resilent!) solution.
Please, expect code to not be stable.

### Example of player construction:

```swift
OVPSDK.Provider.default.getSDK().then {
    $0.getPlayer(videoID:"your_video_id")
    }.onComplete { player in
        // Result<Player> is ready to be used.
}
```
