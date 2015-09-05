//
//  DOJOCreateGroupViewBox.h
//  dojo
//
//  Created by Michael Zuccarino on 7/14/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DOJOCreateGroupTableViewCell.h"
#import "networkConstants.h"

@interface DOJOCreateGroupViewBox : UIView <UITableViewDelegate, UITableViewDataSource>

@property (strong,nonatomic) IBOutlet UITableView *nameTableView;

//@property (strong, nonatomic) DOJOCreateGroupTableViewCell *nameCell;

@property BOOL changeStatus;

@property (strong, nonatomic) NSString *userEmail;
@property (strong, nonatomic) NSArray *tableViewList;
@property (strong, nonatomic) NSArray *statusSectionArray;
@property (strong, nonatomic) NSArray *friendSectionArray;
@property NSInteger *rowSelected;

-(IBAction)inviteToDojo:(UIButton *)button;
-(IBAction)changeFriendRequestState:(UIButton *)button;

@end
