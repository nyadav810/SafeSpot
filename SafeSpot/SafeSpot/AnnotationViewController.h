//
//  AnnotationViewController.h
//  SafeSpot
//
//  Created by Naveen Yadav on 5/21/14.
//  Copyright (c) 2014 2.5 Asian Dudes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
@class Restrictions;

@interface AnnotationViewController : UIViewController
@property (strong, nonatomic) AppDelegate *appDelegate;
@property (strong, nonatomic) Restrictions *restriction;
@property (weak, nonatomic) IBOutlet UINavigationItem *annotationTitle;
- (IBAction)doneButtonClicked:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *commentLabel;

@property (weak, nonatomic) IBOutlet UILabel *arrayLabel;

@end
