//
//  DOJOSearch4DojoTableViewCell.m
//  dojo
//
//  Created by Michael Zuccarino on 10/14/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import "DOJOSearch4DojoTableViewCell.h"

@implementation DOJOSearch4DojoTableViewCell

@synthesize alphaBar, picView, dojoLabel, nameLabel, addButton, distanceLabel;

- (void)awakeFromNib {
    // Initialization code
    
    //self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 67);
    /*
    UICollectionViewFlowLayout *horizontal = [[UICollectionViewFlowLayout alloc] init];
    [horizontal setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    self.picView = [[DOJOPicView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, 250) collectionViewLayout:horizontal];
    [self.picView registerClass:[DOJOPostCollectionViewCell class] forCellWithReuseIdentifier:@"postCell"];
    self.picView.alwaysBounceHorizontal = YES;
    [self.contentView addSubview:self.picView];
    [self.contentView sendSubviewToBack:self.picView];
     */
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
