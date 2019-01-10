# How to start using Verizon Video Partner SDK

## Integrate SDK with your project

You can integrate SDK in your project using Cocoapods - look on Podfile example in this repository.

## Creating an `VVPSDK` object

TL;DR:
```swift
let sdk = VVPSDK.Provider.default.getSDK()
```

`VVPSDK` is a factory of `Player`s which share common settings and configurations.
But `VVPSDK` itself need to be configured properly.
`VVPSDK` should be initialized via config (`VVPSDK.Configuration`) which can be received from web service.

To do so you need to request `VVPSDK` future from an `VVPSDK.Provider`

### VVPSDK.Provider

This class is responsible for giving you a future to setted up VVPSDK object.
You can use devault provider (will work for most cases) or customize it. Do to so:
```swift
var provider = VVPSDK.Provider.default
provider.context.extra = ["site-section": "cars"]

let sdk = provider.getSDK()
```
Note: Contents of `extra` field is `JSON` aka `[String: Any]`
so you need provide something that can be eaten up by `JSONSerialization` object.

### VVPSDK.Context

Each `VVPSDK.Provider` instance contains `context` field which is used to match application and settings on web service.
In `default` provider we use current application context: `VVPSDK.Context.current`.

This context is completed with values available in your application plist, device information, etc.

`extra` portion of context is empty by default, however, you can pass any JSON compatible dictionary here.
Content of this dictionary will be treated by web service in app specific way.

### VVPSDK.Configuration

`VVPSDK.Provider` have another method `func getConfiguration() -> Future<Result<VVPSDK.Configuration>>`.

While preferred way to construct an `VVPSDK` is a provider, `VVPSDK` contains initializer with `Configuration` object.
You can use it when you want to alter recommended settings. For example:
```swift
func patch(config: VVPSDK.Configuration) -> VVPSDK.Configuration {
  var config = config
  config.features.isHLSEnabled = false
  return config
}

let sdk = provider.getConfiguration()
  .map(patch)
  .map(VVPSDK.init)
```

### Note
Content of `VVPSDK.Configuration` will change from version to version
as we are going to more and more web oriented (and resilent!) solution.
Please, expect code to not be stable.

### Example of player construction:

```swift
VVPSDK.Provider.default.getSDK().then {
    $0.getPlayer(videoID:"your_video_id")
    }.onComplete { player in
        // Result<Player> is ready to be used.
}
```
