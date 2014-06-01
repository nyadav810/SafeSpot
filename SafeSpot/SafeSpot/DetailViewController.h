//
//  DetailViewController.h
//  SafeSpot
//
//  Created by Naveen Yadav on 5/3/14.
//  Copyright (c) 2014 2.5 Asian Dudes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "AppDelegate.h"
@class Restrictions;

@interface DetailViewController : UIViewController

@property (strong, nonatomic) AppDelegate *appDelegate;
@property (strong, nonatomic) Restrictions *restriction;

@property (weak, nonatomic) IBOutlet UINavigationItem *detailTitle;

@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
@property (weak, nonatomic) IBOutlet UILabel *parkingStatusLabel;

@property (weak, nonatomic) IBOutlet UILabel *startDayLabel;
@property (weak, nonatomic) IBOutlet UILabel *middleDayLabel;
@property (weak, nonatomic) IBOutlet UILabel *endDayLabel;

@property (weak, nonatomic) IBOutlet UILabel *startTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *middleTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *endTimeLabel;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (weak, nonatomic) IBOutlet UIButton *getDirectionsButton;
- (IBAction)getDirectionsButtonClicked:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *removeFromFavoritesButton;
- (IBAction)removeFavoriteButtonClicked:(id)sender;

@property BOOL nearby;

@end
