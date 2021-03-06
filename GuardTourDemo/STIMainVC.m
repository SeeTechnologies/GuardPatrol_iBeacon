//
//  STIMainVC.m
//  GuardTourDemo
//
//  Created by LS on 2014-07-20.
//  Copyright (c) 2014 Seetechnologies Inc. All rights reserved.
//

#import "STIMainVC.h"

@interface STIMainVC ()

@end

@implementation STIMainVC 

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    STIAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.beaconsDelegate = self;
    
    [appDelegate initiateBeaconsDetection];
}

- (void)didStartBeaconsDetection
{
    NSTimer *transitionTimer = [NSTimer timerWithTimeInterval:3 target:self selector:@selector(startObservingRangedBeacons) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:transitionTimer forMode:NSDefaultRunLoopMode];
}

- (void)startObservingRangedBeacons
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedStatusNotification:) name:@"beaconsRanged" object:nil];
}

-(void) receivedStatusNotification:(NSNotification *) notification
{
    NSDictionary *rangedBeaconsDictionary = notification.userInfo;
    
    if ([rangedBeaconsDictionary count] > 0)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"beaconsRanged" object:nil];
        [self performSegueWithIdentifier:@"Arriving" sender:self];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    // Get the new view controller using [segue destinationViewController].
//    // Pass the selected object to the new view controller.
//}


@end
