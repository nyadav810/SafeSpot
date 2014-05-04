//
//  FavoritesTableViewController.h
//  SafeSpot
//
//  Created by Naveen Yadav on 4/9/14.
//  Copyright (c) 2014 2.5 Asian Dudes. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AppDelegate, FavoritesList;

@interface FavoritesTableViewController : UITableViewController <UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) AppDelegate *appDelegate;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) FavoritesList *favoritesList;

@end
