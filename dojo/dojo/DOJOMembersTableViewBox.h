//
//  DOJOMembersTableViewBox.h
//  dojo
//
//  Created by Michael Zuccarino on 7/25/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DOJOMembersTableViewCell.h"
#import "networkConstants.h"

@interface DOJOMembersTableViewBox : UIView <UITableViewDelegate, UITableViewDataSource>
{
    NSDictionary *currentdojoinfo;
}

@property (strong,nonatomic) IBOutlet UITableView *nameTableView;

@property (strong, nonatomic) DOJOMembersTableViewCell *nameCell;

@property BOOL isSearching;

@property (strong, nonatomic) NSString *userEmail;
@property (strong, nonatomic) NSArray *allDatas;
@property (strong, nonatomic) NSArray *memberList;
@property (strong, nonatomic) NSArray *sumoList;

@property (strong, nonatomic) NSDictionary *currentdojoinfo;

-(IBAction)inviteToDojo:(UIButton *)button;
-(IBAction)changeFriendRequestState:(UIButton *)button;

@end
