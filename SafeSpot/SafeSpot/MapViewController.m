//
//  MapViewController.m
//  SafeSpot
//
//  Created by Naveen Yadav on 3/6/14.
//  Copyright (c) 2014 2.5 Asian Dudes. All rights reserved.
//

// - - - - - Notes about signs database - - -



// - - - Zoom Notes
// maybe at a certain zoom level we COULD use categories to make the lines?
// might be useful for lines http://stackoverflow.com/questions/13013873/mapkit-make-route-line-follow-streets-when-map-zoomed-in
// http://www.galloway.me.uk/tutorials/singleton-classes/

// if we implement quad trees we should cite http://robots.thoughtbot.com/how-to-handle-large-amounts-of-data-on-maps


// Pins
// https://github.com/thoughtbot/TBAnnotationClustering/blob/master/TBAnnotationClustering/TBCoordinateQuadTree.m
// http://stackoverflow.com/questions/7145797/ios-mapkit-custom-pins

// To Do: Add non retina splash screen
// Create globals for current day/time
// Combine restrictions on the same street into one (implement Qtree first to possibly save clustering/ninja skills)
// implement CSV instead of JSON
// Find way to update restrictions, maybe with a button
// find way to update ONLY new restrictions, but for NOW just replace ALL?

// TODO Naveen:
// Park Car Feature
// Map View Overlaid Search
// Finish Favorites/Nearby
// Improve location button

#import "MapViewController.h"
#import "AppDelegate.h"
#import "Restrictions.h"
#import "TBCoordinateQuadTree.h"
#import "AnnotationViewController.h"
#import "NearbyList.h"
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
    
    // centers map
    [self setCenterCoordinate];
    
    //builds tree
    [self main];
    
    [self updateNearbyAnnotations];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
 // centers map to seattle
- (void)setCenterCoordinate
{

    MKCoordinateRegion region;
    CLLocationCoordinate2D center;
    
    center.latitude = 47.6097;
    center.longitude = -122.3331;
    
    // use the zoom level to compute the region
    MKCoordinateSpan span;
    
    // change these to change zoom level
    span.latitudeDelta = 0.03f;
    span.longitudeDelta = 0.03f;
    
    region.center = center;
    region.span = span;
    // set the region
    [self.mapView setRegion:region animated:YES];
    
}

-(int)getTime{
    // get current time
    NSCalendar *gregorianCal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComps = [gregorianCal components: (NSHourCalendarUnit | NSMinuteCalendarUnit)
                                                  fromDate: [NSDate date]];
    
    int minute = (int) [dateComps minute];
    int hour = (int) [dateComps hour];
    
    int current = (hour * 100) + minute;
    
    return current;
}

-(int)getDay{
    // get todays day
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] ;
    NSDateComponents *comps = [gregorian components:NSWeekdayCalendarUnit fromDate:[NSDate date]];

    int weekday = (int) [comps weekday];
    return weekday;
}


// Main  method
- (void) main{
    

    // call build tree
    [self.coordinateQuadTree buildTree];

}



#pragma mark - Map Annotation Segue

// called when an annotation view is clicked on
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    [self performSegueWithIdentifier:@"annotationSegue" sender:view.annotation];
}

//connection between sender and destination
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"annotationSegue"])
    {
        //connect with property in destination controller class
        //MKAnnotationView *view = sender;
        //NSString *sign = [view.annotation title];
        
        [segue.destinationViewController setRestriction:sender];
    }
}


// Method for CUSTOM pins

//http://stackoverflow.com/questions/5861686/help-with-mapkit-three-annotations-with-three-different-pin-colors 
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id < MKAnnotation >)annotation
{
    // Get rid of pin for user location
    if (annotation == mapView.userLocation)
    {
        return nil;
    }
    
    NSString *reuseIdentifier = @"pin";
    
    //MKAnnotationView for own pics
    MKPinAnnotationView *result = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseIdentifier];
    if (!result) {
        result =
        [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    }
    
    //result.image = [UIImage imageNamed:@"pin2.png"];
    result.canShowCallout = YES;
    
    // result.pinColor = MKPinAnnotationColorGreen;
    if ([annotation isKindOfClass:[Restrictions class]]){
        Restrictions *currentAnn = (Restrictions *)annotation;
        result.pinColor = currentAnn.pinColor;
    }
    result.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    

    return result;
}


// annimation for pins
- (void)addBounceAnnimationToView:(UIView *)view
{
    CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    
    bounceAnimation.values = @[@(0.05), @(1.1), @(0.9), @(1)];
    
    bounceAnimation.duration = 0.6;
    NSMutableArray *timingFunctions = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < 4; i++) {
        [timingFunctions addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    }
    [bounceAnimation setTimingFunctions:timingFunctions.copy];
    bounceAnimation.removedOnCompletion = NO;
    
    [view.layer addAnimation:bounceAnimation forKey:@"bounce"];
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    for (UIView *view in views) {
        [self addBounceAnnimationToView:view];
    }
}

