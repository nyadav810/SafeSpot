//
//  MapViewController.h
//  SafeSpot
//
//  Created by Naveen Yadav on 3/6/14.
//  Copyright (c) 2014 2.5 Asian Dudes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
//#import "AppDelegate.h"

@class AppDelegate;

@interface MapViewController : UIViewController <MKMapViewDelegate, UISearchBarDelegate, CLLocationManagerDelegate>
@property (strong, nonatomic) AppDelegate *appDelegate;
@property (strong, nonatomic) CLLocationManager *locationManager;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
//- (NSInteger)hourConversion: (NSInteger)startHour;
@property (weak, nonatomic) IBOutlet UINavigationItem *nav;                 // <-- THATS ME

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *locationButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *parkButton;
- (IBAction)locationButtonClicked:(id)sender;

@end
