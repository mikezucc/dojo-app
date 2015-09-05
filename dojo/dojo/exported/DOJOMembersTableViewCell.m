//
//  DOJOMembersTableViewCell.m
//  dojo
//
//  Created by Michael Zuccarino on 7/25/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import "DOJOMembersTableViewCell.h"

@implementation DOJOMembersTableViewCell

@synthesize nameLabel, friendButton, inviteToDojoButton, checkImage;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        // Initialization code
        nameLabel = [[UILabel alloc] init];
        //checkButton = [[UIButton alloc] init];
        
        [nameLabel setTextColor:[UIColor blackColor]];
        [self.contentView addSubview:nameLabel];
        
        checkImage = [[UIImageView alloc] init];
        [self.contentView addSubview:checkImage];
        
        friendButton = [[UIButton alloc] initWithFrame:CGRectMake(215, 15, 44, 18)];
        [self.contentView addSubview:friendButton];
        
        inviteToDojoButton = [[UIButton alloc] initWithFrame:CGRectMake(272, 9, 28, 26)];
        [self.contentView addSubview:inviteToDojoButton];

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
