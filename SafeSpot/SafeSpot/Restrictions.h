//
//  Restrictions.h
//  SafeSpot
//
//  Created by studentuser on 4/18/14.
//  Copyright (c) 2014 2.5 Asian Dudes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface Restrictions : NSObject <MKAnnotation>

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *comment;
@property (nonatomic, strong) CLLocation *location;

@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;

- (NSNumber *)latitude;
- (NSNumber *)longitude;

+ (instancetype)postWithTitle:(NSString *)title comment:(NSString *)comment latitude:(double)latitude longitude:(double)longitude;

@end
