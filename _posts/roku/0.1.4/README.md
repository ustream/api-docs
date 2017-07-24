# Ustream Player SDK for Roku v0.1.4

## Introduction

The IBM Cloud Video Player SDK lets you play IBM Cloud Video live and recorded videos in your native applications. Using the SDK gives you full control over the embedded Player, including a customizable native user interface, callbacks on status changes, and many more.

This document describes the basic steps to make a Roku app using the Player SDK.

## Before you begin

### Account prerequisites

Before going into details, please note that document assumes the following:

*   you have a registered user at [IBM Cloud Video](http://www.ustream.tv)
*   your IBM Cloud Video user is entitled to use the Player SDK specifically (if you have questions, please [contact us](https://www.ustream.tv/enterprise-video/contact))

### Development prerequisites

The use of **Eclipse** is recommended for editing BrightScript code. Roku provides an Eclipse Plugin to facilitate development.

For information on how to install the plugin please follow instructions on the Roku [Eclipse Plugin Guide](https://sdkdocs.roku.com/display/sdkdoc/Roku+Plugin+for+Eclipse+IDE).

## Step 1: Explore the SDK package

Your package contains two subfolders under **roku/src/main/brightscript/tv/ustream/roku**:

*   **api**: this folder contains the SDK itself
*   **sampleapplication**: this folder contains a sample application showcasing the use of the SDK

## Step 2: Add the SDK to your application

Copy the **api** folder of the SDK package into your application. Make sure your application has its own `Main()` function.

The `Main()` function of the **sampleapplication** folder can be found in the **UstreamSampleApplication.brs** file.

## Step 3: Register your app at IBM Cloud Video

The SDK requires the use of a _IBM Cloud Video API key_, which is validated whenever the SDK communicates with IBM Cloud Video streaming servers. The sample application contains a sample API key which you can use for testing. The sample API key can only be used to play content on the test channel(s) also used in the sample app.

Before you can start using the Player SDK for playing content from your own channel(s), you will need to:

*   get a valid **IBM Cloud Video API key** owned by the IBM Cloud Video user that owns the content you would like to play
*   register the **application identifier(s)** - of every app in which you will integrate the Player SDK in - at IBM Cloud Video

The application identifier is typically structured as _com.your_company.your_project_.

Before you can create and use an instance of the player you have to configure the lib with your **IBM Cloud Video API key**:

*   Replace **your_api_key** to your actual **IBM Cloud Video API key**.
*   Replace **your_application_bundle** to your actual application identifier.

```
    Function Main()
        init(“your_api_key”,”your_application_bundle”)
    end Function
```

## Step 4: Play live or recorded content

You can intiate playback of live or recorded content using the `playChannel` or `playRecorded` method.

Starting playback of a IBM Cloud Video channel:

```javascript
    Function Main()
        init(“your_api_key”,”your_application_bundle”)
        playChannel("channel_id")
    end Function
```

Starting playback of a IBM Cloud Video recorded video:

```javascript
    Function Main()
        init(“your_api_key”,”your_application_bundle”)
        playRecorded("video_id")
    end Function
```

The `playChannel` and `playRecorded` methods need to be called using String parameters, even though content IDs are typically numbers. For example: `playChannel("11378037")`

## Step 5: Handle Player callbacks

IBM Cloud Video content owners can protect their content using various "locks" that implement password protection, age restriction and other limitations. Streaming servers reject clients connecting for playback if lock conditions are not met. The SDK calls the appropriate callback function to indicate this to the application.

### Generic callbacks

#### Non-interactive locks

The following callbacks notify the app that playback has stopped due to a server-side "reject", and lets the app act on the reason of the reject.

| **Callback**                                   | **Reason**                                                                                                       | **Value to return** |
|------------------------------------------------|------------------------------------------------------------------------------------------------------------------|---------------------|
| **playerSdkLockHandle(playerSdkModule,error)** | API key verification error, please [double check](#step-3-register-your-app-at-ibm-cloud-video_6) your API key and application id registered at Ustream. | error code as int   |
| **geoLockHandle(geoLockModule,error)**         | Content is restricted and unavailable at the viewer’s geographical location.                                     | error code as Int   |
| **ipLockHandle(ipLockModule,error)**           | Content is restricted and unavailable from the viewer’s IP address.                                              | error code as Int   |

Sample code is located for each of these callbacks in the **Utils.brs** file of the **sampleapplication** folder.

#### Other errors

The following callbacks are designed to notify the app about playback issues that are not related to content restriction.

| **Callback**                | **Reason**                                                                                      | **Value to return** |
|-----------------------------|-------------------------------------------------------------------------------------------------|---------------------|
| **requestFailed()**         | Communication has failed between the SDK and IBM Cloud Video servers.                           | error code as Int   |
| **channelOffline()**        | The channel to be played is currently off-air, there is no live broadcast taking place.         | error code as Int   |
| **recordedVideoNonExist()** | The recorded video to be played can not be found. It may have been deleted.                     | error code as Int   |
| **privateVideo()**          | The recorded video to be played is not available because it has been made private by the owner. | error code as Int   |
| **formatNotSupported()**    | The recorded video to be played is not available in a format that is compatible with Roku.      | error code as Int   |

Sample code is located for each of these callbacks in the **Utils.brs** file of the **sampleapplication** folder.

### Interactive callbacks

The following locks notify the app that playback has stopped due to a server-side reject, and needs to pass information from a user input when reconnecting.

| **Callback**                        | **Reason**                                                                                                                      | **Value to return**                |
|-------------------------------------|---------------------------------------------------------------------------------------------------------------------------------|------------------------------------|
| **getPassword()**                   | Content is protected with a password. Use this callback to ask the viewer for a password. (see also **incorrectPassword**)      | password as String                 |
| **incorrectPassword()**             | An incorrect password was entered. Use this callback to display an error notification, then **getPassword** gets called again.) | none                               |
| **getAge()**                        | Content is restricted under a certain age. Use this callback to ask the viewer's birth date. (see also **ageHandle**)           | viewer age in years as Int         |
| **ageHandle(ageModule,error)**      | The viewer's age (passed from **getAge**) is lower than the required age. Use this callback to display an error message.        | error code as Int                  |
| **getBirthDay()**                   | Content is restricted under a certain age. Use this callback to ask the viewer's birth date. (see also **birthDayHandle**)      | viewer birth date as "YYYY.MM.DD." |
| **birthDayHandle(ageModule,error)** | The viewer's age (passed from **getBirthDay**) is lower than the required age. Use this callback to display an error message.   | error code as Int                  |

Sample code is located for each of these callbacks in the **Utils.brs**, **PasswordScreen.brs** and **AgeScreen.brs** files of the **sampleapplication** folder.

Empty strings ("") returned from `getPassword` or `getBirthDay` do not get verified, the app returns to the `Main()` function instead.
