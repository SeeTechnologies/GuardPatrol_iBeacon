//
//  STIAppDelegate.h
//  GuardTourDemo
//
//  Created by LS on 2014-07-16.
//  Copyright (c) 2014 Seetechnologies Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@protocol BeaconsDelegate <NSObject>

- (void) didStartBeaconsDetection;

@end

@interface STIAppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>

#define UD_FIRST_LAUNCH @"FirstLaunch"

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (weak) id <BeaconsDelegate> beaconsDelegate;

- (void)initiateBeaconsDetection;

@end
