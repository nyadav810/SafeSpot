//
//  ParkingLocation.h
//  SafeSpot
//
//  Created by Naveen Yadav on 5/28/14.
//  Copyright (c) 2014 2.5 Asian Dudes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface ParkingLocation : NSObject

@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) NSString *notes;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSDate *duration;


@end
