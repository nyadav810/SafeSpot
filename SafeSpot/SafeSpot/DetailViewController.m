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

// Set up mini map
- (void)configureMap
{
    if (self.restriction)
    {
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        [annotation setCoordinate:self.restriction.coordinate];
        [self.mapView addAnnotation:annotation];
        
        MKCoordinateRegion region;
        MKCoordinateSpan span;
        
        span.latitudeDelta = 0.005;
        span.longitudeDelta = 0.005;
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
        // Hide remove from Favorites button if segue came from Nearby
        if (self.nearby == YES)
        {
            self.removeFromFavoritesButton.hidden = YES;
        }
        
        self.detailTitle.title = self.restriction.title;
        self.commentLabel.text = self.restriction.comment;
        
        [self formatDateTime];
        
        [self formatParkingStatus];
    }
}

- (void)formatParkingStatus
{
    // NSLog(@"%@: %@", self.restriction.comment, self.restriction.parkingType);
    
    // Check Parking Type
    if ([[[self.appDelegate parkingDictionary] objectForKey:self.restriction.parkingType] boolValue] == NO)
    {
        self.parkingStatusLabel.textColor = [UIColor redColor];
        self.parkingStatusLabel.text = @"It is not ok to park here at this time.";
    } else
    {
        // Check time restrictions
        if ([self dayComparator:self.restriction.startDay end:self.restriction.endDay today:[self getDay]] && [self hourComparator:self.restriction.startTime hour:self.restriction.endTime ct:[self getTime]])
        {
            self.parkingStatusLabel.textColor = [UIColor redColor];
            self.parkingStatusLabel.text = @"It is not ok to park here at this time.";
        } else {
            self.parkingStatusLabel.textColor = [UIColor greenColor];
            self.parkingStatusLabel.text = @"It is ok to park here at this time.";
        }
    }
}

- (void)formatDateTime
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
    
    NSString *startDay = [dayDictionary objectForKey:[NSNumber numberWithInt:self.restriction.startDay]];
    NSString *endDay = [dayDictionary objectForKey:[NSNumber numberWithInt:self.restriction.endDay]];
    
    // Format Day Labels
    if (!startDay && !endDay)
    {
        // Case 1: Not Specified
        self.middleDayLabel.hidden = YES;
        self.startDayLabel.hidden = YES;
        self.endDayLabel.hidden = YES;
    } else if (self.restriction.startDay == 1 && self.restriction.endDay == 7) {
        // Case 2: All Week
        self.startDayLabel.hidden = YES;
        self.endDayLabel.hidden = YES;
        self.middleDayLabel.text = @"Every Day";
    } else
    {
        // Case 3: Otherwise
        self.startDayLabel.text = startDay;
        self.endDayLabel.text = endDay;
    }
    
    // Format Time Labels
    int startTime = self.restriction.startTime;
    int endTime = self.restriction.endTime;
    
    if (!startTime || !endTime || startTime == 0 || endTime == 0)
    {
        // Case 1: Not Specified
        self.startTimeLabel.hidden = YES;
        self.endTimeLabel.hidden = YES;
        self.middleTimeLabel.hidden = YES;
    } else if ((startTime == 0 || startTime == 1) && endTime == 2359)
    {
        // Case 1: Parking Available at all times
        self.startTimeLabel.hidden = YES;
        self.endTimeLabel.hidden = YES;
        self.middleTimeLabel.text = @"All day";
    } else
    {
        // Case 3: Otherwise
        self.startTimeLabel.text = [self convertTimeFromMilitary:startTime];
        self.endTimeLabel.text = [self convertTimeFromMilitary:endTime];
//        self.startTimeLabel.text = [NSString stringWithFormat:@"%d", startTime];
//        self.endTimeLabel.text = [NSString stringWithFormat:@"%d", endTime];
    }
}

// Date/Time Helper Methods

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

// compares current hour to restriction hour
- (BOOL)hourComparator:(NSUInteger)start hour:(NSUInteger)endHour ct:(NSUInteger)current{
    
    //have to change start/end if its -100 aka null
    if (current == -100)
    {
        return NO;
    }
    
    if (endHour < current)
    {
        return YES;
    } else if (current >= start)
    {
        // its its after restriction
        return YES;
    }
    
    return NO;
}

// pass in todays date
// compares current day to restriction days
- (BOOL) dayComparator:(NSUInteger)startDay end:(NSUInteger)endDay today:(NSUInteger)currentDay
{
    // if start date exists compare it
    
    if (currentDay == -100)
    {
        return NO;
    }
    
    //have to change start/end if its -100 aka null
    if (currentDay < startDay && currentDay > endDay )
    {
        return YES;
    }
    
    return NO;
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
