//
//  RestrictionTableViewCell.h
//  SafeSpot
//
//  Created by Naveen Yadav on 5/3/14.
//  Copyright (c) 2014 2.5 Asian Dudes. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Restrictions;

@interface RestrictionTableViewCell : UITableViewCell
@property (strong, nonatomic) Restrictions *restriction;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end
