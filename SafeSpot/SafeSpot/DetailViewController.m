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
        [days addObject:@"Sunday"];
        [days addObject:@"Monday"];
        [days addObject:@"Tuesday"];
        [days addObject:@"Wednesday"];
        [days addObject:@"Thursday"];
        [days addObject:@"Friday"];
        [days addObject:@"Saturday"];
        
        NSDictionary *dayDictionary = [NSDictionary dictionaryWithObjects:days forKeys:numbers];
        
        self.detailTitle.title = self.restriction.title;
        self.commentLabel.text = self.restriction.comment;

//        self.arrayLabel.text = [NSString stringWithFormat:@"%d Other Signs combined on this street",self.restriction.clusterRestriction.count];
//        //NSLog(@"%d",[self.restriction.clusterRestriction count]);
//        
//        NSLog(@"%@",self.restriction.clusterRestriction );
        
        NSString *startDay = [dayDictionary objectForKey:[NSNumber numberWithInt:self.restriction.startDay]];
        NSString *endDay = [dayDictionary objectForKey:[NSNumber numberWithInt:self.restriction.endDay]];
        
        self.startDayLabel.text = startDay;
        self.endDayLabel.text = endDay;
        
        self.startTimeLabel.text = [NSString stringWithFormat:@"%d", self.restriction.startTime];
        self.endTimeLabel.text = [NSString stringWithFormat:@"%d", self.restriction.endTime];
    }
    
    if (self.nearby == YES)
    {
        self.removeFromFavoritesButton.hidden = YES;
    }
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
