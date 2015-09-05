//
//  DOJOCreateGroupTableViewCell.h
//  dojo
//
//  Created by Michael Zuccarino on 7/14/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DOJOBugFixButton.h"

@interface DOJOCreateGroupTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet DOJOBugFixButton *inviteToDojoButton;
@property (strong, nonatomic) IBOutlet UIButton *requestFriend;

@property (strong, nonatomic) IBOutlet UIButton *friendButton;

@end
