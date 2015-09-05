//
//  DOJOFriendCell.h
//  dojo
//
//  Created by Michael Zuccarino on 12/14/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DOJOFriendCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *profView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UIView *colorBar;

@end
