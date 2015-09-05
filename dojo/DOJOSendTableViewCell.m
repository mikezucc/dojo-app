//
//  DOJOSendTableViewCell.m
//  dojo
//
//  Created by Michael Zuccarino on 7/20/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import "DOJOSendTableViewCell.h"

@implementation DOJOSendTableViewCell

@synthesize nameLabel, selectedView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        nameLabel = [[UILabel alloc] init];
        //checkButton = [[UIButton alloc] init];
        
        [nameLabel setTextColor:[UIColor blackColor]];
        [self.contentView addSubview:nameLabel];
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
