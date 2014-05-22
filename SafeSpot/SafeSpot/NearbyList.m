//
//  NearbyList.m
//  SafeSpot
//
//  Created by Naveen Yadav on 5/21/14.
//  Copyright (c) 2014 2.5 Asian Dudes. All rights reserved.
//

#import "NearbyList.h"
#import "Restrictions.h"

@implementation NearbyList

- (id)init
{
    if (self = [super init])
    {
        _signs = [NSMutableArray array];
    }
    return self;
}

- (NSString *)description
{
    return [self.signs description];
}

# pragma mark - Sign Array manipulation methods

- (void)insertObject:(Restrictions *)object inSignsAtIndex:(NSUInteger)index
{
    [self.signs insertObject:object atIndex:index];
}

- (void)removeObjectAtIndex:(NSUInteger)index
{
    [self.signs removeObjectAtIndex:index];
}

- (void)insertObjects:(NSArray *)array atIndexes:(NSIndexSet *)indexes
{
    [self.signs insertObjects:array atIndexes:indexes];
}

- (void)removeObjectsAtIndexes:(NSIndexSet *)indexes
{
    [self.signs removeObjectsAtIndexes:indexes];
}

@end

