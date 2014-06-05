//
//  ParkCarViewController.m
//  SafeSpot
//
//  Created by Naveen Yadav on 5/8/14.
//  Copyright (c) 2014 2.5 Asian Dudes. All rights reserved.
//

// http://www.icodeblog.com/2010/07/29/iphone-programming-tutorial-local-notifications/
// [[UIApplication sharedApplication] cancelLocalNotification:<notifcationobject>; -- So you have to hold onto a pointer to whichever notification object you want to delete.

#import "ParkCarViewController.h"
#import "ParkingLocation.h"
#import "VisableAnnotationsList.h"
#import "AppDelegate.h"
#import "Restrictions.h"
#import "MapViewController.h"

@interface ParkCarViewController ()

@end

@implementation ParkCarViewController

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
    
    self.appDelegate = [[UIApplication sharedApplication] delegate];
    
    //Restrictions; // Pass in signs within the mapview
  
    // [self main];
    // if location is not shared, idgaf, juts make sure it doesnt crash
    
    // Get location
    
    
    // compare to street signs at SAME/(.0001 closest? fiddle
    // LOOK at the clustered signs as well aka when zoomed out also look at sign.clusterRestriction and iterate through it
    
    // use day/hour comparator
    
    
    
    // maybe need to know if on left/right side
}

// Main  method
- (void) main{
    

    
}


// compares current hour to restriction hour
- (BOOL)hourComparator:(NSUInteger)start hour:(NSUInteger)endHour ct:(NSUInteger)current{
    
    //have to change start/end if its -100 aka null
    if(current == -100){
        return NO;
    }
    
    if(endHour < current){
        return YES;
    } else if(current >= start){ // its its after restriction start time
        return YES; //can park for awhile
    }
    
    return YES;
}

// Possibly debug current hour
// http://stackoverflow.com/questions/1268509/convert-utc-nsdate-to-local-timezone-objective-c



