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
            coordinate: (CLLocationCoordinate2D)coordinate
                 title: (NSString *)title
              duration: (NSDate *)duration;
{
    if (self = [super init])
    {
        _location = location;
        _notes = notes;
        _coordinate = coordinate;
        _title = title;
        _duration = duration;
    }
    return self;
}

+ (instancetype)postWithTitle:(NSString *)title latitude:(double)latitude longitude:(double)longitude
{
    
    ParkingLocation *result = [[ParkingLocation alloc] init];
    result.title = title;
    result.location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    
    result.coordinate =  CLLocationCoordinate2DMake(latitude, longitude);
    
    //some where if/else for geo location
    
    return result;
}

// Archiving
- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.notes forKey:@"notes"];
    [encoder encodeObject:self.title forKey:@"title"];
    [encoder encodeObject:self.duration forKey:@"duration"];
    [encoder encodeDouble:self.coordinate.latitude forKey:@"latitude"];
    [encoder encodeDouble:self.coordinate.longitude forKey:@"longitude"];
    
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init]) {
        _notes = [decoder decodeObjectForKey:@"notes"];
        _title = [decoder decodeObjectForKey:@"title"];
        _duration = [decoder decodeObjectForKey:@"decoder"];
        
        double latitude = [decoder decodeDoubleForKey:@"latitude"];
        double longitude = [decoder decodeDoubleForKey:@"longitude"];
        _location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
        _coordinate = CLLocationCoordinate2DMake(latitude, longitude);
    }
    return self;
}

@end
