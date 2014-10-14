//
//  STIPatrolTVC.m
//  GuardTourDemo
//
//  Created by LS on 2014-07-19.
//  Copyright (c) 2014 Seetechnologies Inc. All rights reserved.
//

#import "STIPatrolTVC.h"
#import "STIBeacon.h"
#import "STIBeaconController.h"
#import "STIAppDelegate.h"
#import <AudioToolbox/AudioToolbox.h>

@interface STIPatrolTVC ()

@end

@implementation STIPatrolTVC

#define BEACON_TYPE_ENTRYWAY @"entryway"

typedef NS_ENUM(NSInteger, STIEntrywayStatus)
{
    STIEntrywayStatusNotVisited,
    STIEntrywayStatusEntered,
    STIEntrywayStatusExited
};

enum STIEntrywayStatus _entrywayStatus = STIEntrywayStatusNotVisited;
int _beaconCheckTotalCount = 0;
SystemSoundID _soundID = 0;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedStatusNotification:) name:@"beaconsRanged" object:nil];
    self.title = @"Wilman Manor";
    [self.navigationItem setHidesBackButton:YES];
    
    NSString *soundPath = [[NSBundle mainBundle]
                            pathForResource:@"roximity" ofType:@"caf"];
    NSURL *soundURL = [NSURL fileURLWithPath:soundPath];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &_soundID);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.activityIndicator stopAnimating];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults boolForKey:UD_FIRST_LAUNCH])
    {
        UIAlertView *helpAlert = [[UIAlertView alloc] initWithTitle:nil message:@"Please start your patrol by entering by the front door." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
        [helpAlert show];
    }
}

-(void) receivedStatusNotification:(NSNotification *) notification
{
    NSDictionary *rangedBeaconsDictionary = notification.userInfo;
    NSArray *propertyBeacons = [STIBeaconController returnAllBeacons];
    
    for (STIBeacon *propertyBeacon in propertyBeacons)
    {
        CLBeacon *rangedBeacon = (CLBeacon *) [rangedBeaconsDictionary objectForKey:propertyBeacon.beaconId];
        
        if (rangedBeacon != nil)
        {
            if ([propertyBeacon isNewProximity:rangedBeacon.proximity])
            {
                // TODO: refactor into new method?
                UIAlertView *helpAlert = [[UIAlertView alloc] initWithTitle:nil message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
                
                if ([propertyBeacon.currentProximityValue intValue] == CLProximityImmediate)
                {
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    BOOL firstAppLaunch = [defaults boolForKey:UD_FIRST_LAUNCH];
                    
                    switch (_entrywayStatus)
                    {
                        case STIEntrywayStatusNotVisited:
                            if ([propertyBeacon.type isEqualToString:BEACON_TYPE_ENTRYWAY])
                            {
                                _entrywayStatus = STIEntrywayStatusEntered;
                                _beaconCheckTotalCount = 1;
                                propertyBeacon.checked = [NSNumber numberWithBool:YES];
                                AudioServicesPlaySystemSound(_soundID);
                                
                                if (firstAppLaunch)
                                {
                                    helpAlert.message = @"Continue your patrol by visiting the other checkpoints in any order.";
                                }
                            }
                            break;
                        case STIEntrywayStatusEntered:
                            if (![propertyBeacon.type isEqualToString:BEACON_TYPE_ENTRYWAY] && _beaconCheckTotalCount < [propertyBeacons count] && !propertyBeacon.checked)
                            {
                                propertyBeacon.checked = [NSNumber numberWithBool:YES];
                                _beaconCheckTotalCount++;
                                AudioServicesPlaySystemSound(_soundID);
                                
                                if (firstAppLaunch && _beaconCheckTotalCount == [propertyBeacons count])
                                {
                                    helpAlert.message = @"Complete your patrol by leaving through the front door.";
                                }
                            }
                            else if ([propertyBeacon.type isEqualToString:BEACON_TYPE_ENTRYWAY] && _beaconCheckTotalCount == [propertyBeacons count])
                            {
                                _entrywayStatus = STIEntrywayStatusExited;
                                AudioServicesPlaySystemSound(_soundID);
                                
                                if (firstAppLaunch)
                                {
                                    helpAlert.message = @"Patrol completed. Please proceed to your next assignment.";
                                }
                            }
                            else if (firstAppLaunch && [propertyBeacon.type isEqualToString:BEACON_TYPE_ENTRYWAY] && _beaconCheckTotalCount > 1 && _beaconCheckTotalCount < [propertyBeacons count])
                            {
                                helpAlert.message = @"You need to visit all the other checkpoints before leaving the property.";
                            }
                        default:
                            // do nothing
                            break;
                    }
                }
                
                if (helpAlert.message != nil)
                {
                    [helpAlert show];
                }
            }
            
//            NSLog(@"Beacon: %@ is at %@ proximity", beacon.name, beacon.currentProximityValue);
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

-(NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil)
    {
        return _fetchedResultsController;
    }
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:[STIBeaconController allBeaconsSortedFetchRequest] managedObjectContext:[[DataManager sharedInstance] mainObjectContext] sectionNameKeyPath:nil cacheName:@"BeaconList"];
    
    self.fetchedResultsController.delegate = self;
    
    [NSFetchedResultsController deleteCacheWithName:@"BeaconList"];
    
#warning Set up error handling
    NSError *error = nil;
    [self.fetchedResultsController performFetch:&error];
    
    return _fetchedResultsController;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PatrolCell" forIndexPath:indexPath];
    
    STIBeacon *beacon = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = beacon.name;

    if (beacon.checked)
    {
        cell.detailTextLabel.text = beacon.immediateMessage;
    }
    else
    {
        switch ([beacon.currentProximityValue intValue])
        {
            case CLProximityFar:
                cell.detailTextLabel.text = beacon.farMessage;
                break;
            case CLProximityNear:
                cell.detailTextLabel.text = beacon.nearMessage;
                break;
            case CLProximityImmediate:
                cell.detailTextLabel.text = beacon.immediateMessage;
                break;
            default:
                cell.detailTextLabel.text = @"Checkpoint not active";
                break;
        }
    }
    
    switch (_entrywayStatus)
    {
        case STIEntrywayStatusNotVisited:
            if ([beacon.type isEqualToString:BEACON_TYPE_ENTRYWAY])
            {
                cell.backgroundColor = [UIColor orangeColor];
            }
            else
            {
                cell.backgroundColor = [UIColor lightGrayColor];
            }
            break;
        case STIEntrywayStatusEntered:
            if ([beacon.type isEqualToString:BEACON_TYPE_ENTRYWAY])
            {
                if (_beaconCheckTotalCount == 1)
                {
                    cell.backgroundColor = [UIColor greenColor];
                }
                else if (_beaconCheckTotalCount == [[STIBeaconController returnAllBeacons] count])
                {
                    cell.backgroundColor = [UIColor orangeColor];
                }
                else
                {
                    cell.backgroundColor = [UIColor lightGrayColor];
                }
            }
            else if (beacon.checked)
            {
                cell.backgroundColor = [UIColor greenColor];
            }
            else
            {
                cell.backgroundColor = [UIColor orangeColor];
            }
            break;
        case STIEntrywayStatusExited:
            cell.backgroundColor = [UIColor greenColor];
        default:
            break;
    }
    
    return cell;
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
