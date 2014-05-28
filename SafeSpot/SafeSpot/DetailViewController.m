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
        self.detailTitle.title = self.restriction.title;
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
