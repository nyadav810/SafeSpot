//
//  AppDelegate.h
//  SafeSpot
//
//  Created by Naveen Yadav on 3/6/14.
//  Copyright (c) 2014 2.5 Asian Dudes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
@class Datastore, FavoritesList, NearbyList, ParkingLocation;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) FavoritesList *favoritesList;
@property (strong, nonatomic) NearbyList *nearbyList;
@property (strong, nonatomic) ParkingLocation *userParkLocation;

@end
