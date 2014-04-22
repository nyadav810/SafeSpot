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
    

    NSLog(@"eeeee");
    NSError *error;
    
    NSData *rawData = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://data.seattle.gov/resource/it8u-sznv.json"]];
    
    NSArray *completeArray = [NSJSONSerialization JSONObjectWithData:rawData
                                                             options:kNilOptions
                                                               error:&error];
    if (!completeArray) {
        NSLog(@"%@ %@", error.localizedDescription, error.localizedFailureReason);
    }
    
    int l = [completeArray count];
    NSLog(@"%d", l);
    
    // array only stores 1000
    NSDictionary *firstCategory = completeArray[77];

    int som = 0;
    for(NSDictionary *s in completeArray){
       // NSLog(@"%@", s);
        //id testr = [s objectForKey:@"latitude"] ; //maybe double later
        float testr = (float) [[s objectForKey:@"latitude"] floatValue]; //maybe double later
        float tl = (float) [[s objectForKey:@"longitude"] floatValue]; //maybe double later
        //NSString *res =  [s objectForKey:@"standardte"];
        NSString *res2 =  [s objectForKey:@"customtext"];
        /*
        NSLog(@"%f",testr);
        NSLog(@"%f",tl);
        NSLog(@"%@",res2);
        */
        
        Restrictions *r = [[Restrictions alloc] init];
        r.title = res2;
        r.comment = res2;
        CLLocation *location = [[CLLocation alloc] initWithLatitude:testr longitude:tl];
        
        //NSLog(@"%@", location);
        
        CLLocationCoordinate2D coordinate = [location coordinate];
        r.location = location;
        r.coordinate = coordinate;
        
        if(som < 100){
            
            [self.mapView addAnnotation: r]; // all are adding to [0,0] :( problem with restrictions
            
            som++;
        }
        
    }
    int keyCount = 0;
    
     NSLog(@"Logging key-value pairs for first element in JSON file:");
     for (id key in firstCategory)
     {
     NSLog(@"\"%@\" : \"%@\"", key, [firstCategory objectForKey:key]);
    
     keyCount++;
     }

     /*

      
      */
        
    NSLog(@"total number of keys: %d", keyCount);
    
    Restrictions *test = [[Restrictions alloc] init];
    test.title = @"@rawr";
    test.comment = @"eee";
    
    CLLocation *location2 = [[CLLocation alloc]init ];
    CLLocationCoordinate2D coordinate2 = [location2 coordinate];
    
    test.location = location2;
    test.coordinate = coordinate2;
    //fiddle with location/coordinate
    
    
    //[self.mapView addAnnotation: test];
    
}
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
 
 signs
 
 2014-04-21 23:06:04.548 SafeSpot[17516:60b] "segkey" : "21241"
 2014-04-21 23:06:04.549 SafeSpot[17516:60b] "customtext" : "NO PARKING WITHIN 30 FEET"
 2014-04-21 23:06:04.549 SafeSpot[17516:60b] "objectid" : "1"
 2014-04-21 23:06:04.549 SafeSpot[17516:60b] "compkey" : "47590.0"
 2014-04-21 23:06:04.549 SafeSpot[17516:60b] "unitdesc" : "S SHELTON ST 0110 BLOCK N SIDE (   0) 0 FT E /O CORSON AVE S (R7-WI30 C/W067-F)"
 2014-04-21 23:06:04.550 SafeSpot[17516:60b] "custom" : "0"
 2014-04-21 23:06:04.550 SafeSpot[17516:60b] "unittype" : "01-RS"
 2014-04-21 23:06:04.550 SafeSpot[17516:60b] "starttime" : "0"
 2014-04-21 23:06:04.550 SafeSpot[17516:60b] "width" : "17"
 2014-04-21 23:06:04.551 SafeSpot[17516:60b] "category" : "PNP"
 2014-04-21 23:06:04.551 SafeSpot[17516:60b] "distance" : "13"
 2014-04-21 23:06:04.551 SafeSpot[17516:60b] "endday" : "7"
 2014-04-21 23:06:04.551 SafeSpot[17516:60b] "elmntkey" : "66305"
 2014-04-21 23:06:04.551 SafeSpot[17516:60b] "signsz" : "12x18"
 2014-04-21 23:06:04.552 SafeSpot[17516:60b] "latitude" : "47.5579"
 2014-04-21 23:06:04.552 SafeSpot[17516:60b] "supportdes" : "Wood Post"
 2014-04-21 23:06:04.552 SafeSpot[17516:60b] "facing" : "E"
 2014-04-21 23:06:04.552 SafeSpot[17516:60b] "endtime" : "2359"
 2014-04-21 23:06:04.553 SafeSpot[17516:60b] "color1" : "R/W"
 2014-04-21 23:06:04.553 SafeSpot[17516:60b] "longitude" : "-122.318"
 2014-04-21 23:06:04.553 SafeSpot[17516:60b] "unitid" : "SGN-645"
 2014-04-21 23:06:04.553 SafeSpot[17516:60b] "comptype" : "20"
 2014-04-21 23:06:04.553 SafeSpot[17516:60b] "standardte" : "NO PARKING WITHIN 30 FEET"
 2014-04-21 23:06:04.554 SafeSpot[17516:60b] "fieldnotes" : "C/W067-F"
 2014-04-21 23:06:04.554 SafeSpot[17516:60b] "support" : "WP"
 2014-04-21 23:06:04.554 SafeSpot[17516:60b] "reflective" : "0"
 2014-04-21 23:06:04.554 SafeSpot[17516:60b] "signtype" : "R7-WI30"
 2014-04-21 23:06:04.555 SafeSpot[17516:60b] "startday" : "1"
 2014-04-21 23:06:04.555 SafeSpot[17516:60b] "categoryde" : "No Parking, but "standing" allowed"
 
 
 }
 */


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
