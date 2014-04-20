//
//  Restrictions.m
//  SafeSpot
//
//  Created by Dexter Lesaca III on 4/18/14.
//  Copyright (c) 2014 2.5 Asian Dudes. All rights reserved.
//

#import "Restrictions.h"
#import <CoreLocation/CoreLocation.h>


@implementation Restrictions

+ (instancetype)postWithTitle:(NSString *)title comment:(NSString *)comment latitude:(double)latitude longitude:(double)longitude
{
    
    Restrictions *result = [[Restrictions alloc] init];
    result.title = title;
    result.comment = comment;
    result.location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    
    result.coordinate =  CLLocationCoordinate2DMake(latitude, longitude);
    
    //some where if/else for geo location
    
    return result;
}

- (NSNumber *)latitude
{
    return @(self.location.coordinate.latitude);
}
- (NSNumber *)longitude
{
    return @(self.location.coordinate.longitude);
    
}

@end
