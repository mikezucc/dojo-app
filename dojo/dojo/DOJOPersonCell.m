//
//  DOJOPersonCell.m
//  dojo
//
//  Created by Michael Zuccarino on 1/2/15.
//  Copyright (c) 2015 Michael Zuccarino. All rights reserved.
//

#import "DOJOPersonCell.h"

@implementation DOJOPersonCell

@synthesize profileView, pointsLabel, nameLabel;

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    self.profileView.contentMode = UIViewContentModeScaleAspectFill;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
