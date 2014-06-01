//
//  ParkCarViewController.h
//  SafeSpot
//
//  Created by Naveen Yadav on 5/8/14.
//  Copyright (c) 2014 2.5 Asian Dudes. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AppDelegate;

@interface ParkCarViewController : UIViewController <UITextViewDelegate>

@property (strong, nonatomic) AppDelegate *appDelegate;

- (IBAction)cancelButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (weak, nonatomic) IBOutlet UIDatePicker *datePickerOutlet;

- (IBAction)parkCar:(id)sender;

- (IBAction)parkCarButton:(id)sender;

@end
