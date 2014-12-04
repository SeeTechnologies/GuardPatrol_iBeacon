//
//  STIAppDelegate.m
//  GuardTourDemo
//
//  Created by LS on 2014-07-16.
//  Copyright (c) 2014 Seetechnologies Inc. All rights reserved.
//

#import "STIAppDelegate.h"
#import "STIBeacon.h"
#import "STIBeaconController.h"

@implementation STIAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;

    // the following UUID is the UUID for some, if not all, of the current Roximity iBeacons. If using a different brand of dedicated iBeacons replace this UUID with one appropriate to your devices
    NSUUID *beaconRoximityUUID = [[NSUUID alloc] initWithUUIDString:@"8DEEFBB9-F738-4297-8040-96668BB44281"];
    CLBeaconRegion *beaconRoximityRegion = [[CLBeaconRegion alloc] initWithProximityUUID:beaconRoximityUUID identifier:@"beaconRoximity"];
    
//    [self.locationManager startMonitoringForRegion:beaconRoximityRegion];
    [self.locationManager startRangingBeaconsInRegion:beaconRoximityRegion];

    // the following UUID is one of the default UUIDs in the AirLocate sample app
    NSUUID *beaconAppleUUID = [[NSUUID alloc] initWithUUIDString:@"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"];
    CLBeaconRegion *beaconAppleRegion = [[CLBeaconRegion alloc] initWithProximityUUID:beaconAppleUUID identifier:@"beaconApple"];
    
//    [self.locationManager startMonitoringForRegion:beaconAppleRegion];
    [self.locationManager startRangingBeaconsInRegion:beaconAppleRegion];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *beacons = [STIBeaconController returnAllBeacons];
    
    if ([beacons count] == 0)
    {
        // demo app simplification - would normally load this data from a web service so it can be updated remotely
        STIBeacon *demoBeacon1 = [[STIBeacon alloc] initWithBeaconId:@"1" nearMessage:@"Use key #42 to unlock" immediateMessage:@"Relock after exiting" farMessage:@"Continue along front yard sidewalk" name:@"Front Door"];
        demoBeacon1.type = @"entryway";
//        // comment out one of the 2 following beacons if you only have 2 total beacons or add more beacons if you have more. Edit the beaconIds to match the minor identifiers on each of your different beacons. Note that this data is persisted in Core Data on first launch of the app. If you update this data after installing on a device you will need to delete the Guard Patrol app from your device and re-install the app
        STIBeacon *demoBeacon2 = [[STIBeacon alloc] initWithBeaconId:@"4494" nearMessage:@"Behind books on middle shelf" immediateMessage:@"Confirmed locked" farMessage:@"At end of main floor hallway" name:@"Study - Safe"];
        STIBeacon *demoBeacon3 = [[STIBeacon alloc] initWithBeaconId:@"6" nearMessage:@"Mounted on outside wall" immediateMessage:@"Confirmed not stolen" farMessage:@"Next to front entryway" name:@"Living Room - 85 in. TV"];

        [[DataManager sharedInstance] save];
        
        [defaults setBool:YES forKey:UD_FIRST_LAUNCH];
    }
    else
    {
        [defaults setBool:NO forKey:UD_FIRST_LAUNCH];
    }
    
    return YES;
}

//- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
//{
//    [manager startRangingBeaconsInRegion:(CLBeaconRegion *)region];
//}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
    NSLog(@"Error monitoring beacons for region: %@, Error Msg - %@", region.identifier, error.description);
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    NSMutableArray *beaconsKeys = [[NSMutableArray alloc] initWithCapacity:beacons.count];
    
    for (CLBeacon *rangedBeacon in beacons)
    {
        NSString *proximityString = nil;
        
        [beaconsKeys addObject:[rangedBeacon.minor stringValue]];
        
        switch (rangedBeacon.proximity)
        {
            case CLProximityFar:
                proximityString = @"Far";
                break;
            case CLProximityNear:
                proximityString = @"Near";
                break;
            case CLProximityImmediate:
                proximityString = @"Immediate";
                break;
            default:
                proximityString = @"Unknown";
                break;
        }
        
        NSLog(@"Ranged beacon: UUID - %@, Major - %@, Minor - %@, Proximity - %@", rangedBeacon.proximityUUID.description, [rangedBeacon.major stringValue], [rangedBeacon.minor stringValue], proximityString);
    }
    
    NSNotification *rangedBeaconsNote = [[NSNotification alloc] initWithName:@"beaconsRanged" object:self userInfo:[NSDictionary dictionaryWithObjects:beacons forKeys:beaconsKeys]];
    [[NSNotificationCenter defaultCenter] postNotification:rangedBeaconsNote];
}

- (void)locationManager:(CLLocationManager *)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error
{
    NSLog(@"Error ranging beacons for region: %@, Error Msg - %@", region.identifier, error.description);
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
