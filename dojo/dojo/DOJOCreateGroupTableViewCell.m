//
//  DOJOCreateGroupTableViewCell.m
//  dojo
//
//  Created by Michael Zuccarino on 7/14/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import "DOJOCreateGroupTableViewCell.h"

@implementation DOJOCreateGroupTableViewCell

@synthesize nameLabel, friendButton, inviteToDojoButton;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        nameLabel = [[UILabel alloc] init];
        //checkButton = [[UIButton alloc] init];
        
        [nameLabel setTextColor:[UIColor blackColor]];
        [self.contentView addSubview:nameLabel];
        
        friendButton = [[UIButton alloc] initWithFrame:CGRectMake(215, 15, 44, 18)];
        [self.contentView addSubview:friendButton];
        
        inviteToDojoButton = [[DOJOBugFixButton alloc] initWithFrame:CGRectMake(272, 9, 28, 26)];
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
