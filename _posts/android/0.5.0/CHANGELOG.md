# Changelog

## [0.7.0] - 2017-05-15
### Changed
- Joda-Time dependency has been removed from the sample application (was added in [0.5.0])

## [0.6.0] - 2017-04-19
### Added
- Track selection API:
    - Ability to manage subtitles, audio, video tracks
    - Ability to select specific video formats (resolution, bitrate)
	- Track selection example in the sample application
	- Default subtitles are selected and displayed by default

## [0.5.1] - 2017-03-01
### Changed
- Sample application dependencies changed: Joda-Time added.
- Player SDK deployment moved from local Maven repo to AAR file. We are switching to the simple AAR file deploy until
a proper artifact repository is available.
- Bug fixes and stability improvements

### Removed
- Removed Joda-Time dependency from the user facing interface for greater flexibility. Though Joda-Time is still used
inside the Player SDK for now, therefore it must be included as a dependency.

## [0.4.0] - 2016-05-31
### Added
- Added `IUstreamPlayer.isInitialized()` method to check whether the player is already initialized. This is most useful
on a configuration change event. The information representing the init state of the player does not need to be manually
saved anymore.

### Changed
- Tweaks around `IUstreamPlayer.destroy()`. This is not bound to Android lifecycle anymore, can be called anywhere
after initialization.
- Bugfixes and stability improvements

[0.7.0]: ../0.7.0/
[0.6.0]: ../0.6.0/
[0.5.1]: ../0.5.0/
[0.4.0]: ../0.4.0/
