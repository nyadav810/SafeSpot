//
//  Datastore.m
//  SafeSpot
//
//  Created by Naveen Yadav on 3/6/14.
//  Copyright (c) 2014 2.5 Asian Dudes. All rights reserved.
//

#import "Datastore.h"

@interface Datastore ()
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@end

@implementation Datastore

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Webcams" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}


// Retrieve JSON data from datasource and parse the information. Called upon launch in MapViewController.
- (void)updateFromServerWithCompletion:(void (^)(void))completionHandler
{
    // JSON Datasoure: http://data.seattle.gov/resource/it8u-sznv.json
    
//    NSError *error;
//    
//    NSData *rawData = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://data.seattle.gov/resource/it8u-sznv.json"]];
//    
//    NSArray *completeArray = [NSJSONSerialization JSONObjectWithData:rawData
//                                                             options:kNilOptions
//                                                               error:&error];
//    if (!completeArray) {
//        NSLog(@"%@ %@", error.localizedDescription, error.localizedFailureReason);
//    }
//    
//    NSDictionary *firstCategory = completeArray[0];
//    int keyCount = 0;
//
//    NSLog(@"Logging key-value pairs for first element in JSON file:");
//    for (id key in firstCategory)
//    {
//        NSLog(@"\"%@\" : \"%@\"", key, [firstCategory objectForKey:key]);
//        keyCount++;
//    }
//    
//    NSLog(@"total number of keys: %d", keyCount);
//    
//    if (completionHandler) {
//        dispatch_async(dispatch_get_main_queue(), completionHandler);
//    }
}

@end
