//
//  FirstViewController.m
//  SafeSpot
//
//  Created by Naveen Yadav on 3/6/14.
//  Copyright (c) 2014 2.5 Asian Dudes. All rights reserved.
//

#import "FirstViewController.h"
#import "AppDelegate.h"

@interface FirstViewController ()

@end

@implementation FirstViewController

- (NSManagedObjectContext *)managedObjectContext
{
    return self.datastore.managedObjectContext;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //NSParameterAssert(self.managedObjectContext);
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    self.datastore = appDelegate.datastore;
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self.datastore updateFromServerWithCompletion:^{
        NSLog(@"datastore update complete");
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
