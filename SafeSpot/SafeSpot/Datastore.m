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
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Webcams.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store: */
#ifdef DEBUG
        NSLog(@"removing old datastore (model incompatible, probably");
        [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
            NSLog(@"couldn't add store on second attempt, giving up");
            NSLog(@"%@ %@", error.localizedDescription, error.userInfo);
            abort();
        }
        else {
            NSLog(@"new empty store created");
        }
#else
        
        /*         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
#endif
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
    // JSON Datasoure: http://data.seattle.gov/resource/ge96-bmdn.json
    NSError *error;
    
    NSData *rawData = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://data.seattle.gov/resource/ge96-bmdn.json"]];
    
    NSArray *completeArray = [NSJSONSerialization JSONObjectWithData:rawData
                                                             options:kNilOptions
                                                               error:&error];
    if (!completeArray) {
        NSLog(@"%@ %@", error.localizedDescription, error.localizedFailureReason);
    }
    
    NSDictionary *firstCategory = completeArray[0];
    int keyCount = 0;
    
    /* Example JSON struct:
     {
        "total_zone" : "0",
        "bus" : "0",
        "nostop" : "0",
        "unitid2" : "470",
        "tl_spaces" : "0",
        "blockface_" : "616",
        "total_spac" : "0",
        "tier" : "0",
        "parking_sp" : "0",
        "nopark" : "0",
        "short_rate" : "0",
        "unitdesc" : "11TH AVE NE BETWEEN NE 47TH ST AND NE 50TH ST",
        "distance" : "23",
        "rate" : "0",
        "unitid" : "230",
        "side" : "E",
        "unrestrict" : "0",
        "block_nbr" : "4700",
        "total_nopa" : "0",
        "long_rate" : "0",
        "carpool_sp" : "0",
        "segkey" : "1410",
        "width" : "-23",
        "end_distan" : "639",
        "parking_ca" : "No Parking Allowed",
        "peak_hour" : "4-6PM",
        "elmntkey" : "1434",
        "csm" : true,
        "paid_space" : "0",
        "shape_len" : "0",
        "load" : "0",
        "objectid" : "1",
        "rpz_spaces" : "0",
        "zone" : "0",
        "block_id" : "NE11-47"
     }
    */
    NSLog(@"Logging key-value pairs for first element in JSON file:");
    for (id key in firstCategory)
    {
        NSLog(@"\"%@\" : \"%@\"", key, [firstCategory objectForKey:key]);
        keyCount++;
    }
    
    NSLog(@"total number of keys: %d", keyCount);
    
    if (completionHandler) {
        dispatch_async(dispatch_get_main_queue(), completionHandler);
    }
}

@end
