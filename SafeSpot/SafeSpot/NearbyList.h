//
//  NearbyList.h
//  SafeSpot
//
//  Created by Naveen Yadav on 5/21/14.
//  Copyright (c) 2014 2.5 Asian Dudes. All rights reserved.
//
//  List of Parking Signs close to user

#import <Foundation/Foundation.h>

@class Restrictions;

@interface NearbyList : NSObject

@property (nonatomic, strong) NSMutableArray *signs;

- (void)insertObject:(Restrictions *)object inSignsAtIndex:(NSUInteger)index;
- (void)removeObjectAtIndex:(NSUInteger)index;
- (void)insertObjects:(NSArray *)array atIndexes:(NSIndexSet *)indexes;
- (void)removeObjectsAtIndexes:(NSIndexSet *)indexes;


@end
