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

- (NSString *)description
{
    return [NSString stringWithFormat:@"<Post %@ %@>", self.date, self.comment];
}

- (id)init
{
    if (self = [super init]) {
        _date = [NSDate date];
        _clusterRestriction = [[NSMutableArray alloc] init];
    }
    return self;
}

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



// Archiving
- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.title forKey:@"title"];
    [encoder encodeObject:self.comment forKey:@"comment"];
    [encoder encodeObject:self.date forKey:@"date"];
    [encoder encodeDouble:self.coordinate.latitude forKey:@"latitude"];
    [encoder encodeDouble:self.coordinate.longitude forKey:@"longitude"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init]) {
        double latitude = [decoder decodeDoubleForKey:@"latitude"];
        double longitude = [decoder decodeDoubleForKey:@"longitude"];
        
        _title = [decoder decodeObjectForKey:@"title"];
        _comment = [decoder decodeObjectForKey:@"comment"];
        _date = [decoder decodeObjectForKey:@"date"];
        _location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
        _coordinate = CLLocationCoordinate2DMake(latitude, longitude);
    }
    return self;
}

@end
