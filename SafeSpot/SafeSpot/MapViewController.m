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

// To Do: Add non retina splash screen
// combine restrictions on the same street into one (implement Qtree first to possibly save clustering/ninja skills)
// Find way to update restrictions, maybe with a button
// add quad tree coord

#import "MapViewController.h"
#import "AppDelegate.h"
#import "Restrictions.h"
#import "TBCoordinateQuadTree.h"
//#import <CoreLocation/CoreLocation.h>

@interface MapViewController ()

@end

@implementation MapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // #FF5E3A
    UIColor *color = [UIColor colorWithRed:255/255.0f green:94/255.0f blue:58/255.0f alpha:1.0f];
    [self.tabBarController.tabBar setSelectedImageTintColor:color];
    
    self.appDelegate = [[UIApplication sharedApplication] delegate];
    self.locationManager = self.appDelegate.locationManager;
    self.locationManager.delegate = self;
    self.searchBar.delegate = self;
    
    self.mapView.delegate = self;
    [self.view addSubview:self.mapView];
    
    self.coordinateQuadTree = [[TBCoordinateQuadTree alloc] init]; 
    self.coordinateQuadTree.mapView = self.mapView;
    self.coordinateQuadTree.root;
    
    
    // centers map
    self.setCenterCoordinate;
    
    //builds tree
    [self main];
    
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setCenterCoordinate
{

    MKCoordinateRegion region;
    CLLocationCoordinate2D center;
    
    center.latitude = 47.6097;
    center.longitude = -122.3331;
    
    // use the zoom level to compute the region
    MKCoordinateSpan span; // = [self coordinateSpanWithMapView:self centerCoordinate:centerCoordinate andZoomLevel:zoomLevel];
    // = MKCoordinateRegionMake(centerCoordinate, span);
    span.latitudeDelta = 0.3f;
    span.longitudeDelta = 0.3f;
    
    region.center = center;
    region.span = span;
    // set the region like normal
    NSLog(@"%f,%f", center.longitude,center.latitude);
    [self.mapView setRegion:region animated:YES];
}


// Main debug method
- (void) main{
   
    
    NSCalendar *gregorianCal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComps = [gregorianCal components: (NSHourCalendarUnit | NSMinuteCalendarUnit)
                                                  fromDate: [NSDate date]];
    
    int minute = (int) [dateComps minute];
    int hour = (int) [dateComps hour];

    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] ;
    NSDateComponents *comps = [gregorian components:NSWeekdayCalendarUnit fromDate:[NSDate date]];
    
    int weekday = (int) [comps weekday];
    int current = (hour * 100) + minute;

    // call build tree
    [self.coordinateQuadTree buildTree:current withDay:weekday]; // make it pass in an array


}

/*
 , [ 80235, "F301808D-EC9D-4711-9E2E-A360096ED708", 80235, 1285278966, "386118", 1285278966, "386118", null, "80235", "531546.0", "20", "2149", "25117", "260", "-17", "SGN-139286", "01-RS", "R7-NP", "[RED SLASHED CIRCLE] P", "PNP", "No Parking, but \"standing\" allowed", "
 
 15TH AVE S 0320 BLOCK W SIDE ( 247) 247 FT S/O S HANFORD ST (R7-NP )
 
 ", "N", "UP", "Wood Pole", "RED/WHITE", "12X18", false, null, null, "[RED SLASHED CIRCLE] P", "1", "7", "0", "2359", "47.5744", "-122.3135" ]
 */





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
        // visible rect might be causing problems
        sleep(10);
        NSLog(@"%f",zoomScale);
        if(zoomScale < 10){
            NSArray *annotations = [self.coordinateQuadTree clusteredAnnotationsWithinMapRect:mapView.visibleMapRect withZoomScale:zoomScale];
            //NSLog(@"%@",annotations);
            [self updateMapViewAnnotationsWithAnnotations:annotations];
        }
        
    }];
}

- (double)zoomScale {
    return self.mapView.bounds.size.width / self.mapView.visibleMapRect.size.width;
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
    NSLog(@"TEST");
    NSLog(@"%@",toKeep);
    
    // These two methods must be called on the main thread
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.mapView addAnnotations:[toAdd allObjects]];
        
        [self.mapView removeAnnotations:[toRemove allObjects]];
    }];
}


#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self.nav setLeftBarButtonItem:nil animated:YES];
    [self.nav setRightBarButtonItem:nil animated:YES];
    [self.nav setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil) style:UIBarButtonItemStylePlain target:self action:@selector(didClickCancelButton:)]];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [self.nav setLeftBarButtonItem:self.locationButton animated:YES];
    [self.nav setRightBarButtonItem:self.parkButton animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar endEditing:YES];
}

#pragma mark - Button actions

- (IBAction)didClickCancelButton:(id)sender
{
    [self searchBarCancelButtonClicked:self.searchBar];
}

- (IBAction)locationButtonClicked:(id)sender
{
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
    CLLocation *location  = [self.locationManager location];
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

- (IBAction)parkButtonClicked:(id)sender {
    [self performSegueWithIdentifier:@"parkSegue" sender:sender];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    //NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil) {
    }
}

@end
