//
//  DOJOSearchForUserViewController.h
//  dojo
//
//  Created by Michael Zuccarino on 9/15/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "DOJOSearchFriendCell.h"
#import "networkConstants.h"

@interface DOJOSearchForUserViewController : UIViewController <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>

-(IBAction)removeFromStack:(id)sender;

-(IBAction)changeFriendRequestStatus:(UIButton *)button;

@property (strong,nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) IBOutlet UITableView *searchTableView;
@property (strong, nonatomic) NSArray *searchTableViewData;
@property NSInteger *rowSelected;

@end
