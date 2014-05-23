//
//  FavoritesList.m
//  SafeSpot
//
//  Created by Naveen Yadav on 5/3/14.
//  Copyright (c) 2014 2.5 Asian Dudes. All rights reserved.
//

#import "FavoritesList.h"
#import "Restrictions.h"

@implementation FavoritesList

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

// Create fake Favorite signs
- (void)fakeSomeSigns
{
    double latitudeSeattle = 47.0;
    double longitudeSeattle = -122.0;
    
    for (NSInteger i = 1; i < 21; i++)
    {
        NSString *title = [NSString stringWithFormat:@"Favorite Sign #%ld", (long)i];
        NSString *comment = [NSString stringWithFormat:@"Comment #%ld", (long)i];
        Restrictions *newRestrictions = [Restrictions postWithTitle:title comment:comment latitude:latitudeSeattle longitude:longitudeSeattle];
        latitudeSeattle += .1;
        longitudeSeattle += .1;
        [self insertObject:newRestrictions inSignsAtIndex:0];
    }
    NSLog(@"%d signs added to favorite signs", 20);
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

// Archiving
- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.signs forKey:@"signs"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init]) {
        _signs = [decoder decodeObjectForKey:@"signs"];
    }
    return self;
}

@end
