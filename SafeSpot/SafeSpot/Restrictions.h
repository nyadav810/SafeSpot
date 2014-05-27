//
//  Restrictions.h
//  SafeSpot
//
//  Created by Dexter Lesaca III on 4/18/14.
//  Copyright (c) 2014 2.5 Asian Dudes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface Restrictions : NSObject <MKAnnotation>

@property (nonatomic, strong) NSDate *date; // Might not need

@property (nonatomic, copy) NSString *title; // Steet Name
@property  (nonatomic) MKPinAnnotationColor pinColor; // pin color

@property (nonatomic, copy) NSString *comment; //Restrictions
@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSMutableArray *clusterRestriction; // used to combine restrictions. idk how yet

- (NSNumber *)latitude;
- (NSNumber *)longitude;

+ (instancetype)postWithTitle:(NSString *)title comment:(NSString *)comment latitude:(double)latitude longitude:(double)longitude;

@end
