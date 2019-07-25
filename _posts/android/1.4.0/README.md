# IBM Video Streaming Player SDK for Android v1.4

## Introduction

The IBM Video Streaming Player SDK lets you play IBM Video Streaming live and recorded videos in your native applications. Using the native SDK 
gives you full control over the Player, including a customizable native user interface, callbacks on status changes, 
and many more.

This document describes the basic steps to make a mobile app using the IBM Video Streaming Player SDK for Android.

## Before you begin

### Account prerequisites

Before going into details, please note that document assumes the following:
*   You have a registered user at [video.ibm.com](https://video.ibm.com/).
*   Your IBM Video Streaming user is entitled to use the IBM Video Streaming Player SDK specifically. Log-in to [Dashboard], 
and check ["API/SDK access"] under the "Integrations & Apps" section.

If you have questions, please [contact us](https://video.ibm.com/enterprise-video/contact).

### Development prerequisites

#### IDE

We recommend using Android Studio v3.4.0 (or newer) for development.

#### Build system

The Player SDK uses the Gradle build system, and it is deployed as an AAR file. The sample application also uses Gradle, 
you can build it using the provided gradle wrapper: `gradlew`

#### Android API level

The supported minimum API level is 16 (Android version 4.1)

## Development process

### Step 1: Create credentials for your mobile app

The SDK requires the use of a **IBM Video Streaming Player SDK key**, which is validated whenever the SDK communicates with IBM Video Streaming 
streaming servers. The sample application contains a sample SDK key which you can use for testing. The sample SDK key 
can only be used to play content on the test channel(s) also used in the sample app.

Before you can download and start using the _IBM Video Streaming Player SDK for Android_ for playing content from your own channel(s), you will need 
to register the **Key Hash** of every app in which you will integrate the _IBM Video Streaming Player SDK for Android_ at IBM Video Streaming. 
Every registered application will have its own _IBM Video Streaming Player SDK key_. Although there is a provided SDK key for the sample 
app's sample content, you still need to register your **Key Hash** at IBM Video Streaming. This will ensure that you can build the sample 
project using your own certificates.
Every time you create an instance of the `UstreamPlayerFactory` you have to use your **IBM Video Streaming Player SDK key**.

#### Generate your Key Hash

There are three types of certificates that your application can be signed with.
Each certificate generates a different **Key Hash**.

*   The **debug key** is used for development and testing (debug build).
*   The **release key** (or App Signing key) is used to sign your app when you release it to the Google Play Store (release build).
*   (Optional) The third type has been recently introduced with **Google Play App Signing**.
Using this feature when you upload your release build to the Play Store Google will sign it again with your true release key.
Therefore you will have to generate key hashes for all three of your keys (Debug key, Upload key, App Signing key - managed by Google).
For more information visit: [Google Play App Signing](https://support.google.com/googleplay/android-developer/answer/7384423)


There are two ways to generate your **Key Hash**:
* In your Android app:

    Execute this in a debug build **and** a in a release build too:
    
    Since version 1.3.0 you can use `tv.ustream.player.android.SignatureUtil.keyHashFromContext(Context)`
    to generate or check your current Key Hash from your application. This method basically executes 
    the following lines without printing to the output:

    ```java
    String packageName = context.getPackageName();
    PackageInfo packageInfo = context.getPackageManager().getPackageInfo(packageName, PackageManager.GET_SIGNATURES);
    byte[] signature = packageInfo.signatures[0].toByteArray();
    MessageDigest messageDigest = MessageDigest.getInstance("SHA");
    String keyHash = Base64.encodeToString(messageDigest.digest(signature), Base64.NO_WRAP);
    System.out.println("Key Hash is: "+keyHash);
    ```

* Using the command line:
 
    - Install OpenSSL for your development platform.
    
    - Locate your `keystore_file` and replace `CERTIFICATION_ALIAS` with your alias below and execute the commands:
 
        ```
        keytool -exportcert -alias CERTIFICATION_ALIAS -keystore /path/to/keystore_file >your_company-debug.key
        openssl dgst -sha1 -binary your_company-debug.key | base64
        ```
        The output of the last command is your **Key Hash**. 
        
        Remember to generate the identifier for your release certificate's public key **and** every other debug certificates 
        that your developers will use.

#### Enter credentials

* Log-in into your account, navigate to the [Dashboard] and select ["API/SDK access"] 
under the "Integrations & Apps" menu.

* In the "Mobile Player SDK" section, click on "Create new credentials" and provide a name for your application in the 
"Application name" field. Your credentials will be listed under the ["API/SDK access"] page based on this name.

* Select Android in the "Platform" drop-down. Enter your **Key Hash** and **Google Play Package Name** in the respective fields.

* After you completed all fields, hit "Save" to generate your IBM Video Streaming Player SDK for Android credentials. Make sure that 
the "Key Hash" and "Google Play Package Name" are introduced correctly.
If you accidentally saved wrong values, you can edit or delete your credentials,
but beware as this will break any existing applications relying on those credentials.

### Step 2: Download SDK package

After hitting "Save" in the "Create new credentials" step, you will see your credentials listed with the newly generated
**IBM Video Streaming Player SDK key**.

Click to the "Android Player SDK" link near the "Download" to download the zip archive containing the SDK package.

### Step 3: Explore the SDK package

The provided zip archive contains the sample Android application project for IBM Video Streaming Player SDK for Android. The sample 
application uses the Player SDK as an AAR dependency found in the `/m2repository` folder in the archive.

### Step 4: Create (or open) your project

Open the project that you would like to integrate the IBM Video Streaming Player SDK in.
Update the `AndroidManifest.xml` of your application with the following permission:

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

### Step 5: Add the SDK to the project

Import from local repo: copy the `m2repository` folder to your project. In your project's `build.gradle` put the Player SDK
dependency:

```gradle
repositories {
    maven {
        name 'IBMLocal'
        url new File("${rootProject.rootDir.path}/m2repository").toURI()
    }
}

dependencies {
    implementation 'tv.ustream.player:ibm-player-sdk-android-external:1.4.0'
}
```

You can find this in the sample application also, just copy those settings.

### Step 6: Create a Player

#### In your layout .xml

Place a `PlayerView` in your layout:

```xml
<tv.ustream.player.android.PlayerView
android:id="@+id/playerview"
android:layout_height="match_parent"
android:layout_width="match_parent" />
```

#### In your Activity or Fragment

Create a `UstreamPlayerFactory` in your Activity or Fragment with the Activity's context:

```java
private final UstreamPlayerFactory ustreamPlayerFactory = new UstreamPlayerFactory(USTREAM_PLAYER_SDK_KEY, context);
```
This factory can be used to create or retrieve IBM Video Streaming Player instances.
IBM Video Streaming Players created for a specific `playerId` will be retained across configuration changes (like orientation change).
Requesting a player with the same `playerId` will create a new UstreamPlayer interface, but that interface will 
belong to the same player instance. The previous player for the same id must be detached before attaching a new one.

In your Fragment's `onCreateView()` or Activity's `onCreate()` find your playerView and get a player instance from the factory:

```java
final PlayerView playerView = (PlayerView)findViewById(R.id.playerview);
UstreamPlayer ustreamPlayer = ustreamPlayerFactory.createUstreamPlayer(playerId);
```
Where `playerId` can be:
- a constant String value if the Activity will only contain **one** player instance.
- a persisted String value for every player instance that the Activity contains. (saved in `onSaveInstanceState()` restored in `onCreate()`)

The `tv.ustream.player.api.UstreamPlayer` class is the point where you can interface with the Player SDK. Its methods send 
events to the player, and its states are observed through the listeners (see below). The `UstreamPlayer`'s methods are 
explained further in its _Javadoc_.

### Step 7: Play live or recorded content

After the `ustreamPlayer` is created, initialize it with a content. This will most likely be in your 
Activity's `onCreate()` (Fragment's `onCreateView()`). A player instance can be initialized more than once with different 
content, but `connect()` or `play()` has to be called in order to reconnect to the servers. The `connect()` method is 
optional (a `play()` or `pause()` call will also handle it implicitly) though the player will respond to `play()` calls 
more quickly because it is already connected to IBM Video Streaming's servers.

First time initialization:

```java
// To play videos, use ContentType.RECORDED and the video id
ContentDescriptor contentDescriptor = new ContentDescriptor(ContentType.RECORDED, 54321);
```

```java
// To play live streams, use ContentType.LIVE and the channel id
ContentDescriptor contentDescriptor = new ContentDescriptor(ContentType.LIVE, 12345);
```

```java
if (!ustreamPlayer.isInitialized()) {
    ustreamPlayer.initWithContent(contentDescriptor);

    /*
    If the password (or birthday) is known in advance (and it is known to be required)
    it can be supplied here, for example:
    ustreamPlayer.setPassword("super-secret");
    */
    ustreamPlayer.connect();
}
```

Remember to define a string constant `USTREAM_PLAYER_SDK_KEY` with your actual **IBM Video Streaming Player SDK key**.

IBM Video Streaming Player SDK version 1.3.0 introduced changes in the user facing interface, see the [CHANGELOG.md] for details.

#### Setting your listeners

To receive state changes and other events from the player you need to set listeners. There are mandatory and optional ones, 
but all of these listeners have to be set prior to calling `ustreamPlayer.attach()` on your player instance. This should 
happen in the `onResume()` or `onStart()` callback of your Activity or Fragment. Calling `attach()` is an important step, this is where 
your listeners and the player view is bound to the Player SDK. Forgetting to call this will cause the player to not render 
video on your view, and you will not receive any callback on your listeners.
Also since version 0.9.0 this is the place to set your `PlayerView` to the IBM Video Streaming player.
The reason behind this is, now you can optionally pre-buffer your player by calling `ustreamPlayer.pause()` without the need to add a `PlayerView`.
PlayerView can be later set, when it is appropriate. For example a news feed like application's `PlayerView`s will be in a `RecyclerView`.

```java
@Override
protected void onResume() {
    super.onResume();
    ustreamPlayer.setPlayerListener(playerListener);
    ustreamPlayer.setErrorListener(errorListener);
    ustreamPlayer.setProgressListener(progressListener);
    ustreamPlayer.setViewerCountListener(viewerCountListener);
    ustreamPlayer.setLogoClickListener(logoClickListener);
    ustreamPlayer.setMetaDataListener(metaDataListener);
    ustreamPlayer.setBufferingListener(bufferingListener);
    ustreamPlayer.setPlayerView(playerView);
    ustreamPlayer.attach();
}
```

You also need to call `ustreamPlayer.detach()` in your Activity's or Fragment's `onPause()` or `onStop()` callback, so your views can 
be recycled properly.

```java
@Override
protected void onPause() {
    ustreamPlayer.detach();
    super.onPause();
}
```

See the next section and the sample application for more details.

#### Changing content

Changing content on an already initialized player (Please note `detach()` and `attach()` have to be called to properly 
reinitialize views):

```java
private void changeContent(ContentDescriptor nextContent) {
    ustreamPlayer.detach();
    ustreamPlayer.initWithContent(nextContent);
    ustreamPlayer.connect();
    ustreamPlayer.attach();
}
```

### Step 8: Handle Player callbacks

#### State flow of the Player SDK

This diagram represents the state flow of the Player SDK, the nodes are the states reported by the player, the named edges 
are events that can be sent to the player. There is a decision in the flow that happens automatically based on the content 
selected (live or recorded).

![State flow diagram](/images/android-state-flow-diagram-0.5.png "State flow diagram")


#### Catching callbacks

There are eight different listeners that you can add to the Player SDK instance to receive callbacks. Some of these 
listeners are mandatory, others are optional, but each listener represents a group of functionality of the Player SDK.

The eight listeners are:

*   PlayerListener **(mandatory)**
*   ErrorListener **(mandatory)**
*   BufferingListener
*   ProgressListener
*   ViewerCountListener
*   LogoClickListener
*   MetaDataListener
*   MediaTrackChangeListener

##### PlayerListener

The `PlayerListener` is the most important listener, this is also a mandatory one, you must provide it, or you will receive 
an exception. The Player SDK's state is observed through this interface.

```java
package tv.ustream.player.api;

/**
* Observes the state of the content playback.
*
* All callbacks represent mutually exclusive states.
*/
public interface PlayerListener {

    /**
    * Called when the player is initialized.
    * This is the initial state, and this is the state the player
    * returns to after re-initialized with a new content.
    * The Player SDK is not connected to the internet in this state.
    */
    void onInitialized();

    /**
    * Called when the player is stopped.
    * This is the state the player returns to after a stop() or disconnect() call.
    * The Player SDK is not connected to the internet in this state.
    */
    void onStopped();
    
    /**
    * The requested live channel is not broadcasting, or the stream is not
    * available in a playable format.
    * Note: in this state, the player is still connected to IBM Video Streaming's servers,
    * waiting for the stream to become online.
    */
    void onWaitingForContent();

    /**
    * Called when everything is ready to play the requested content.
    * Note: At this point buffering of the content did not start yet
    */
    void onContentReady();

    /**
    * Called at playback paused or stopped.
    */
    void onPaused();

    /**
    * Called at playback start or restart.
    */
    void onPlaying();
}
```

##### ErrorListener

This is also a mandatory listener; the Player SDK reports all playback errors here. When an error occurs the SDK will call 
the corresponding callback, then it will return to the Stopped state, notifying the application using 
`PlayerListener.onStopped()`.

```java
package tv.ustream.player.api;

/**
* Observes the errors that can possibly occur in the player.
*
* The callbacks are called when playback is not possible and each callback
* represent a reason for the playback error.
*/
public interface ErrorListener {
    /**
     * The requested recorded video is not available in a playable format.
     */
    void onContentNotPlayable();

    /**
     * The requested live channel or recorded video does not exist.
     */
    void onNoSuchContent();

    /**
     * The requested content requires a password authentication.
     */
    void onPasswordLock();

    /**
     * The requested content is restricted by age.
     */
    void onAgeLock();

    /**
     * The requested content requires a HashLock authentication
     * or the provided Hash is invalid/expired.
     */
    void onHashLock();

    /**
     * The requested content can not be accessed in the current area.
     */
    void onGeoLock();

    /**
     * The requested content can not be accessed due to restrictions.
     */
    void onRestricted();

    /**
     * The provided IBM Video Streaming Player SDK key is invalid or this key is not authorized to
     * access this content.
     */
    void onInvalidApiKey();

    /**
     * The broadcaster's viewer hours are spent. Receiving this callback means
     * that Your clients will not be able to watch your streams at the moment.
     */
    void onViewerHourLimitLock();

    /**
     * Connection error.
     */
    void onConnectionError();

    /**
     * Unknown error.
     */
    void onUnknownError();
}
```

##### BufferingListener

This is an optional listener, notifying the application about buffering starts and stops. The player will resume its 
previous operation when buffering is completed.

```java
package tv.ustream.player.api;

/**
* Observes background network communication's state
*/
public interface BufferingListener {
    
    /**
    * Called when the player does not have enough video frame to continue
    * playing and it is started to download data from the server
    */
    void onBufferingStarted();
    
    /**
    * Called when the player is finished receiving data from the server
    * either if there is sufficient amount of data is received and the
    * playback is continued or an error occurred.
    */
    void onBufferingStopped();
}
```

##### ProgressListener

The `ProgressListener` provides information about the content's duration and progress. This is an optional listener. 
Duration and progress values are in milliseconds.

```java
package tv.ustream.player.api;

public interface ProgressListener {
    void onPositionUpdated(long positionMs);
    void onDurationUpdated(long durationMs);
    void onDurationDisabled();
}
```

##### ViewerCountListener

The `ViewerCountListener` provides information about the content's audience (all-time viewers and current concurrent viewers). 
This is an optional listener.

```java
package tv.ustream.player.api;

/**
* Provides information about the current and total viewer numbers
*/
public interface ViewerCountListener {

    /**
    * Update of current viewer number.
    * @param viewers number of current viewers, display this on your layout
    */
    
    void onCurrentViewersUpdated(long viewers);
    
    /**
    * Current viewers module is disabled, remove the indicator from your
    * layout.
    */
    void onCurrentViewersDisabled();
    
    /**
    * Update of total viewer number.
    * @param totalViewers number of all-time combined viewers, display this on
    * your layout.
    */
    void onTotalViewersUpdated(long totalViewers);
    
    /**
    * Total viewers module is disabled, remove the indicator from your
    * layout.
    */
    void onTotalViewersDisabled();
}
```

##### LogoClickListener

The displayed logo has been clicked, you should open the URL in the callback's parameter. This is an optional listener.

```java
package tv.ustream.player.api;

import java.net.URI;

/**
* Observes the click of the logo of a branded channel.
*/
public interface LogoClickListener {

    /**
    * Called when the logo of the branded channel has been clicked.
    *
    * @param url The url which should be opened on a logo click.
    */
    void onLogoClick(URI url);
    
}
```

##### MetaDataListener

`MetaDataListener` provides updates of the content's meta data, the callback is called when the meta becomes available. 
This is an optional listener.

```java
package tv.ustream.player.api;

/**
* Observes the metaData of the content
*/
public interface MetaDataListener {

    /**
    * Called when the content metadata becomes available
    * (title, category, etc...).
    */
    void onMetaData(MetaData data);
    
    /**
    * Called when the content's conversation settings become available.
    * @param data Holder for the IRC chat and SocialStream settings.
    */
    void onChatAndSocialStreamData(ChatAndSocialStreamData data);
}
```

##### MediaTrackChangeListener

An optional listener to observe track changes in the player (audio, video, text).

* `onMediaTracksChanged(MediaTrackGroupHolder mediaTrackGroups)`
        - called when the tracks become available or change during playback.
* `onVideoTrackSelectionChanged(@Nullable MediaTrackSelection trackSelection)`
        - called when the selected video track is changed
* `onAudioTrackSelectionChanged(@Nullable MediaTrackSelection trackSelection)`
        - called when the selected audio track is changed
* `onTextTrackSelectionChanged(@Nullable MediaTrackSelection trackSelection)`
        - called when the selected text (subtitle / closed caption) track is changed
* `onVideoFormatChanged(MediaFormat videoFormat)`
        - called when the video format of the selected video track is changed

The track selection can be controlled with following methods of `UstreamPlayer`:
* `selectTrackForRenderer(MediaTrack mediaTrack, @Nullable int[] selectedFormatIndices)`
        - selects the supplied media track on the appropriate renderer.
        The Formats identified with the `selectedFormatIndices`'s values will take part in the selection.
        The latter parameter can be used to filter specific format for the selection, e.g. HD only.
* `selectDefaultTrack(MediaTrack.TrackType trackType)`
        - Commands the appropriate renderer for the provided TrackType to switch to the default mediaTrack.
* `disableRenderer(MediaTrack.TrackType trackType)`
        - Commands the appropriate renderer for the provided TrackType to disable rendering.

For more details see javadoc in `MediaTrackChangeListener` and `UstreamPlayer` classes.

#### Interactive callbacks

The `onStopped()` callback in `PlayerListener` indicate a full stop and disconnect from IBM Video Streaming's servers. If the disconnect 
happened due to an error, the appropriate callback of `ErrorListener` indicates the reason.
Some of these errors can be resolved by you or the user of your application.

Errors that can be resolved by user (or developer) interaction:

*   `onPasswordLock()` – Call `ustreamPlayer.setPassword(password);` then restart the playback by `ustreamPlayer.play();`

*   `onAgeLock()` – Call `ustreamPlayer.setBirthDate(date);` then restart the playback by `ustreamPlayer.play();`

*   `onHashLock()` – Call `ustreamPlayer.setHash(hash);` then restart the playback by `ustreamPlayer.play();`

Transient errors:

*   `onConnectionError()` – There is a problem with the internet connection,  
(most likely temporary) try again later by calling: `ustreamPlayer.play();`

*   `onUnknownError()` – This indicates a problem that the Player SDK can't determine, 
(most likely temporary) try again by calling: `ustreamPlayer.play();`

*   `onViewerHourLimitLock()` – The broadcaster's viewer hours are spent. This user can not watch the stream at the moment, 
try again by calling: `ustreamPlayer.play();`

Other errors:

*   `onInvalidApiKey()` – The provided IBM Video Streaming Player SDK key is not authorized to play this content. You need to create a 
new Player SDK Factory instance to provide the correct key. The key needs to be set upon factory creation: 
`new UstreamPlayerFactory(USTREAM_PLAYER_SDK_KEY, context);`

*   `onNoSuchContent()` – The requested live channel or recorded video does not exist.

*   `onContentNotPlayable()` – The requested recorded video is not available in a playable format.

*   `onGeoLock()` – The requested content is not playable in the user's current geo location.

*   `onRestricted()` – There are security restrictions set for the channel, that does not enable the Player SDK to play 
this content, or your channel has reached its maximum concurrent viewer number. The latter can be resolved by retrying 
later, to resolve the former the channel's settings have to be modified.

These callbacks are found in `tv.ustream.player.api.ErrorListener`.

## Changing tracks

Video streams can contain multiple tracks of different types (usually Video, Audio, Text). The player SDK lets you control which of these
tracks are selected and presented to the user. See this document's `MediaTrackChangeListener` section or the corresponding javadoc for
API reference.

### Usage

- Set a `MediaTrackChangeListener` on an initialized player, call `attach()` when appropriate.
- When the player determines the available track groups
it will report it through the listener's `void onMediaTracksChanged(MediaTrackGroupHolder mediaTrackGroups)` callback.
- The `mediaTrackGroups` object holds the available media tracks for each track type. Use these to instruct the player's specific renderers to
play a certain media track. A renderer can also be disabled.

**Example**: Selecting a subtitle / closed captions track

```java
UstreamPlayerFactory ustreamPlayerFactory = new UstreamPlayerFactory(API_KEY, activity);
ContentDescriptor contentDescriptor = new ContentDescriptor(ContentType.RECORDED, 123456L);
UstreamPlayer player = ustreamPlayerFactory.createUstreamPlayer(contentDescriptor.toString());
player.initWithContent(contentDescriptor);
player.setMediaTracksChangeListener(mediaTrackChangeListener);
player.attach();

//... Inside the MediaTrackChangeListener
public void onMediaTracksChanged(MediaTrackGroupHolder mediaTrackGroups) {
    availableTextTracks = trackGroupHolder.textTracks;
    // Update the subtitle selector with the available subtitles
}

//... When the user selects a subtitle track from the selector:
void selectTrack(MediaTrack mediaTrack) {
    ustreamPlayer.selectTrackForRenderer(mediaTracks, null);
}
```

**Example**: Querying whether a `MediaFormat` is supported

```java
//... Inside the MediaTrackChangeListener
public void onMediaTracksChanged(MediaTrackGroupHolder mediaTrackGroups) {
    for (MediaTrack videoTrack : mediaTrackGroups.videoTracks) {
        for (MediaFormat videoFormat : videoTrack.mediaFormats) {
            if (mediaTrackGroups.formatSupportInfo.isSupported(videoFormat)) {
                logSupportedFormat(videoTrack, videoFormat);
            } else {
                logUnsupportedFormat(videoTrack, videoFormat);
            }
        }
    }
}
```

For more detailed and general examples please consult the provided sample app.

## Pre-buffering

UstreamPlayers initialized with `RECORDED` content can be buffered ahead of time.
This way an illusion of instantly starting videos can be achieved.
By the time a player is needed (`PlayerView` is set and `play()` is called) it is likely already in the `Paused` state, and playback can start immediately.
This feature's most obvious use-case is a newsfeed like playback experience, 
when video contents are scrolling into the view and need to be started as soon as possible.

### Usage

- Create a `ustreamPlayer` instance with an id. (The id can be the `contentDescriptors.toString()` value for simplicity, if duplicate contents are not required.)
- Initialize the created player with a **RECORDED** content.
- Call `pause()` on the player. The UstreamPlayer will buffer the content then it will wait.
At this stage it is not required to call `setPlayerListener()`, `setErrorListener()` and `attach()` if the callbacks are not relevant for you.
But you are free to do so if you are interested in the callbacks, but make sure you call `detach()` before changing listeners or playerView on the player,
and call `attach()` again so these changes can take effect.
- Later when the player is needed set your listeners and the `playerView`, call `attach()`
- Call `ustreamPlayer.play()` and if it is buffered the playback will start instantly.

**Example**:

```java
UstreamPlayerFactory ustreamPlayerFactory = new UstreamPlayerFactory(API_KEY, activity);
ContentDescriptor contentDescriptor = new ContentDescriptor(ContentType.RECORDED, 123456L);
UstreamPlayer player1 = ustreamPlayerFactory.createUstreamPlayer(contentDescriptor.toString());
player1.initWithContent(contentDescriptor);
player1.pause();

//... AT A LATER POINT, WHEN THE PLAYER IS NEEDED:

player1.setPlayerListener(playerListener);
player1.setErrorListener(errorListener);
player1.setPlayerView(playerView);
player1.attach();
player1.play();
```

**Note**:
- Only your device capabilities (mostly RAM) limit how many players you can pre-buffer. Keeping too many players can cause an OutOfMemoryError.
- When the players are no longer needed don't forget to `destroy()` them.


## Customizing the Player UI

#### The appearance of the Player is fully customizable. The provided sample application contains an example appearance with resources.

See `/src/main/res/layout/layout_video.xml` in the sample app.

## Localization

Localization is totally up to you, but there is an example in the `strings.xml` file of the sample application, 
containing the most likely needed strings.

## Using plugins in the SDK

IBM Player SDK version 1.1.0 introduced a plugin system which enables you to extend the media player with additional features.
Plugins will be provided by IBM, and must be provided during player initialization in `UstreamPlayer.initWithContent(ContentDescriptor, MediaPlayerModule)`.
These extensions may require different player views than `tv.ustream.player.android.PlayerView`. PlayerView requirements for a plugin will always be stated
in this documentation, but can also be queried from the MediaPlayerModule instance itself using `MediaPlayerModule.getSupportedPlayerViewType()`.
Make sure to always use the appropriate `PlayerView`.

Creation of the plugin is the user's responsibility, use the constructor of the desired plugin, provide appropriate parameters and set listeners.
When a plugin is passed to a UstreamPlayer instance it will be retained across configuration changes, however the listeners the user provided are not subject
to the usual `UstreamPlayer.attach()` / `UstreamPlayer.detach()` working. The user needs to manually set and remove those listeners.
The current `MediaPlayerModule` in use can be retrieved from the player instance using `UstreamPlayer.getMediaPlayerPlugin()` which returns
a `MediaPlayerModule` that will be cast to the appropriate class that was set during `initWithContent`. The user must know which MediaPlayerModule was
 set during init.

Please note that while a `MediaPlayerPlugin` provided through `UstreamPlayer.initWithContent` is retained across configuration changes,
the plugin itself might NOT support configuration changes at all due to plugin specific reasons. This will always be stated in the plugin's documentation
under the **Plugin limitations** section.

### Ads Plugin

IBM Player SDK version 1.1.0 introduced **Ads Plugin** (called `AdsMediaPlayerModuleAndroid`) which can be used to provide ads for the audience using the developer's
*Double Click for Publishers* account.

Supported features:
- Pre-roll video ads
- Mid-roll video ads with multiple configurable scheduling via `AdScheduleRule`s
- Customizable ad parameters via key/value pairs

Ads plugin needs to be instantiated and passed to the `UstreamPlayer` instance via `initWithContent(ContentDescriptor, MediaPlayerModule)`.
Upon plugin creation the user can provide the following configuration data: `String dfpTagUrl`, `AdScheduleRule scheduleRule`,
where `dfpTagUrl` points to the user's *Double Click for Publishers* account and `adScheduleRule` is the class defining when to show ads.
See javadoc for details.

Additionally any time after creation the user can set:
- an `AdStateListener` using `AdsMediaPlayerModuleAndroid.setAdStateListener(AdStateListener)` which notifies the user when an ad is being displayed.
- `AdData` which is targeting metadata for *DFP*. Feel free to use your own meta and/or meta provided by `MetaDataListener.onMetaData(MetaData)`.

#### Example usage
Add the Ads Plugin to your build use same local m2 repostory in project root folder and add these lines to your gradle file (Google IMA SDK is a dependency of the Ads Plugin):

```gradle
implementation 'tv.ustream.player:ibm-player-sdk-android-plugin-ads-external:1.4.0@aar'
implementation 'com.google.ads.interactivemedia.v3:interactivemedia:3.11.3'
implementation 'com.google.android.gms:play-services-ads-identifier:17.0.0'
implementation 'androidx.browser:browser:1.0.0'
```

In `AndroidManifest.xml` set configChanges settings in the player activity as:

```xml
<activity
        android:name="com.my.company.PlayerActivity"
        android:configChanges="orientation|screenSize|keyboardHidden"
        android:label="@string/app_name" />
```

Create a UstreamPlayer as usual, but provide an `AdsMediaPlayerModule` at init:
```java
ustreamPlayer = ustreamPlayerFactory.createUstreamPlayer(playerId);
if (!ustreamPlayer.isInitialized()) {
    final AdScheduleRule scheduleRule = new FixedIntervalRule(true, 60000); // Schedules a pre-roll and inserts mid-rolls after 60 seconds of playback time
    ustreamPlayer.initWithContent(contentDescriptor, new AdsMediaPlayerModuleAndroid(/* AdsStateListener */this, DFP_TAG_URL, scheduleRule));
}
```

In your application's layout file use `tv.ustream.player.android.plugin.ads.AdsPlayerView` (instead of regular `tv.ustream.player.android.PlayerView`).

```xml
<FrameLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:background="@android:color/black">

    <tv.ustream.player.android.plugin.ads.AdsPlayerView
        android:id="@+id/playerview"
        android:layout_height="match_parent"
        android:layout_width="match_parent"
        android:layout_gravity="center"/>

</FrameLayout>
```

Retrieve the plugin after init:

```java
AdsMediaPlayerModuleAndroid mediaPlayerPlugin = ustreamPlayer.getMediaPlayerPlugin();
```

Set an `AdsStateListener` on the plugin:

```java
mediaPlayerPlugin.setAdStateListener(new AdStateListener() {
    @Override
    public void adStarted() {
        // Customize UI elements during ad playback, e.g: hide seekbar
        seekBar.setVisibility(View.INVISIBLE);
        muteToggleButton.setVisibility(View.INVISIBLE);
        fullScreenToggleButton.setVisibility(View.INVISIBLE);
    }

    @Override
    public void adFinished() {
        // Restore UI elements after ad playback
        seekBar.setVisibility(View.VISIBLE);
        muteToggleButton.setVisibility(View.VISIBLE);
        fullScreenToggleButton.setVisibility(View.VISIBLE);
    }
});
```

Set meta for *DFP* using an `AdData` object:

```java
List<String> adKeywords = Arrays.asList("testKeyword1", "testKeyword2");
Map<String, String> adExtras = new HashMap<>();
adExtras.put("adExtraKey1", "adExtraValue1");
adExtras.put("adExtraKey2", "adExtraValue2");
AdData adData = new AdData("TestTitle", adKeywords, adExtras);
mediaPlayerPlugin.setAdData(adData);
```

Everything else works just like it did before, no other code modification is required.

#### Plugin limitations

- Ads Plugin does not support configuration changes, use `android:configChanges="orientation|screenSize|keyboardHidden"` in your player activity.
This limitations is imposed by Google IMA SDK on which we depend to show ads.
- Ads Plugin uses it's own PlayerView: `tv.ustream.player.android.plugin.ads.AdsPlayerView`
- Seeking while an ad is playing will seek the original content, as ad seeking is not possible

## Security Extension
We recently dropped support of deprecated versions of TLS, and only support TLS 1.2 SSL connection to our services. Older Android versions (below 5.0) do not support TLS 1.2 out of the box, if you are targeting these versions you need to include and configure an extra dependency ([Android Security Provider](https://developer.android.com/training/articles/security-gms-provider.html)):

```gradle
implementation "com.google.android.gms:play-services-base:$actualVersionOfPlayServices"
```

```java
import com.google.android.gms.security.ProviderInstaller;

//...

if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) {
    ProviderInstaller.installIfNeededAsync(context, listener);
}
```


## Changelog

See the [CHANGELOG.md] for changes.

[Dashboard]: https://video.ibm.com/dashboard
["API/SDK access"]: https://video.ibm.com/dashboard/integrations/api-access
[CHANGELOG.md]: CHANGELOG