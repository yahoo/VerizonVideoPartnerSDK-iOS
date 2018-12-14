# Oath Video Partner SDK - For iOS and tvOS

> A native iOS SDK that makes it easy to play and monetize videos from the Oath O2 video platform.

<p>
    <a href="https://github.com/Carthage/Carthage">
        <img src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat" alt="Carthage Compatible" />
    </a>
    <img src="https://img.shields.io/badge/Swift-4.0-orange.svg" alt="Swift 4" />
    <a href="https://raw.githubusercontent.com/OathAdPlatforms/OathVideoPartnerSDK-iOS/master/LICENSE">
        <img src="https://img.shields.io/badge/license-MIT-blue.svg?style=flat" alt="MIT LICENSE" />
    </a>
</p>

The Oath Video Partner SDK (OVPSDK or SDK) is a native iOS SDK for playing and monetizing videos from the Oath O2 video platform in apps. The OVPSDK is written in Swift and is delivered by source files that can be included in an app either via CocoaPods or Carthage. Currently, the Swift Package Manager not supported on iOS or tvOS.

The OVPSDK also handles video ads (pre-roll, mid-roll, and post-roll) and provides performance analytics. These analytics provide details about what is played, how long it is played (e.g., deciles, quartiles), and details about the actual device or network it's played on. For more details about supported analytics, or to access analytics data, you'll need to work with the [Video Support Team](mailto:video.support@oath.com) to build reports that focus on the specific details of your app’s video and ads performance.

The SDK includes a complete video player control UX, that includes a limited, albeit robust, set of customization options. The controls implementation is fully open source, and the SDK architecture allows for you to include your own fully customized controls UX, should you not be interested in the built-in default.

## Table of Contents

