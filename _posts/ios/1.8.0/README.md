# Ustream Player SDK for iOS v1.8.0

## Introduction

The Ustream Player SDK lets you play Ustream live and recorded videos in your native applications. Using the native SDK gives you full control over the Player, including a customizable native user interface, callbacks on status changes, and many more.

This document describes the basic steps to make a mobile app using the Player SDK for iOS.

## Before you begin

### Account prerequisites

Before going into details, please note that document assumes the following:
*   You have a registered user at [video.ibm.com](https://video.ibm.com/).
*   Your Ustream user is entitled to use the Ustream Player SDK specifically. Log-in to [Dashboard],
and check ["API/SDK access"] under the "Integrations & Apps" section.

If you have questions, please [contact us](https://video.ibm.com/enterprise-video/contact).

### Development prerequisites

#### IDE

We recommend using the most recent version of Xcode.

#### Minimum OS version

The Player SDK requires iOS 8.0 or above.

## Development process

### Step 1: Create credentials for your mobile app

Log-in to your account, navigate to the [Dashboard] and select ["API/SDK access"]
under the "Integrations & Apps" menu.

Click on "Create new credentials" and provide a name for your application in the "Application name" field. Your credentials will be listed under the "API/SDK access" page based on this name.

Select iOS in the "Platform" drop-down. Enter the "bundle id" in its respective field.

After you completed all fields, hit "Save" to generate your SDK credentials. Make sure that the "bundle id" is introduced correctly, as you will have no possibility to update them later. If you
accidentally saved wrong values, start the process from the beginning and create new credentials with the correct values.

### Step 2: Download SDK package

After hitting "Save" in the "Create new credentials" step, you will see your credentials listed.

The created credentials entry will have a "Download iOS Player SDK" button at the bottom, click it to download the SDK package.

### Step 3: Explore the SDK package

The provided zip archive contains the binary framework and a sample application.

### Step 4: Create (or open) your project

Open the project that you would like to integrate the SDK in.

### Step 5: Add the SDK to the project

#### Add the framework

Drag IBMVideoPlayerSDK.xcframework into the Embedded Binaries section of your target.

### Step 6: Register your app at IBM

The SDK requires the use of an IBM Player SDK key, which is validated whenever the SDK communicates with IBM's streaming servers.
The sample application contains a sample SDK key which you can use for testing. The sample SDK key can only be
used to play content on the test channel(s) that are used in the sample app.

Note: Although there is a provided SDK key for the sample app's sample content, you still need to register your identifier at IBM.

Before you can start using the Player SDK for playing content from your own channel(s), you will need to:

*   Get a valid **IBM Player SDK key** belonging to the Account that owns the content you would like to play.
*   Register the **bundle identifier(s)** of every app in which you will integrate the IBM Player SDK in.

The application identifier is typically structured as `com.company.project`.

Before you can create and use an instance of the player you have to configure the lib with your IBM Player SDK key:

##### Objective-C
```objc
[USUstreamPlayer configureWithApiKey:<#place your SDK key here#>];
```

##### Swift
```swift
USUstreamPlayer.configure(withApiKey:<#place your SDK key here#>)
```

### Step 7: Create a Player

`USUstreamPlayer` can be instantiated in the usual way. The created player object is a subclass of the `USUstreamPlayer` optimized for the targeted device (iPhone or iPad).

##### Objective-C
```objc
@import iOSPlayerSDK;

self.ustreamPlayer = [[USUstreamPlayer alloc] init];
self.ustreamPlayer.delegate = self;
self.ustreamPlayer.view.frame = self.view.bounds;
[self.view addSubview:self.ustreamPlayer.view];
```

##### Swift
```swift
import iOSPlayerSDK

self.ustreamPlayer = USUstreamPlayer()
self.ustreamPlayer.delegate = self
self.ustreamPlayer.view.frame = self.view.bounds
self.view.addSubview(self.ustreamPlayer.view)
```

### Step 8: Play live or recorded content

By now you have configured your player and it is ready to stream video content through IBM's services.

`USUstreamPlayer` can play different kinds of media:
- Live streams
- Recorded videos

For example, to watch the live video playing on your channel:

##### Objective-C
```objc
self.mediaDescriptor = [USMediaDescriptor channelDescriptorWithID:<#place your channel ID here#>];
[self.ustreamPlayer playMedia:self.mediaDescriptor];
```

##### Swift
```swift
self.mediaDescriptor = USMediaDescriptor.channelDescriptor(withID:<#place your channel ID here#>)
self.ustreamPlayer.playMedia(self.mediaDescriptor)
```

### Step 9: Handle Player callbacks

Content owners can control access to their media using various "locks" that implement password protection, age restriction and other protections. Streaming servers reject clients trying to connect whenever lock conditions are not met. The SDK calls the appropriate callback function to indicate this to the application.

#### Generic callbacks

`USUstreamPlayer` reports its state changes using the `USPlayerDelegate` protocol. Some callbacks may also require user interaction in case the servers notify the Player about content restrictions. For example when "lock" conditions are not met.

In order to receive these callbacks, you need to define a handler conforming to protocol `USPlayerDelegate` and set it as a delegate of your player instance.

##### Objective-C
```objc
self.ustreamPlayer.delegate = self;
```

##### Swift
```swift
self.ustreamPlayer.delegate = self
```

##### Player state is changed

The player instance reports its state changes so that application states can be updated accordingly. For example, your app can change the layout of the player screen depending on whether playback is in progress.

The most important callback indicating such change is the `playerStateDidChange:`, which reports the state of the Player. The states are listed in the `USPlayerState` enum.

#### Interactive callbacks

Callbacks listed below are "interactive", this means they can be used to reconnect for playback after some kind of user input.

##### Password lock

When the Player sends the callback: `playerRequiresPassword:` it waits for a password belonging to the locked content. You can provide the password using `continueWithPassword:`
When you provide the password, the server validates it and starts playing the content if the password is valid. Otherwise it calls back again with `playerRequiresPassword:`.

##### Age lock

When the Player sends either callback `playerRequiresAgeConfirmation:ageRequired:` or `playerRequiresBirthdate:` you need to ask the user's birth date without hints to the required age. If the user-specified age is not less than the required age, you can continue the playback with `continueWithAgeConfirmed`.

##### Hash lock

Implementing custom viewer authentication flow is possible using the [Viewer Authentication API](https://developers.video.ibm.com/channel-api/viewer-authentication-api.html). If the channel or video is set up with custom viewer authentication, the player sends the callback `playerRequiresHash:` where the application should present the custom authentication flow for the user. For more information on implementing the flow please refer to the [Viewer Authentication API documentation](https://developers.video.ibm.com/channel-api/viewer-authentication-api.html).
Once the authentication flow is finished, `USUstreamPlayer` `continueWithHash:` should be called with the resulting `hash` object of the authentication flow. If the provided `hash` object is validated the player gains access to the restricted resource and starts playing it back.

## Customizing the Player UI

`USUstreamPlayer` includes a full-featured user interface by default, including a control bar, loading and error views. You can change this behavior by setting the `playerControlStyle` property of the player. By setting it to `USPlayerControlStyleNone` you can instruct the player to display media only, without any decoration views.

In case you don’t want to handle all the player states and error cases manually, you can also reconfigure the control bars by setting their content using the `USUstreamPlayer (USToolbar)` category.

You can set any of the player toolbar’s contents using the `-[USToolbar setToolbarItems:animated:]` API. The standard toolbar items are accessible in the `USUstreamPlayer (USToolbar)` category Of course you can create your own items as well by subclassing `USToolbarItem`.

## Pre-buffering

`USPrebufferingController` provides an API allowing the buffering of content ahead of time, to support near instantaneous playback starts.
If you provide a content list to be prepared for playback before it is actually required to be started, you will likely get a player prepared to start the playback instantly once it is actually needed by the user of your app.

Usage:
1. Create a content list in priority order as soon as possible. For example if the application contains a list of videos then the priority order may be determined based on the distance of the video cell from the screen centre. The list must contain `USMediaDescriptor` objects.

2. Enqueue the content list for preparation using the `enqueueForPlaybackPreparation:` method.

3. Update the list whenever it is needed by calling `enqueueForPlaybackPreparation:` with a new list. For example when the user is scrolling up/down in the list.

4. Request a `USUstreamPlayer` for a media using `playerForMedia:` when the user is initiating a playback, eg. when a video is selected.

5. Present the requested player.

Remarks:
- The content list can be updated freely anytime, it won't trigger re-buffering on an existing player.
- The provided player is owned by the caller, it may be used as any other player created with `[[USUstreamPlayer alloc] init]` for example.
- If the caller releases the player its resources will be reused for the other enqueued content.
- If a content was not enqueued but a player is requested for it then the user will get a cold player which will start in buffering state, but it is a completely valid usage.
- If it is appropriate then call `cancelPlaybackPreparations` to release system resources.
- If `playerForMedia:` is called multiple times with the same `USMediaDescriptor` it will return the same player instance. You should create a different `USMediaDescriptor` object for each occurrences in order to get different players for them.

## Background audio
`USUstreamPlayer` can be configured for background playback, meaning that if the app goes to background the audio will continue to play.
To enable the feature: change your application's "Background Mode" to _Audio, AirPlay, and Picture in Picture_ (select your project file, select "Capabilities" tab, open "Background Mode", and select "Audio, AirPlay, and Picture in Picture").
Please note that this feature needs to be enabled per `USUstreamPlayer` instance, by setting the `continuePlaybackInBackground` property to `YES`. To configure the Control Center and Lock Screen audio control widget please refer to "Background Player" sample in our _Sample App_.

## DFP Integration
The SDK supports serving ads with Google's DoubleClick for Publishers (DFP) service.

Follow these steps to set it up:
1. Add Google IMA SDK for iOS to the project either by CocoaPods or manually as it is described in [IMA SDK's developer documentation](https://developers.google.com/interactive-media-ads/docs/sdks/ios/).
2. Generate Google IMA tag on [DFP Dashboard](https://www.google.com/dfp/) under Inventory/units.
3. Create a `USUstreamPlayer` instance.
4. Configure ad serving using `configureAdServiceWithGoogleIMATag:customMetadata:minAdFreeTimeInterval:allowPreroll:` or `configureAdServiceWithGoogleIMATag:customMetadata:cuePoints:allowPreroll:`.


## Localization

The SDK by default provides all texts in English only.
If you want to support other languages and/or redefine texts, add the keys listed below into the localization files of your application. If you don’t redefine these keys, then the SDK will fall back to the localizations included in the resource bundle of the SDK.

| Keys                                  | English values                                                                       |
| ------------------------------------- | ------------------------------------------------------------------------------------ |
| USPlayer.content.status.offline       | This channel is off-air.
| USPlayer.content.status.realizing     | Initializing...
| USPlayer.content.status.unrealized    | Loading failed, please try again.
| USPlayer.content.status.unrealized    | Loading failed, please try again.
| USPlayer.content.lock.ageLock         | This content is age-restricted.
| USPlayer.content.lock.birthdateLock   | This content is age-restricted. Please provide your birthdate.
| USPlayer.content.lock.geoLimitLock    | Too many viewers in your area.
| USPlayer.content.lock.geoLock         | This content is not available in your area.
| USPlayer.content.lock.hashLock        | This content is not supported in the mobile apps. Please use a browser for watching.
| USPlayer.content.lock.IPLock          | This content is not available in your network.
| USPlayer.content.lock.passwordLock    | This content is password-protected.
| USPlayer.content.lock.refererLock     | Viewer limit exceeded.
| USPlayer.content.lock.unknownLock     | This content is not supported.
| USPlayer.content.error.update         | Sorry, something went wrong. Please try again.
| USPlayer.content.error.connect        | Connection error. Please try again.
| USPlayer.content.error.unsuported     | Unsupported content.
| USPlayer.content.error.deleted        | This video has been removed by the owner.
| USPlayer.content.error.inexistent     | This content is inaccessible. Try again later.
| USPlayer.content.error.unknown        | Sorry, something went wrong. Please try again.
| USPlayer.content.error.authentication | Invalid password.
| USPlayer.content.error.timeout        | Loading timeout, please try again.
| USPlayer.player.external.title        | AirPlay
| USPlayer.player.external.message      | This video is playing on "Apple TV".
| USPlayer.player.audioOnly             | Playing audio only...
| USPlayer.player.status.buffering      | Buffering...
| USPlayer.control.viewerCount          | %d viewers
| USPlayer.player.started.justNow       | Started just now
| USPlayer.player.started.years         | Started years ago
| USPlayer.player.started.months        | Started months ago
| USPlayer.player.started.weeks         | Started weeks ago
| USPlayer.player.started.days          | Started days ago
| USPlayer.player.started.hours         | Started %dh %dm ago
| USPlayer.player.started.minutes       | Started %dm ago
| USPlayer.player.status.finished       | finished
| USPlayer.content.error.age            | Age unconfirmed or too young user

## Changelog

See the [CHANGELOG.md] for changes.

[Dashboard]: https://www.ustream.tv/dashboard
["API/SDK access"]: https://www.ustream.tv/dashboard/integrations/api-access
[CHANGELOG.md]: CHANGELOG
