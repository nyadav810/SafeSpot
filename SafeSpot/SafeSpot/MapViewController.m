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
 // http://status.socrata.com/
 */

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


// Pins
// https://github.com/thoughtbot/TBAnnotationClustering/blob/master/TBAnnotationClustering/TBCoordinateQuadTree.m
// http://stackoverflow.com/questions/7145797/ios-mapkit-custom-pins



#import "MapViewController.h"
#import "AppDelegate.h"
#import "Restrictions.h"
#import <CoreData/CoreData.h>

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
    
    //NSParameterAssert(self.managedObjectContext);
    self.appDelegate = [[UIApplication sharedApplication] delegate];
    self.locationManager = self.appDelegate.locationManager;
    self.datastore = self.appDelegate.datastore;
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    
    [self.datastore updateFromServerWithCompletion:^{
        NSLog(@"datastore update complete");
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] ;
    NSDateComponents *comps = [gregorian components:NSWeekdayCalendarUnit fromDate:[NSDate date]];
    
    int weekday = (int) [comps weekday];
    //NSLog(@"%d",weekday); // pass it in..? it kept breaking

    NSLog(@" zoom level is ");
    self.zoomLevel;
    
    [self test];

    
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// Main debug method
- (void) test{
    
    NSError *error;
    
    // JSON Datasoure: http://data.seattle.gov/resource/it8u-sznv.json 
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"rows" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    
    //NSArray *signs = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    NSDictionary *rawSigns = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    if (!rawSigns) {
        NSLog(@"%@ %@", error.localizedDescription, error.localizedFailureReason);
    }
    
    NSArray *signs = [rawSigns objectForKey:@"data"];
    
    //should pass this in since its probably huge
    NSCalendar *gregorianCal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComps = [gregorianCal components: (NSHourCalendarUnit | NSMinuteCalendarUnit)
                                                  fromDate: [NSDate date]];
    
    int minute = (int) [dateComps minute];
    int hour = (int) [dateComps hour];
    // NSLog(@"%d,%d,%d,%d",hour,minute,start,endHour);
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] ;
    NSDateComponents *comps = [gregorian components:NSWeekdayCalendarUnit fromDate:[NSDate date]];
    
    int weekday = (int) [comps weekday];
    
    NSInteger current = (hour * 100) + minute;
    NSLog(@"%d",weekday);
    
    
    int numberOfPins = 0;
    int totalSigns = 0;
    
    for(NSArray *s in signs){
        
        float latitude = (float) [s[35] floatValue];
        float longitude = (float) [s[36]floatValue];
        
        NSString *title =  s[21]; // Street Names
        //15TH AVE S 0320 BLOCK W SIDE ( 247) 247 FT S/O S HANFORD ST (R7-NP )
        // http://stackoverflow.com/questions/6825834/objective-c-how-to-extract-part-of-a-string-e-g-start-with
        // or use substring to get certain parts
        
        
        NSString *comment =  s[20]; // Restrictions
        
        NSString *details =  s[32]; // more on the restrictions
        
        int startHour = -100;
        int endHour = -100;
        int startDay = -100;
        int endDay = -100;
        
        if( s[33] != [NSNull null]){
            startHour =  (int) [s[33] integerValue];
            //NSLog(@"%d",startHour);
        }else{
            // ~ 200-300 unlabeled but HAS restrictions id startHour = s[33]; //-10; //?
            // NSLog(@"%@",startHour);
        }
        
        if( s[34] != [NSNull null]){
            endHour =  (int) [s[34] integerValue];
            //NSLog(@"%d",endHour);

        }else{
            
        }
        
        //maybe make a boolean to verify non null?
        if( s[31] != [NSNull null]){
            startDay =  (int) [s[31] integerValue];
        }else{
            
        }
    
        if( s[32] != [NSNull null]){
            endDay =  (int) [s[32] integerValue];
            // NSLog(@"%d",endDay);
        }else{
            
        }
        // Only run if start and end are not null
        // [self dayComparator:startDay end:endDay today:weekday];
        
        
        // maybe make Restriction have Restrictions( or some other name) so one holds the streets restrictions
        // Restrictions have startDay/Hour and endDay/Hour and custom Text
        
        
        
        Restrictions *rest = [[Restrictions alloc] init];
        rest.title = title;
        rest.comment = comment;
        
        CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
        CLLocationCoordinate2D coordinate = [location coordinate];
        rest.location = location;
        rest.coordinate = coordinate;
        
       
        
        totalSigns++;
        if(numberOfPins < 100){
            
            // [self mapView addAnnotation
            
            // day compare first, if its okay check hour comparator
            // only run if not start and end hour are not null
            [self hourComparator:startHour hour:endHour ct:current];
            //depending on answer change pin color
            
            [self.mapView addAnnotation:rest];
            //[self.mapView addAnnotation: self.mapView viewForAnnotation: rest pin:details ]; // all are adding to [0,0] :( problem with restrictions
            numberOfPins++;
        }
    }


}

