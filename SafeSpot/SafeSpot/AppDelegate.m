//
//  AppDelegate.m
//  SafeSpot
//
//  Created by Naveen Yadav on 3/6/14.
//  Copyright (c) 2014 2.5 Asian Dudes. All rights reserved.
//

#import "AppDelegate.h"
#import "MapViewController.h"
#import "FavoritesList.h"
#import "NearbyList.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.locationManager = [[CLLocationManager alloc] init];
    
    // Restore Favorites List & User location
    self.favoritesList = [NSKeyedUnarchiver unarchiveObjectWithFile:[self favoritesListStorageLocation]];
    self.userParkLocation = [NSKeyedUnarchiver unarchiveObjectWithFile:[self userParkStorageLocation]];
    
    if (!self.favoritesList)
    {
        self.favoritesList = [[FavoritesList alloc] init];
    }
    
    // Initialize Nearby List (needs to be done each time App starts)
    self.nearbyList = [[NearbyList alloc] init];
    
    return YES;
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
    [self save];
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
    [self save];
}

// Terminate app, save stuff
- (void)save
{
    [NSKeyedArchiver archiveRootObject:self.favoritesList
                                toFile:[self favoritesListStorageLocation]];
    NSLog(@"Favorites List archived");
    [self.locationManager stopMonitoringSignificantLocationChanges];
}

// Archiving Directory
- (NSString *)applicationDocumentsFolderName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}

// Favorites List
- (NSString *)favoritesListStorageLocation
{
    return [[self applicationDocumentsFolderName] stringByAppendingPathComponent:@"favoritesList"];
}

// User Location
- (NSString *)userParkStorageLocation
{
    return [[self applicationDocumentsFolderName] stringByAppendingString:@"userParkLocation"];
}

// Parking Categories with Boolean Values for Parking
- (NSMutableDictionary *)parkingDictionary
{
    NSMutableDictionary *parkingTypes = [[NSMutableDictionary alloc] init];
    [parkingTypes setValue:[NSNumber numberWithBool:YES] forKey:@"P1530"];  // Parking - 15 or 30 minutes
    [parkingTypes setValue:[NSNumber numberWithBool:YES] forKey:@"P1H"];    // Parking - 1 Hour or more
    [parkingTypes setValue:[NSNumber numberWithBool:NO] forKey:@"PBLO"];    // Bus Layover Signs
    [parkingTypes setValue:[NSNumber numberWithBool:NO] forKey:@"PBZ"];     // Bus Zone
    [parkingTypes setValue:[NSNumber numberWithBool:YES] forKey:@"PCARPL"]; // Carpool signed parking
    [parkingTypes setValue:[NSNumber numberWithBool:NO] forKey:@"PCVL"];    // Commercial Vehicle Load Zones
    [parkingTypes setValue:[NSNumber numberWithBool:YES] forKey:@"PDIS"];   // Disabled Parking Signs
    [parkingTypes setValue:[NSNumber numberWithBool:NO] forKey:@"PGA"];     // Exempt vehicles, Police etc.
    [parkingTypes setValue:[NSNumber numberWithBool:NO] forKey:@"PINST"];   // Geographic directional signs
    [parkingTypes setValue:[NSNumber numberWithBool:NO] forKey:@"PLU"];     // 15 or 30 minute load zones, may be paid
    [parkingTypes setValue:[NSNumber numberWithBool:NO] forKey:@"PNP"];     // No Parking, but "standing" allowed
    [parkingTypes setValue:[NSNumber numberWithBool:NO] forKey:@"PNS"];     // No stopping, standing or parking
    [parkingTypes setValue:[NSNumber numberWithBool:YES] forKey:@"PPEAK"];  // Peaking Parking Restrictions, TOW
    [parkingTypes setValue:[NSNumber numberWithBool:NO] forKey:@"PPL"];     // 3 minute passenger load zone
    [parkingTypes setValue:[NSNumber numberWithBool:YES] forKey:@"PPP"];    // short term paid parking btw 15 min - 4 hours
    [parkingTypes setValue:[NSNumber numberWithBool:NO] forKey:@"PR"];      // Parking Regulatory
    [parkingTypes setValue:[NSNumber numberWithBool:YES] forKey:@"PRZ"];    // Restricted Parking Zone permited parking
    [parkingTypes setValue:[NSNumber numberWithBool:NO] forKey:@"PS"];      // Pay Stations
    [parkingTypes setValue:[NSNumber numberWithBool:NO] forKey:@"PSCH"];    // School Bus or Load
    [parkingTypes setValue:[NSNumber numberWithBool:YES] forKey:@"PTIML"];  // Short term parking 15, 30 minute or 1-4 hours
    [parkingTypes setValue:[NSNumber numberWithBool:NO] forKey:@"PTRKL"];   // 30 minute truck load/unload zones
    [parkingTypes setValue:[NSNumber numberWithBool:NO] forKey:@"PZONE"];   // Includes charter bus, event, etc.
    
    return parkingTypes;
}

@end
