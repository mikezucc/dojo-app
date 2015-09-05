//
//  DOJOSearchFriendCell.m
//  dojo
//
//  Created by Michael Zuccarino on 9/15/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import "DOJOSearchFriendCell.h"

@implementation DOJOSearchFriendCell

@synthesize friendName, requestFriendButton;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        friendName = [friendName init];
        friendName.font = [UIFont fontWithName:@"Avenir" size:18.0];
        requestFriendButton = [[UIButton alloc] init];
        
        [self.contentView addSubview:friendName];
        [self.contentView addSubview:requestFriendButton];
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