/*
 , [ 80235, "F301808D-EC9D-4711-9E2E-A360096ED708", 80235, 1285278966, "386118", 1285278966, "386118", null, "80235", "531546.0", "20", "2149", "25117", "260", "-17", "SGN-139286", "01-RS", "R7-NP", "[RED SLASHED CIRCLE] P", "PNP", "No Parking, but \"standing\" allowed", "15TH AVE S 0320 BLOCK W SIDE ( 247) 247 FT S/O S HANFORD ST (R7-NP )", "N", "UP", "Wood Pole", "RED/WHITE", "12X18", false, null, null, "[RED SLASHED CIRCLE] P", "1", "7", "0", "2359", "47.5744", "-122.3135" ]
 */

// Gets string of day
// NSString *localDate = [NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterMediumStyle];

// http://stackoverflow.com/questions/10861433/in-objective-c-to-get-the-current-hour-and-minute-as-integers-we-need-to-use-n
// This method will compares current time to start/end time
- (NSInteger)hourComparator:(NSUInteger)start hour:(NSUInteger)endHour ct:(NSUInteger)current{ //add param for current

    
    //have to change start/end if its -100 aka null
    if(endHour < current){ //its after the restriction, maybe && statement for start..?
        //cant park
        // NSLog(@"test can park yay!");
        //return false;
        
        //
    } else if(current >= start){ // its its after restriction
        //can park
        //NSLog(@"test hours cant park finish");
        
        // NSLog(@"%d,%d",start,endHour);
        
        // return true; boolean
    }
    
    return 0;
}

// Possibly debug current hour
// http://stackoverflow.com/questions/1268509/convert-utc-nsdate-to-local-timezone-objective-c
    


// pass in todays date
- (NSInteger) dayComparator:(NSUInteger)startDay end:(NSUInteger)endDay today:(NSUInteger)currentDay{ // if start date exists compare it
    
    NSLog(@"%d,%d", startDay, endDay);
    if(currentDay < startDay && currentDay > endDay ){
        // true?
        //
        
        NSLog(@"%d", currentDay);
        
    }
    //get todays date
    
    return 0;
}


-(NSInteger) zoomLevel{
    double scale = _mapView.bounds.size.width / _mapView.visibleMapRect.size.width;
    double totalTilesAtMaxZoom = MKMapSizeWorld.width / 256.0;
    NSInteger zoomLevelAtMaxZoom = log2(totalTilesAtMaxZoom);
    NSInteger zoomLevel = MAX(0, zoomLevelAtMaxZoom + floor(log2f(scale) + 0.5));
    
    // NSLog(@"%d",zoomLevel);
    
    switch (zoomLevel) {
        case 13:
        case 14:
        case 15:
            return 64;
        case 16:
        case 17:
        case 18:
            return 32;
        case 19:
            return 16;
            
        default:
            return 88;
    }
    return 0;
}




// This method will add annotations to map
// addAnnotations, built in



// This method will remove annotations on map
//removeAnnotations


// need to make the annotations in something I can clear



// Source for code http://www.appcoda.com/ios-programming-101-drop-a-pin-on-map-with-mapkit-api/
// suppose to zoom into location
// other method



/*
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id < MKAnnotation >)annotation
{
    // pin color red or green
    NSString *reuseIdentifier = @"greenPin";
    
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

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    [[NSOperationQueue new] addOperationWithBlock:^{
        double zoomScale = self.mapView.bounds.size.width / self.mapView.visibleMapRect.size.width;
        NSLog(@"%f",zoomScale);
        // NSArray *annotations = [self.coordinateQuadTree clusteredAnnotationsWithinMapRect:mapView.visibleMapRect withZoomScale:zoomScale];
        
        // [self updateMapViewAnnotationsWithAnnotations:annotations];
    }];
}

- (void)updateMapViewAnnotationsWithAnnotations:(NSArray *)annotations
{
    NSMutableSet *before = [NSMutableSet setWithArray:self.mapView.annotations];
    NSSet *after = [NSSet setWithArray:annotations];
    
    // Annotations circled in blue shared by both sets
    NSMutableSet *toKeep = [NSMutableSet setWithSet:before];
    [toKeep intersectSet:after];
    
    // Annotations circled in green
    NSMutableSet *toAdd = [NSMutableSet setWithSet:after];
    [toAdd minusSet:toKeep];
    
    // Annotations circled in red
    NSMutableSet *toRemove = [NSMutableSet setWithSet:before];
    [toRemove minusSet:after];
    
    // These two methods must be called on the main thread
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.mapView addAnnotations:[toAdd allObjects]];
        [self.mapView removeAnnotations:[toRemove allObjects]];
    }];
}

// Centers map on user's location
- (IBAction)centerMapOnUserButtonClicked:(id)sender
{
    if ([CLLocationManager locationServicesEnabled])
    {
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.distanceFilter = kCLDistanceFilterNone;
        [self.locationManager startUpdatingLocation];
    }
    CLLocation *location = [self.locationManager location];
    CLLocationCoordinate2D coordinate = [location coordinate];
    MKCoordinateRegion region;
    region.center = coordinate;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.0125;
    span.longitudeDelta = 0.0125;
    region.span = span;
    [self.mapView setRegion:region animated:YES];
    
    self.mapView.showsUserLocation = YES;
}


@end
