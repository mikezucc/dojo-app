//
//  DOJOHomeTableViewCell.m
//  dojo
//
//  Created by Michael Zuccarino on 7/10/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import "DOJOHomeTableViewCell.h"
#import "DOJOPostCollectionViewCell.h"

@implementation DOJOHomeTableViewCell

@synthesize dojoNameLabel,activeMemberLabel, picView, alphaBar, timeStamp;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        //[self.contentView addSubview:picView];
        /*
        UICollectionViewFlowLayout *horizontal = [[UICollectionViewFlowLayout alloc] init];
        [horizontal setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        picView = [[UICollectionView alloc] initWithFrame:CGRectMake(6, 75, 200, 100) collectionViewLayout:horizontal];
        [picView registerClass:[DOJOPostCollectionViewCell class] forCellWithReuseIdentifier:@"postCell"];
        picView.alwaysBounceHorizontal = YES;
        [self.contentView addSubview:picView];
         */
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
    UICollectionViewFlowLayout *horizontal = [[UICollectionViewFlowLayout alloc] init];
    [horizontal setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    self.picView = [[DOJOPicView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, 250) collectionViewLayout:horizontal];
    [self.picView registerClass:[DOJOPostCollectionViewCell class] forCellWithReuseIdentifier:@"postCell"];
    self.picView.alwaysBounceHorizontal = YES;
    [self.contentView addSubview:self.picView];
    [self.contentView sendSubviewToBack:self.picView];
    //messageBox = [[UILabel alloc] initWithFrame:CGRectMake(20, 50, 280, 100)];
    //[self.contentView addSubview:messageBox];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
