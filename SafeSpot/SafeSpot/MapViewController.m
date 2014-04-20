//
//  MapViewController.m
//  SafeSpot
//
//  Created by Naveen Yadav on 3/6/14.
//  Copyright (c) 2014 2.5 Asian Dudes. All rights reserved.
//

#import "MapViewController.h"
#import "AppDelegate.h"
#import "Restrictions.h"

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

    [self test];
    [self hourComparator];
    
    // - - - - - Notes about signs database - - -
    // "No parking" is good because it uses hours 0-23:59 aka all day.
    // Categories mention restricted parking zones
    // lat/long and start day/end day are going to be used
    // Stand rate
    // Use custom text or stand rate, they seem the same
    
    
    // - - - Zoom Notes
    // maybe at a certain zoom level we COULD use categories to make the lines?
    // might be useful for lines http://stackoverflow.com/questions/13013873/mapkit-make-route-line-follow-streets-when-map-zoomed-in
    // http://www.galloway.me.uk/tutorials/singleton-classes/
    // if we implement quad trees we should cite http://robots.thoughtbot.com/how-to-handle-large-amounts-of-data-on-maps
    
    
    // - - - Bug Notes
    // Regularly scheduled maintenance occurs on the 3rd Saturday of every month.
    // http://status.socrata.com/
    
   
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// debug method
- (void) test{
    
    Restrictions *test = [[Restrictions alloc] init];
    test.comment = @"eee";
    
    CLLocation *location = [[CLLocation alloc]init ];
    CLLocationCoordinate2D coordinate = [location coordinate];
    
    test.location = location;
    //fiddle with location/coordinate
    NSLog(@"eeeee");
    
    [self.mapView addAnnotation: test];
    
}



// This method will compares current time to start/end time
- (NSInteger)hourComparator {//:(NSInteger)startHour {
    
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

// This method will change the current time to the correct timezone/time
// not sure what to return, maybe Date instead
- (NSInteger) correctTimezone{
    //http://stackoverflow.com/questions/1268509/convert-utc-nsdate-to-local-timezone-objective-c
    
    return 0;
}

// This method will add annotations to map
// addAnnotations, built in



// This method will remove annotations on map
//removeAnnotations



// need to make the annotations in something I can clear



//
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id < MKAnnotation >)annotation
{
    NSString *reuseIdentifier = @"purplePin";
    
    
    MKPinAnnotationView *result = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseIdentifier];
    if (!result) {
        result =
        [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    }
    result.pinColor = MKPinAnnotationColorPurple;
    
    return result;
}

/*
- (IBAction)centerMapOnUserButtonClicked:(id)sender {
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
}
*/

@end
