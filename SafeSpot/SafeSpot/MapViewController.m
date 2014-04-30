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
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] ;
    NSDateComponents *comps = [gregorian components:NSWeekdayCalendarUnit fromDate:[NSDate date]];
    
    int weekday = [comps weekday];
    NSLog(@"%d",weekday);

    
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
        }else{
            // ~ 200-300 unlabeled but HAS restrictions id startHour = s[33]; //-10; //?
            // NSLog(@"%@",startHour);
        }
        
        if( s[33] != [NSNull null]){
            endHour =  (int) [s[33] integerValue];
        }else{
            
        }
        
        if( s[30] != [NSNull null]){
            startDay =  (int) [s[30] integerValue];
        }else{
            
        }
    
        if( s[31] != [NSNull null]){
            endDay =  (int) [s[31] integerValue];
        }else{
            
        }
        
        // maybe make Restriction have Restrictions( or some other name) so one holds the streets restrictions
        // Restrictions have startDay/Hour and endDay/Hour and custom Text
        
        //
        
        Restrictions *rest = [[Restrictions alloc] init];
        rest.title = title;
        rest.comment = comment;
        
        CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
        CLLocationCoordinate2D coordinate = [location coordinate];
        rest.location = location;
        rest.coordinate = coordinate;
        
        totalSigns++;
        if(numberOfPins < 100){
                
            [self.mapView addAnnotation: rest]; // all are adding to [0,0] :( problem with restrictions
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
- (NSInteger)hourComparator {//:(NSInteger)startHour {

    //should pass this in since its probably huge
    NSCalendar *gregorianCal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComps = [gregorianCal components: (NSHourCalendarUnit | NSMinuteCalendarUnit)
                                                  fromDate: [NSDate date]];
    // Then use it
    int minute =[dateComps minute];
    int hour = [dateComps hour];
    NSLog(@"%d,%d",hour,minute);
    
    NSLog(@"Hour comparator called");
    NSInteger start = 0; // start hour
    NSInteger current = 2;
    
    NSInteger end = 1; //end hour
    //use 24hrs, so 7am < 7pm aka 19:00
    
    if(end < current){ //its after the restriction
        //cant park
        NSLog(@"test hours finish");
        //return false;
        
    } else if(current <= start){ // its its after restriction
        //can park
        NSLog(@"test hours cant park finish");
        
        // return true; boolean
    }
    
    return 0;
}

// Possibly debug current hour
// http://stackoverflow.com/questions/1268509/convert-utc-nsdate-to-local-timezone-objective-c
    


// pass in todays date
- (NSInteger) dayComparator{ // if start date exists compare it

    //get todays date
    
    return 0;
}


-(NSInteger) zoomLevel{
    
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
