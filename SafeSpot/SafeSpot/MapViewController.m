//
//  MapViewController.m
//  SafeSpot
//
//  Created by Naveen Yadav on 3/6/14.
//  Copyright (c) 2014 2.5 Asian Dudes. All rights reserved.
//

#import "MapViewController.h"
#import "AppDelegate.h"

@interface MapViewController ()

@end

@implementation MapViewController

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

    [self hourConversion];
    
    // notes about signs database;
    // no parking is good because it uses hours 0-23:59 aka all day.
    // categories mention restricted parking/
    // Stand rate
    // lat/long and start day/end day
    // Use custom text/ or stand rate, they seem the same
    
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//changes hour key
- (NSInteger)hourConversion {//:(NSInteger)startHour {
    
    // get current time as an int
    // http://stackoverflow.com/questions/3385552/nsdatecomponents-componentsfromdate-and-time-zones
    // http://stackoverflow.com/questions/10861433/in-objective-c-to-get-the-current-hour-and-minute-as-integers-we-need-to-use-n
    
    
    
    NSLog(@"rawr");
    NSInteger start = 0;
    NSInteger current = 2;
    NSInteger end = 1;
    //use 24hrs, so 7am < 7pm aka 19:00
    if(end <= current){ //its after the restriction
        //cant park
        NSLog(@"test finish");
    } else if(current <= start){ // its its after restriction
        //can park
        NSLog(@"test cant park finish");
    }
    
    return 0;
}

- (NSInteger) correctTimezone{
    //http://stackoverflow.com/questions/1268509/convert-utc-nsdate-to-local-timezone-objective-c
    
    return 0;
}



- (IBAction)centerMapOnUserButtonClicked:(id)sender {
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
}
@end
