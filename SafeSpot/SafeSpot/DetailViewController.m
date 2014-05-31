//
//  DetailViewController.m
//  SafeSpot
//
//  Created by Naveen Yadav on 5/3/14.
//  Copyright (c) 2014 2.5 Asian Dudes. All rights reserved.
//

#import "DetailViewController.h"
#import "AppDelegate.h"
#import "Restrictions.h"
#import "FavoritesList.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.appDelegate = [[UIApplication sharedApplication] delegate];
    [self configureView];
    [self configureMap];
}

- (void)configureMap
{
    if (self.restriction)
    {
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        [annotation setCoordinate:self.restriction.coordinate];
        [self.mapView addAnnotation:annotation];
        
        MKCoordinateRegion region;
        MKCoordinateSpan span;
        
        span.latitudeDelta = 0.01;
        span.longitudeDelta = 0.01;
        region.span = span;
        region.center = self.restriction.coordinate;
        [self.mapView setRegion:region animated:YES];
        [self.mapView regionThatFits:region];
    }
}

- (void)configureView
{
    // Update the user interface for the detail item.
    
    if (self.restriction)
    {
        
        NSMutableArray *numbers = [NSMutableArray array];
        
        for (NSInteger i = 1; i <= 7; i++)
        {
            [numbers addObject:[NSNumber numberWithInteger:i]];
        }
        
        // Day of Week Array
        NSMutableArray *days = [NSMutableArray array];
       
        [days addObject:@"Monday"];
        [days addObject:@"Tuesday"];
        [days addObject:@"Wednesday"];
        [days addObject:@"Thursday"];
        [days addObject:@"Friday"];
        [days addObject:@"Saturday"];
        [days addObject:@"Sunday"]; // is day 7
        
        NSDictionary *dayDictionary = [NSDictionary dictionaryWithObjects:days forKeys:numbers];
        
        self.detailTitle.title = self.restriction.title;
        self.commentLabel.text = self.restriction.comment;

//        self.arrayLabel.text = [NSString stringWithFormat:@"%d Other Signs combined on this street",self.restriction.clusterRestriction.count];
//        //NSLog(@"%d",[self.restriction.clusterRestriction count]);
//        might need to add custom text
//        NSLog(@"%@",self.restriction.clusterRestriction );
        
        NSString *startDay = [dayDictionary objectForKey:[NSNumber numberWithInt:self.restriction.startDay]];
        NSString *endDay = [dayDictionary objectForKey:[NSNumber numberWithInt:self.restriction.endDay]];
        
        self.startDayLabel.text = startDay;
        self.endDayLabel.text = endDay;
        
        if (self.restriction.startTime == 0 && self.restriction.endTime == 2359)
        {
            self.startTimeLabel.hidden = YES;
            self.endTimeLabel.hidden = YES;
            
        }
        
        //self.startTimeLabel.text = [NSString stringWithFormat:@"%d", self.restriction.startTime];
        //self.endTimeLabel.text = [NSString stringWithFormat:@"%d", self.restriction.endTime];
        self.startTimeLabel.text = [self convertTimeFromMilitary:self.restriction.startTime];
        self.endTimeLabel.text = [self convertTimeFromMilitary:self.restriction.endTime];
    }
    
    // Hide remove from Favorites button if segue came from Nearby
    if (self.nearby == YES)
    {
        self.removeFromFavoritesButton.hidden = YES;
    }
}

- (NSString *)convertTimeFromMilitary:(int)x
{
    NSString *time;
	// convert military time to AM/PM
    if (x < 1000)
    {
        time = [NSString stringWithFormat:@"0%d", x];
    } else
    {
        time = [NSString stringWithFormat:@"%d", x];
    }
    
	int mHr = [[time substringWithRange:NSMakeRange(0,2)] intValue];
	int min = [[time substringWithRange:NSMakeRange(2,2)] intValue];
    
	int hr;
	if(mHr == 0)
    {
		hr = 12;
	}
    else
    {
		hr = mHr % 12;
	}
    
	return [NSString stringWithFormat:@"%d:%.2d %@", hr, min, (mHr >= 12 ? @"PM" : @"AM")];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)removeFavoriteButtonClicked:(id)sender {
    if ([self.appDelegate.favoritesList.signs containsObject:self.restriction])
    {
        [self.appDelegate.favoritesList removeObjectAtIndex:[self.appDelegate.favoritesList.signs indexOfObject:self.restriction]];
        
        // segue out
        [self.navigationController popViewControllerAnimated:YES];
    }
}
@end
