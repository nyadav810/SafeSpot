//
//  MapViewController.h
//  SafeSpot
//
//  Created by Naveen Yadav on 3/6/14.
//  Copyright (c) 2014 2.5 Asian Dudes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Datastore.h"

@interface MapViewController : UIViewController <MKMapViewDelegate, UISearchBarDelegate>

@property (strong, nonatomic) Datastore *datastore;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
- (IBAction)centerMapOnUserButtonClicked:(id)sender;
//- (NSInteger)hourConversion: (NSInteger)startHour;

@end