// when map moves it calls this
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    [[NSOperationQueue new] addOperationWithBlock:^{

        double zoomScale = self.mapView.bounds.size.width / self.mapView.visibleMapRect.size.width;

       
         NSLog(@"%f",zoomScale);
        int time =[self getTime];
        int day = [self getDay];
        // NSLog(@"today is %d day",[self getDay]);
        
        // Called when zoomed in enough to show all signs
        if(zoomScale > 0.256){ //zoom level affects clustering
            NSArray *annotations = [self.coordinateQuadTree clusteredAnnotationsWithinMapRect:mapView.visibleMapRect withZoomScale:zoomScale c:time withDay:day b:NO];
            

            NSMutableDictionary *clusterSigns = [[NSMutableDictionary alloc] init]; // Might not want Array
            
            for(Restrictions *restriction in annotations){
                NSLog(@"%@",restriction);
                // NSLog(@"%d and %d days are %d and %d", restriction.startTime, restriction.endTime,restriction.startDay ,restriction.endDay);
                
                //NSString *loc = [NSString stringWithFormat:@"%f %f",[restriction.longitude doubleValue],[restriction.longitude doubleValue]];
                NSString *loc = [NSString stringWithFormat:@"%f",restriction.coordinate.longitude ];
                restriction.coordinate.latitude;
                restriction.coordinate.longitude;
                //NSLog(@"%@",[clusterSigns objectForKey:loc] );
                 //NSLog(@"%@",loc );
                if([clusterSigns objectForKey:loc] == NULL){
                    // NSMapTable;
                    [clusterSigns setValue:restriction forKey:loc];
                    //[[restriction clusterRestriction] addObject:restriction];
                    //NEED to find way to combine all, CLUSTER doesnt work
                    NSLog(@" HARDAA %@",loc);
                }else{
                    //NSLog(@"%@",loc );
                    [[[clusterSigns objectForKey:loc] clusterRestriction] addObject:restriction];

                }// find way to keep track of same lat/long, then add
            }
            
            // change to clusterSigns
            [self updateMapViewAnnotationsWithAnnotations:annotations];
            // [self updateMapViewAnnotationsWithAnnotations:[clusterSigns allValues]];
        }else if(zoomScale > 0.06){
            
            NSArray *annotations = [self.coordinateQuadTree clusteredAnnotationsWithinMapRect:mapView.visibleMapRect withZoomScale:zoomScale c:time withDay:day b:YES];
            NSMutableDictionary *clusterSigns = [[NSMutableDictionary alloc] init];
            
            for(Restrictions *restriction in annotations){

                if([clusterSigns objectForKey:restriction.title] == NULL){
                    [clusterSigns setValue:restriction forKey:restriction.title];

                }else{
                    // change to the getter first
                    [[[clusterSigns objectForKey:restriction.title] clusterRestriction] addObject:restriction];

                }
            
            }
            // NSLog(@"%@",[clusterSigns allValues]);
            [self updateMapViewAnnotationsWithAnnotations:[clusterSigns allValues]];
            
        }else{
            // Delete annotations
            NSLog(@"lets delete stuff");
            // NSLog(@" do this %d",[self.mapView.annotations count]);
            sleep(.01);
            NSLog(@" do this %d",[self.mapView.annotations count]);
            //NSLog(@" do this %d",[self.mapView.annotations count]);
            [mapView removeAnnotations:self.mapView.annotations];
        }
        
    }];
}



- (double)zoomScale {
    return self.mapView.bounds.size.width / self.mapView.visibleMapRect.size.width;
}

// updates pins to whats on the map
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
    NSLog(@"update pins");
    
    // These two methods must be called on the main thread
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.mapView addAnnotations:[toAdd allObjects]];
        
        [self.mapView removeAnnotations:[toRemove allObjects]];
    }];
}

// Nearby Annotation stuff
- (void)updateNearbyAnnotations
{
    CLLocation *location  = [self.locationManager location];
    CLLocationCoordinate2D coordinate = [location coordinate];
    
    MKMapPoint curr;
    MKMapRect rect;

    if (location != nil)
    {
        curr = MKMapPointForCoordinate(coordinate);
        rect = MKMapRectMake(curr.x, curr.y, 0.0025, 0.0025);
        
        // Change nearby list here
        int time =[self getTime];
        int day = [self getDay];
        NSArray *annotations = [self.coordinateQuadTree clusteredAnnotationsWithinMapRect:rect withZoomScale:[self zoomScale] c:time withDay:day b:NO];
        
        self.appDelegate.nearbyList.signs = [NSMutableArray arrayWithArray:annotations];
    }
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

// Search bar cancel button
- (IBAction)didClickCancelButton:(id)sender
{
    [self searchBarCancelButtonClicked:self.searchBar];
}

// Get user location
- (IBAction)locationButtonClicked:(id)sender
{
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized)
    {
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        [self.locationManager startUpdatingLocation];
        CLLocation *location  = [self.locationManager location];
        CLLocationCoordinate2D coordinate = [location coordinate];

        [self.mapView setCenterCoordinate:coordinate animated:YES];
        
        self.mapView.showsUserLocation = YES;
        [self updateNearbyAnnotations];
    }
}

// Segue to park car
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

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    // TODO: Update Nearby List when user moves WITHOUT clearing the list
}

@end