- [Background](#background)
  - [Main Features](#main-sdk-features)
- [Install](#install)
  - [Requirements](#initial-requirements)
  - [App Onboarding](#onboard-your-apps-for-sdk-authentication)
  - [Cocoapods](#cocoapods)
  - [Carthage](#carthage)
- [Usage](#usage)
  - [Architecture](#high-level-architecture-overview)
  - [How the SDK Works](#how-the-sdk-works)
  - [Default Video Player Control UX](#default-video-player-control-ux)
  - [Advertising Info and User Tracking](#advertising-info-and-user-tracking)
- [Contribute](#contribute)
- [License](#license)

## Background

The Oath Video Partner SDK is used to natively play O2 videos. If you have a native app, you should use the SDK because it provides all ads and analytics for free which can be extremely important for monetization and tracking the performance and usage of videos and ads, improving your understanding of user habits.

There are several technical advantages to using the native OVPSDK over a web player-based solution. This document won't go into detail, but here are some of the advantages:
* Improved performance
* Mobile network awareness
* Frugal memory, thread, and device resource usage
* Better security when comparing to webviews or embedded browsers, some platforms like Apple TV don’t have webviews
* Fine-grained controls with fewer limits
* More customization options

### Main SDK Features
* Playback of one or more individual videos or a single playlist of videos
* Video playback of VOD (video on demand), 360°, and LIVE streaming video types
* Supports either mp4 or m3u8 (HLS) formats
* Video ads (VAST support of both mp4 and vpaid ads)
* Prerolls and midrolls support
* Tap an ad to access the ad destination URL via an in-app-browser
* Full video and ads analytics
* Default video player control UX
* HLS support for multiple closed captioning (CC) and SAP audio languages
* Mute/Unmute support
* Automatic filtering of geo-restricted videos (Automatically done on micro-service backend)
* Complete apps control of the frame where videos play
* Native iOS Picture-in-Picture support
* Apple AirPlay support

## Install

### Initial Requirements
* Xcode 9.3+
* Swift 4.1 (use in Obj-C projects is also possible by writing wrapper around Swift framework)
* CocoaPods or Carthage
* Mobile device running iOS 9 or later or AppleTV device running tvOS 9 or later
* Account in the O2 Portal, and access to Oath-ingested video content
* Onboarded application bundle ID

### Onboard your Apps for SDK Authentication
For the OVPSDK to authenticate itself for video playback within your app, the containing app’s unique App Store bundle identifier is passed to Oath's back end service. You need to email the [Video Support Team](mailto:video.support@oath.com) to register your app bundle IDs to use OVPSDK. You can also register multiple bundled IDs against your same app entity. You might need to do this if you need to allow for a dev/test app bundle ID or an enterprise bundle ID that co-exists on a device alongside your production app. Also, both iOS and Android app bundle IDs can either be the same or different – for the same app. Registration not only authenticates your application, but it ensures your backend video and ads analytics are all configured properly. In addition, this registration information also defines the video content your app is allowed to play through the SDK.


### Cocoapods

You can install the OathVideoPartnerSDK using CocoaPod. 
To do this, add OathVideoPartnerSDK for your target in your Podfile:

```ruby
target 'Target-Name' do
    pod 'OathVideoPartnerSDK'
end
```
After that, open terminal in a folder with it and execute command: 

```bash
pod install
```
### Carthage

To use Carthage, all you need is to add this repository in your Cartfile as:
```bash
github "OathAdPlatforms/OathVideoPartnerSDK-iOS"
```

And then you have to execute command:
```bash
carthage update 
```

## Usage

## High-Level Architecture Overview
The high-level OVPSDK architecture is composed of the following components:
* SDK Core
* Player Core
* A set of Video Renderers that are built-in (e.g., flat 2D and RYOT 360°) with the possibility to use external renderers (e.g., Verizon Envrmnt 360°, custom, etc.)
* O2 VRM (video rights management) VAST Ads Engine
* Content and Ads Video Analytics module
* Default video player control UX implementation

Our modular approach makes it easy to add new renderers in the future, or to add your own custom video player control UX implementation. Under the hood, we rely on the built-in iOS [`AVPlayer`](https://developer.apple.com/documentation/avfoundation/avplayer) to handle the actual video playback. Remember, that new renderers have to be registered on our micro-service. Reach [Video Support Team](mailto:video.support@oath.com) to start this process.

You can visit our [tutorials](OathVideoPartnerSDK-Tutorials) to see examples of how to integrate our SDK and how to customize player for your app.

## How the SDK works
At a very basic level, the OVPSDK controls only the video frame. Because of this, you are completely in control of your app’s design and UX (look and feel). You can control whether videos play in a small view, in-place over a thumbnail image, or at full-screen. Your app also has complete control over device rotation, use of view/navigation controllers, scrollers, and any transitions between them. The SDK does not dictate any overall visual design or behavior on your app.

However, if you choose to use the SDK’s built-in player control UX implementation it will impose it's video player control UX. All control rendering is also done within the frame that's provided for the video. Regardless of which controls UX you use, we currently do not allow any customization or overriding of the ads playback UX (which is different from the normal video playback UX), so that visual interface is dictated, and you cannot override it. Future customization options are planned here.

To play a video, follow these very basic steps:
1. Initialize an instance of the OneSDK
2. Using OneSDK initialize a new `Player` object with a video ID/IDs or playlist ID
3. Set `Player` to the `PlayerViewController`
4. Set `Controls` to the `PlayerViewController`
5. Show `PlayerViewController`!

**That’s it!**

Behind the scenes, the initialization of an instance of the SDK takes your app’s bundle ID, and passes it to our back-end micro services where it's authenticated for video playback within the O2 video platform. Then, the server returns all necessary playback and authentication information, down to that instance of the SDK, for use during its lifespan. When you construct a new `Player` object from that SDK instance, it communicates with our micro services to obtain all the necessary video metadata (e.g., thumbnails and video URLs, duration, etc.). This `Player` object will play and replay the associated video until deinitialized.

More specifically, before a video plays, the SDK’s Ads Engine tries to fulfill a pre-roll ad. While the request for the ad is being processed, the video begins buffering in the background. If an ad is returned in a reasonable amount of time, the `Player` plays the ad using the built-in ads UX. When the ad finishes, the video playback begins. If no ad is to be shown, or the ad request times out, the video playback begins directly.

The runtime circumstances and algorithm for getting an ad or not, are not in the scope of this documentation. Suffice to say, there are many considerations to this (e.g., content owner/seller rules, geolocation, frequency capping, etc.). For more information and details on how ads are served to the OVPSDK, please email the [Video Support Team](mailto:video.support@oath.com).

**Note**: The SDK only operates with an active network connection,you will not be able to do anything without it.

## Default Video Player Control UX

|Portrait|Landscape|
|--------|---------|
|<img width="300" alt="screen shot 2017-12-21 at 9 06 35 pm" src="https://user-images.githubusercontent.com/16276892/34273124-5943e9de-e693-11e7-90dd-d5d2fc2a2f65.png">|<img width="300" alt="screen shot 2017-12-21 at 9 06 41 pm" src="https://user-images.githubusercontent.com/16276892/34273126-595cdb24-e693-11e7-8bc7-5f95683ec676.png">|

The default player control UX contains the following elements:
* Play/Pause/Replay button (with loading animation)
* ± 10 second skip buttons
* Previous and Next buttons
* Seekbar
* Video title
* Elapsed time
* Video duration
* LIVE indicator
* 360° View Orientation Compass / Orientation Reset button
* Closed Captioning/SAP Settings button
* Picture-in-Picture (PiP) button
* AirPlay button
* 4 app-custom sidebar buttons

It also includes some gestures to interact with player:

| Controls hide/show gesture|
|---------------------------|
|<img width="650" alt="show-hide-anim" src="https://user-images.githubusercontent.com/31652265/40317058-ec57c4a0-5d28-11e8-9f5c-535c48f17a3b.gif">|

|Content full-screen gesture|
|---------------------------|
|<img width="650" alt="show-hide-anim" src="https://user-images.githubusercontent.com/31652265/40316727-e4ff0228-5d27-11e8-8cb4-14df42c4447f.gif">|

This video control implementation allows a few runtime customizations that can be set on a player-by-player basis. This includes the ability to:
* Set the tint color for the controls (to match your app’s brand)
* Hide various elements of the controls (useful for smaller view versus full-screen playback)
* Set any of the 4 app-custom sidebar buttons

The built-in tint color of the default video player control UX is <span style="color:magenta">pink/magenta</span>. This is deliberate for easier development; feel free to change it to match with your app’s specific design or brand. The built-in tint color of the ad’s UX is <span style="color:gold">yellow/gold</span>. This cannot be changed at this time, and we advise that you don’t tint your main controls yellow since that will make it difficult to see. You also shouldn't use black or gray because video contrast will reduce visibility of the controls. However, white is generally a good shade to choose because there is a slightly darkened canvas layered about the video, but below the controls; this helps make white controls more visible. 

The player controls are shown under several well-established circumstances. This includes whenever the video is paused, such as before a video starts (with AutoPlay off) or while buffering, after any video finishes (with AutoPlay off), or after all videos linked to the player finish. They also will display (fade in) on demand whenever a video is tapped. If a video is actively playing, the controls will automatically hide (fade out) after a predetermined number of seconds. At any time the controls are shown, they can be quickly hidden by tapping on the video (not over a button, of course).

The default player control UX implementation includes 4 optional app-specific sidebar buttons. You can set any or all of these to use as you see fit. This was built to allow for app-specific video overlay customization in anticipation for up to 4 new behaviors. Because these 4 sidebar buttons are built right into the default controls UX, they will automatically fade in/out with the rest of the video controls. There is no need to handle any of that logic or attempt to synchronize to the animation timings.

We also think that there should be more gestures that will help users interact with our player. One of these is a double tap gesture. By doing double tap in the empty space of the player, the user will be able to change video gravity from aspect fit to aspect fill. This gesture won't have any conflicts with controls show/hide gesture. 

The complete implementation of the default player control UX is open source and has been provided as an implementation example of this SDK. Feel free to inspect it, copy it, and modify it at will.

The default iOS Controls UI implementation repo can be found here: 
[Oath Video Partner SDK Controls for iOS](https://github.com/OathAdPlatforms/OneMobileSDK-controls-ios)

### Advertising Info and User Tracking
The Oath Video Partner SDK does not track anything that is not related to playing videos or video ads. We use the IDFA (ID for advertisers) value and respect the user's limitations for ad tracking (iOS enforces this anyway). The device geolocation is determined by our backend video servers based on IP address, for the purposes of determining and filtering out content that is geo-restricted by content owners. The SDK does not explicitly use the built-in Location Services APIs, and thus does not require your users to grant access to device location data.

The sample projects are all set up to use the following test-only bundle ID: `com.aol.mobile.one.testapp`

## Contribute

Please refer to [the contributing.md file](Contributing.md) for information about how to get involved. We highly appreciate, welcome, and value all feedback on this documentation or the OVPSDK in any way, shape, or form. If you have any suggestions for corrections, additions, or any further clarity, please don't hesitate to email the [Video Support Team](mailto:video.support@oath.com).

## Maintainers

- [Andrey Moskvin](mailto:andrey.moskvin@oath.com)
- [Roman Tysiachnik](mailto:roman.tysiachnik@oath.com)
- [Vladyslav Anokhin](mailto:vladyslav.anokhin@oath.com)

## License

This project is licensed under the terms of the [MIT](LICENSE-MIT) open source license. Please refer to [LICENSE](LICENSE) for the full terms.

