//
//  DetailViewController.h
//  SafeSpot
//
//  Created by Naveen Yadav on 5/3/14.
//  Copyright (c) 2014 2.5 Asian Dudes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
@class Restrictions;

@interface DetailViewController : UIViewController

@property (strong, nonatomic) AppDelegate *appDelegate;
@property (strong, nonatomic) Restrictions *restriction;
@property (weak, nonatomic) IBOutlet UINavigationItem *detailTitle;
- (IBAction)removeFavoriteButtonClicked:(id)sender;

@end
