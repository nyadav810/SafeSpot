//
//  VisableAnnotationsList.h
//  SafeSpot
//
//  Created by studentuser on 6/1/14.
//  Copyright (c) 2014 2.5 Asian Dudes. All rights reserved.
//


#import <Foundation/Foundation.h>

@class Restrictions;

@interface VisableAnnotationsList : NSObject

@property (nonatomic, strong) NSMutableArray *signs;

- (void)insertObject:(Restrictions *)object inSignsAtIndex:(NSUInteger)index;
- (void)removeObjectAtIndex:(NSUInteger)index;
- (void)insertObjects:(NSArray *)array atIndexes:(NSIndexSet *)indexes;
- (void)removeObjectsAtIndexes:(NSIndexSet *)indexes;


@end
