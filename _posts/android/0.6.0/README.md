# Ustream Player SDK for Android v0.6

## Introduction

The Ustream Player SDK lets you play Ustream live and recorded videos in your native applications. Using the native SDK 
gives you full control over the Player, including a customizable native user interface, callbacks on status changes, 
and many more.
This document describes the basic steps to make a mobile app using the Ustream Player SDK for Android.

## Before you begin

### Account prerequisites

Before going into details, please note that document assumes the following:
*   You have a registered user at [ustream.tv](http://www.ustream.tv/).
*   Your Ustream user is entitled to use the Ustream Player SDK specifically. Log-in to [Dashboard], 
and check ["API/SDK access"] under the "Account" section. 
If you have questions, please [contact us](https://www.ustream.tv/enterprise-video/contact).

### Development prerequisites

#### IDE

We recommend using Android Studio v2.0.0 (or newer) for development.

#### Build system

The Player SDK uses the Gradle build system, and it is deployed as an AAR file. The sample application also uses Gradle, 
you can build it using the provided gradle wrapper: `gradlew`

#### Android API level

The supported minimum API level is 16 (Android version 4.1)

## Development process

### Step 1: Create credentials for your mobile app

The SDK requires the use of a **Ustream Player SDK key**, which is validated whenever the SDK communicates with Ustream 
streaming servers. The sample application contains a sample SDK key which you can use for testing. The sample SDK key 
can only be used to play content on the test channel(s) also used in the sample app.

Before you can download and start using the _Ustream Player SDK for Android_ for playing content from your own channel(s), you will need 
to register the **Key Hash** of every app in which you will integrate the _Ustream Player SDK for Android_ at Ustream. 
Every registered application will have its own _Ustream Player SDK key_. Although there is a provided SDK key for the sample 
app's sample content, you still need to register your **Key Hash** at Ustream. This will ensure that you can build the sample 
project using your own certificates.
Every time you initialize an instance of the Ustream Player SDK you have to use your **Ustream Player SDK key**.

#### Generate your Key Hash

There are two types of certificates that your application can be signed with. 
Each certificate generates a different **Key Hash**.

*   The **debug key** is used for development and testing (debug build).
*   The **release key** is used to sign your app when you release it to the Google Play Store (release build). 


There are two ways to generate your **Key Hash**:
* In your Android app:

    Execute this in a debug build **and** a in a release build too:

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
under the "Account" menu.

* In the "Mobile Player SDK" section, click on "Create new credentials" and provide a name for your application in the 
"Application name" field. Your credentials will be listed under the ["API/SDK access"] page based on this name.

* Select Android in the "Platform" drop-down. Enter your **Key Hash** and **Google Play Package Name** in the respective fields.

* After you completed all fields, hit "Save" to generate your Ustream Player SDK for Android credentials. Make sure that 
the "Key Hash" and "Google Play Package Name" are introduced correctly, as you will have no possibility to update them later. 
If you accidentally saved wrong values, start the process from the beginning and create new credentials with the correct 
values.

### Step 2: Download SDK package

After hitting "Save" in the "Create new credentials" step, you will see your credentials listed with the newly generated
**Ustream Player SDK key**.

Click to the "Android Player SDK" link near the "Download" to download the zip archive containing the SDK package.

### Step 3: Explore the SDK package

The provided zip archive contains the sample Android application project for Ustream Player SDK for Android. The sample 
application uses the Player SDK as an AAR file found in the `/libs` folder in the archive.

### Step 4: Create (or open) your project

Open the project that you would like to integrate the Ustream Player SDK in.

### Step 5: Add the SDK to the project

Import from local repo: copy the AAR file to the `libs` folder of your project. In your project's `build.gradle` put the Player SDK
dependency:

```
repositories {
    flatDir {
        dirs 'libs'
    }
}

dependencies {
    compile "joda-time:joda-time:2.5"
    compile "tv.ustream.player:ustream-player-android:0.5.1@aar"
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

In your Fragment's `onCreateView()` or Activity's `onCreate()` get the player instance from the playerView:

```java
final PlayerView playerView = (PlayerView)findViewById(R.id.playerview);
IUstreamPlayer ustreamPlayer = playerView.getUstreamPlayer();
```

The `tv.ustream.player.api.IUstreamPlayer` class is the point where you can interface with the Player SDK. Its methods send 
events to the player, and its states are observed through the listeners (see below). The `IUstreamPlayer`'s methods are 
explained further in its _Javadoc_.

### Step 7: Play live or recorded content

After the `ustreamPlayer` is created, initialize it with a content. This will most likely be in your 
Activity's `onCreate()` (Fragment's `onCreateView()`). A player instance can be initialized more than once with different 
content, but `connect()` or `play()` has to be called in order to reconnect to the servers. The `connect()` method is 
optional (a `play()` or `pause()` call will also handle it implicitly) though the player will respond to `play()` calls 
more quickly because it is already connected to Ustream's servers.

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
    ustreamPlayer.initWithContent(USTREAM_PLAYER_SDK_KEY, contentDescriptor);

    /**
    If the password (or birthday) is known in advance (and it is known to be required)
    it can be supplied here, for example:
    ustreamPlayer.setPassword("super-secret");
    */
    ustreamPlayer.connect();
}
```

Remember to define a string constant `USTREAM_PLAYER_SDK_KEY` with your actual **Ustream Player SDK key**.

Ustream Player SDK version 0.5.0 introduced changes in the user facing interface, see the [CHANGELOG.md] for details.

#### Setting your listeners

To receive state changes and other events from the player you need to set listeners. There are mandatory and optional ones, 
but all of these listeners have to be set prior to calling `ustreamPlayer.attach()` on your player instance. This should 
happen in the `onResume()` callback of your Activity or Fragment. Calling `attach()` is an important step, this is where 
your listeners and the player view is bound to the Player SDK. Forgetting to call this will cause the player to not render 
video on your view, and you will not receive any callback on your listeners.

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
    ustreamPlayer.attach();
}
```

You also need to call `ustreamPlayer.detach()` in your Activity's or Fragment's `onPause()` callback, so your views can 
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
    ustreamPlayer.initWithContent(USTREAM_PLAYER_SDK_KEY, nextContent);
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

There are seven different listeners that you can add to the Player SDK instance to receive callbacks. Some of these 
listeners are mandatory, others are optional, but each listener represents a group of functionality of the Player SDK.

The seven listeners are:

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
    * Note: in this state, the player is still connected to Ustream's servers,
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

```
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
    * The provided Ustream Player SDK key is invalid or this key is not authorized to
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

An optional listener to observe track changes in the player (audio, video, ).

* `onMediaTracksChanged(MediaTrackGroupHolder mediaTrackGroups)`
        - called when the tracks become available or change during playback.
* `onVideoTrackSelectionChanged(@Nullable MediaTrackSelection trackSelection)`
        - called when the selected video track is changed
* `onAudioTrackSelectionChanged(@Nullable MediaTrackSelection trackSelection)`
        - called when the selected audio track is changed
* `onTextTrackSelectionChanged(@Nullable MediaTrackSelection trackSelection)`
        - called when the selected subtitle (closed caption) track is changed
* `onVideoFormatChanged(MediaFormat videoFormat)`
        - called when the video format of the selected video track is changed

The track selection can be controlled with following methods of `IUstreamPlayer`:
* `selectTrackForRenderer(MediaTrack mediaTrack, @Nullable int[] selectedFormatIndices)`
        - selects the supplied media track on the appropriate renderer.
        The Formats identified with the `selectedFormatIndices`'s values will take part in the selection.
        The latter parameter can be used to filter specific format for the selection, e.g. HD only.
* `selectDefaultTrack(MediaTrack.TrackType trackType)`
        - Commands the appropriate renderer for the provided TrackType to switch to the default mediaTrack.
* `disableRenderer(MediaTrack.TrackType trackType)`
        - Commands the appropriate renderer for the provided TrackType to disable rendering.

For more details see javadoc in `MediaTrackChangeListener` and `IUstreamPlayer` classes.

#### Interactive callbacks

There are certain callbacks in `PlayerListener` that indicate a disconnect from Ustream's servers. These callback methods 
represent the reason for the disconnect. Some of these errors can be resolved by you or the user of your application.

These callbacks are found in `tv.ustream.player.api.ErrorListener`:

```java

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
* The requested content can not be accessed due to restrictions.
*/
void onRestricted();

/**
* The provided Ustream Player SDK key is invalid or this key is not authorized to access this content.
*/
void onInvalidApiKey();

/**
* The broadcaster's viewer hours are spent. Receiving this callback means that Your clients will not be able to
* watch your streams at the moment.
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

```

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

*   `onInvalidApiKey()` – The provided Ustream Player SDK key is not authorized to play this content. You need to create a 
new Player SDK instance to provide the correct key. The key needs to be set upon init: 
`ustreamPlayer.initWithContent(USTREAM_PLAYER_SDK_KEY, contentDescriptor);`

*   `onNoSuchContent()` – The requested live channel or recorded video does not exist.

*   `onContentNotPlayable()` – The requested recorded video is not available in a playable format.

*   `onRestricted()` – There are security restrictions set for the channel, that does not enable the Player SDK to play 
this content, or your channel has reached its maximum concurrent viewer number. The latter can be resolved by retrying 
later, to resolve the former the channel's settings have to be modified.

## Customizing the Player UI

#### The appearance of the Player is fully customizable. The provided sample application contains an example appearance with resources.

See `/src/main/res/layout/layout_video.xml` in the sample app.

## Localization

Localization is totally up to you, but there is an example in the `strings.xml` file of the sample application, 
containing the most likely needed strings.

## Changelog

See the [CHANGELOG.md] for changes.

[Dashboard]: https://www.ustream.tv/dashboard
["API/SDK access"]: https://www.ustream.tv/dashboard/account/api-access
[CHANGELOG.md]: CHANGELOG