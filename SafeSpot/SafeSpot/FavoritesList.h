//
//  FavoritesList.h
//  SafeSpot
//
//  Created by Naveen Yadav on 5/3/14.
//  Copyright (c) 2014 2.5 Asian Dudes. All rights reserved.
//
//  Persistant list of user's favorite signs

#import <Foundation/Foundation.h>

@class Restrictions;

@interface FavoritesList : NSObject

@property (nonatomic, strong) NSMutableArray *signs;

- (void)insertObject:(Restrictions *)object inSignsAtIndex:(NSUInteger)index;
- (void)removeObjectAtIndex:(NSUInteger)index;
- (void)insertObjects:(NSArray *)array atIndexes:(NSIndexSet *)indexes;
- (void)removeObjectsAtIndexes:(NSIndexSet *)indexes;


- (void)fakeSomeSigns;

@end
