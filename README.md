GuardPatrol_iBeacon
===================

Demo app using iBeacons via the iOS CoreLocation framework

Use Case:

- the Guard Patrol app would be used by security guards to confirm their patrols. iBeacons would be placed in various indoor and/or outdoor locations at a property the property owner/manager identified as mandatory patrol checkpoints.


Prerequisites:

- at least 3 iOS devices (optimally 4 or more) with Bluetooth LE support OR
- 1 iOS device with Bluetooth LE support and at least 2 iBeacons (optimally 3 or more)


How To Use This Demo:

- turn on Bluetooth on all your iOS devices
- if using iOS devices as iBeacons download the Apple Developer sample code for AirLocate from https://developer.apple.com/library/ios/samplecode/AirLocate/Introduction/Intro.html#//apple_ref/doc/uid/DTS40013430 
- open the AirLocate project in Xcode and install the app on the iOS devices you will be using as iBeacons
- launch the AirLocate app on each iOS device you will be using as an iBeacon
- press Configuration in AirLocate, update Minor to a different number on each device, and turn the Enabled switch to on (all other settings will be fine to leave as their defaults)
- leave AirLocate running in the foreground on all of these devices
- position these devices at least 5m away from each other
- open GuardTourDemo.xcworkspace (rather than .xcodeproj) in Xcode
- navigate to the -application:didFinishLaunchingWithOptions: method in STIAppDelegate.m
- update beacon UUID’s as needed (see comments in the code for more details)
- update beaconIds with the Minor identifiers of your devices for demoBeacon1 through 3 (see comments in the code for more details)
- install Guard Patrol on an iOS device
- disconnect your device from Xcode
- launch the app at least a few meters away from the iBeacon you configured as the “entryway” (normally demoBeacon1)
- follow the instructions on screen to pass through the “front door” (need to move close enough to trigger this location to turn green)
- follow the instructions on screen to visit all the other patrol locations (need to move close enough to trigger these locations to turn green)
- once all the other patrol locations have been visited leave through the “front door” (need to move close enough to trigger this location to turn green again) to complete the patrol
- to reset the demo and try it again terminate the Guard Patrol app (double-click home button, swipe app screenshot up and off the top of the screen)


Troubleshooting:

- if you see “Checkpoint not active” for one of your beacons it likely means one of the following:
  - if using one or more iOS devices as iBeacons the AirLocate app needs to be running in the foreground. If you have switched to another app, the home screen or the device has auto-locked the device will no longer be broadcasting as an iBeacon. It is a good idea to turn off auto-lock while using this app
  - if using one or more iOS devices as iBeacons the AirLocate app on each device must have Enabled turned on under Configuration
  - if using one or more iOS devices as iBeacons and the AirLocate app has been terminated at some point since you set the Minor identifier to match one of the beacons in STIAppDelegate the Minor identifier will have been reset to 0 and you will need to update it again to match one of the beacons in STIAppDelegate (as described above)
  - if using one or more dedicated iBeacons there may have been a mistake in entering the correct UUID and/or Minor identifier to match one of the beacons in STIAppDelegate
  - if using one or more dedicated iBeacons the internal battery may be drained, try replacing the battery if it is user-serviceable 
- if the initial “Searching for nearby properties” screen displays for more than several seconds:
  - you may be out of range of all of your iBeacons. Move to within 10m of at least one of your iBeacons 
  - the Guard Patrol demo app may not work as expected running on iOS 8. The app has been successfully tested on an iPhone 5 running iOS 7.1.2
  - one of the issues under “Checkpoint not active” above may be affecting one or more of your devices