// pass in todays date
// compares current day to restriction days
- (BOOL) dayComparator:(NSUInteger)startDay end:(NSUInteger)endDay today:(NSUInteger)currentDay{ // if start date exists compare it
    
    if(currentDay == -100){
        return NO;
    }
    
    int parkUntilDay = (int) currentDay; // sunday is day 1, need to change this
    if(parkUntilDay == 1){
        parkUntilDay = 7;
    }else if(parkUntilDay == 7){
        parkUntilDay = 6;
    }else{
        parkUntilDay -= 1;
    }
    
    //have to change current day. IF day = 1, day = 7, if day = 2 (day -1)
    if(parkUntilDay < startDay || parkUntilDay > endDay ){
        return YES;
    }
    
    return NO;
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

- (IBAction)cancelButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// UIDate Picker action, doesnt seem like we will need it
- (IBAction)parkCar:(id)sender {
     // NSLog(@"heya you presseed the wheel");
    // [self.datePickerOutlet date];
    // NSLog(@"will probably delete this lol %@", [self.datePickerOutlet date]);
    
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

-(void)cantPark{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You cant park here"
                                                    message:@"You cant park here"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    // alert.tag = 2;
    [alert show];
    
}

// Park button action
- (IBAction)parkCarButton:(id)sender
{
    // NSLog(@"the park button was pressed");
    ParkingLocation *car = [[ParkingLocation alloc]init];
    
    CLLocation *currentLocation = [self.appDelegate.locationManager location];
    
    NSLog(@"%@",currentLocation);
    car.title = @"You parked here";
    // car.title = [NSString stringWithFormat:@"%@ %d",car.title,[self getTime]];
    
    //Get current time

    int current =  [self getTime];
    // get todays day
    int weekday = [self getDay];
    
    car.duration = [self.datePickerOutlet date];

    NSLog(@"park until %@", car.duration);

    if(currentLocation != NULL)
    {
        // change to  currentLocation
        //do stuff
         car.coordinate = [currentLocation coordinate];
         car.location = currentLocation;
         car.pinColor = MKPinAnnotationColorGreen;
         self.appDelegate.userParkLocation = car;
        
        // IF not by a sign then it IS OK park
        for(MKAnnotationView *sign in self.appDelegate.visableAnnotationsList.signs)
        {
            if([sign isKindOfClass:[Restrictions class]])
            {
                Restrictions *currentAnn = (Restrictions *)sign;

                double distance = [currentLocation distanceFromLocation:currentAnn.location];
            
                if(distance < 10)
                {
                    //NSLog(@"%f",distance);
                    NSLog(@"%@,park type %@",currentAnn.title, currentAnn.parkingType);
                    if(
                       ([[[self.appDelegate parkingDictionary] objectForKey:currentAnn.parkingType] boolValue] == YES)
                       || (([self dayComparator:currentAnn.startDay end:currentAnn.endDay today:weekday])
                       || ([self hourComparator:currentAnn.startTime hour:currentAnn.endTime ct:current]))
                       )
                    {
                        NSCalendar *g = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] ;
                        //NSDateComponents *comps = [gregorian components:NSWeekdayCalendarUnit fromDate:[NSDate date]];
                        NSDateComponents *c = [g components:NSWeekdayCalendarUnit fromDate:car.duration];
                        
                        
                        //NSLog(@"%d", parkUntilDay);
                        NSCalendar *gC = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
                        NSDateComponents *dC = [gC components: (NSHourCalendarUnit | NSMinuteCalendarUnit)
                                                                      fromDate: car.duration];
                        
                        int minuteC = (int) [dC minute];
                        int hourC = (int) [dC hour];
                        
                        int later = (hourC * 100) + minuteC;
                        // NSLog(@"%d", later);
                        // La 47.675734
                        // Lo -122.311317
                        NSUInteger unitFlags = NSHourCalendarUnit;
                        NSDateComponents *components = [gC components:unitFlags
                                                                            fromDate:[NSDate date]
                                                                              toDate:car.duration
                                                                             options:0];
                        int days = [components hour]/24;
                        NSLog(@"%d",days);
                        // ALSO need to check if the DATE duration returns is ok to park until? A little hard
                        if( [[[self.appDelegate parkingDictionary] objectForKey:currentAnn.parkingType] boolValue] == NO)
                        {
                            if((days >= 7) || ![self dayComparator:currentAnn.startDay end:currentAnn.endDay today:days] ||
                               ![self hourComparator:currentAnn.startTime hour:currentAnn.endTime ct:later])
                            {
                            
                                self.appDelegate.userParkLocation = NULL;
                            
                            }else if(days > 6){
                            
                            }else if(days > 5){
                                
                            }else if(days > 4){
                                
                            }else if(days > 4){
                                
                            }else if(days > 3){
                                
                            }else if(days > 2){
                                
                            }
                        NSLog(@"SUPER OK to park %f", distance);
                    } else
                    {
                        // NSLog(@"cant park");
                        self.cantPark;
                        self.appDelegate.userParkLocation = NULL;
                        break;
                    }
                }
                
                if(currentAnn.clusterRestriction.count > 0)
                {
                    for(int i = 0; i < (currentAnn.clusterRestriction.count-1); i++)
                    {
                        Restrictions *clusterAnnotation = (Restrictions *)currentAnn.clusterRestriction[i];
                        
                        double distanceC = [currentLocation distanceFromLocation:clusterAnnotation.location];
                        
                        // NSLog(@"distance %f", distanceC);
                        if(distance < 10)
                        {
                            NSLog(@"%@,park type %@",currentAnn.title, currentAnn.parkingType);
                            // NSLog(@"distance %f", distanceC);
                            
                            if(
                               ([[[self.appDelegate parkingDictionary] objectForKey:clusterAnnotation.parkingType] boolValue] == YES)
                               || (([self dayComparator:clusterAnnotation.startDay end:clusterAnnotation.endDay today:weekday]) // No = cant park, yes = can
                                || [self hourComparator:clusterAnnotation.startTime hour:clusterAnnotation.endTime ct:current]) )
                               
                            {
                                
                                if( [[[self.appDelegate parkingDictionary] objectForKey:currentAnn.parkingType] boolValue] == NO)
                                {
                                    
                                }else{
                                    
                                }
                                
                                NSLog(@"SUPER OK to park %f", distanceC);
                                
                            } else
                            {
                                // NSLog(@"cant park");
                                self.cantPark;
                                self.appDelegate.userParkLocation = NULL;
                                break;
                            }
                        }
                    }
                    //add cluster restrictins iteration!!
                }
            }
        }
    }
        [self dismissViewControllerAnimated:YES completion:
            nil];
        // will add at TBcoor Or mapviews update region did change
    } else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please Share your location"
                                                        message:@"We cannot check if you can park here"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        // alert.tag = 2;
        [alert show];
     
    }
}
@end