//
//  ParkCarViewController.h
//  SafeSpot
//
//  Created by Naveen Yadav on 5/8/14.
//  Copyright (c) 2014 2.5 Asian Dudes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ParkCarViewController : UIViewController <UITextViewDelegate>
- (IBAction)cancelButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end
