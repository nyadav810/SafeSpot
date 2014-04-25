//
//  MapViewController.m
//  SafeSpot
//
//  Created by Naveen Yadav on 3/6/14.
//  Copyright (c) 2014 2.5 Asian Dudes. All rights reserved.
//

/*
 Found bugs:
 Going "Home makes the app crash"
 Current location button makes AC
 Array only holds 1000(kind of useful for now
 */

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
    
    // #FF5E3A
    UIColor *color = [UIColor colorWithRed:255/255.0f green:94/255.0f blue:58/255.0f alpha:1.0f];
    [self.tabBarController.tabBar setSelectedImageTintColor:color];
//    [self.view setBackgroundColor:color];
//    
//    // #FF9500
//    UIColor *color2 = [UIColor colorWithRed:255/255.0f green:149/255.0f blue:0/255.0f alpha:1.0f];
//    
//    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    
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
    
    NSError *error;
    
    // JSON Datasoure: http://data.seattle.gov/resource/it8u-sznv.json
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"rows" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSArray *signs = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    
    if (!signs) {
        NSLog(@"%@ %@", error.localizedDescription, error.localizedFailureReason);
    }
    
    NSLog(@"%d", [signs count]);

    int som = 0;
    for(NSDictionary *s in signs){
        float latitude = (float) [[s objectForKey:@"latitude"] floatValue]; // maybe double later
        float longitude = (float) [[s objectForKey:@"longitude"] floatValue]; // maybe double later
        NSString *title =  [s objectForKey:@"unitdesc"];
        NSString *comment =  [s objectForKey:@"customtext"];
        
        Restrictions *r = [[Restrictions alloc] init];
        r.title = title;
        r.comment = comment;
        CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
        
        CLLocationCoordinate2D coordinate = [location coordinate];
        r.location = location;
        r.coordinate = coordinate;
        
        if(som < 100){
            
            [self.mapView addAnnotation: r]; // all are adding to [0,0] :( problem with restrictions
            
            som++;
        }
    }
    
//    Restrictions *test = [[Restrictions alloc] init];
//    test.title = @"@rawr";
//    test.comment = @"eee";
//    
//    CLLocation *location2 = [[CLLocation alloc]init ];
//    CLLocationCoordinate2D coordinate2 = [location2 coordinate];
//    
//    test.location = location2;
//    test.coordinate = coordinate2;
//    fiddle with location/coordinate
//    
//    
//    [self.mapView addAnnotation: test];
    
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


// Source for code http://www.appcoda.com/ios-programming-101-drop-a-pin-on-map-with-mapkit-api/
// suppose to zoom into location
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 800, 800);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
}

/*
//
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id < MKAnnotation >)annotation
{
    NSString *reuseIdentifier = @"purplePin";
    
    NSLog(@"annote this");
    
    MKPinAnnotationView *result = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseIdentifier];
    if (!result) {
        result =
        [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    }
    result.pinColor = MKPinAnnotationColorPurple;
    
    return result;
}
 */


- (IBAction)centerMapOnUserButtonClicked:(id)sender {
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
}


@end
