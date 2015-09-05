//
//  DOJOMembersTableViewCell.h
//  dojo
//
//  Created by Michael Zuccarino on 7/25/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DOJOMembersTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *checkImage;
@property (strong, nonatomic) IBOutlet UIButton *inviteToDojoButton;
@property (strong, nonatomic) IBOutlet UIButton *requestFriend;

@property (strong, nonatomic) IBOutlet UIButton *friendButton;

@end
