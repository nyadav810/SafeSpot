//
//  ParkingLocation.m
//  SafeSpot
//
//  Created by Naveen Yadav on 5/28/14.
//  Copyright (c) 2014 2.5 Asian Dudes. All rights reserved.
//

#import "ParkingLocation.h"

@implementation ParkingLocation

- (id)init
{
    return self;
}

- (id)initWithLocation: (CLLocation *)location
                 notes: (NSString *)notes
{
    if (self = [super init])
    {
        _location = location;
        _notes = notes;
    }
    return self;
}

@end
