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
        //[self.favoritesList fakeSomeSigns];
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
    [self.locationManager stopUpdatingLocation];
}

// Archiving Location
- (NSString *)applicationDocumentsFolderName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}

- (NSString *)favoritesListStorageLocation
{
    return [[self applicationDocumentsFolderName] stringByAppendingPathComponent:@"favoritesList"];
}

- (NSString *)userParkStorageLocation
{
    return [[self applicationDocumentsFolderName] stringByAppendingString:@"userParkLocation"];
}

@end
