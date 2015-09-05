//
//  DOJOTypeCell.m
//  dojo
//
//  Created by Michael Zuccarino on 12/18/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import "DOJOTypeCell.h"

@implementation DOJOTypeCell

@synthesize typeLabel, typeIcon;

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    typeIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    //typeIcon.frame = CGRectMake(0, 0, 30, 30);
    typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 44, 50, 20)];
    //typeLabel.frame = CGRectMake(0, 44, self.frame.size.width, 20);
    typeLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:16];
    
    [self.contentView addSubview:typeIcon];
    [self.contentView addSubview:typeLabel];
    return self;
}

@end
