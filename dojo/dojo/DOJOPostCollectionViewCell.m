//
//  DOJOPostCollectionViewCell.m
//  dojo
//
//  Created by Michael Zuccarino on 10/28/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import "DOJOPostCollectionViewCell.h"

@implementation DOJOPostCollectionViewCell

@synthesize cellFace, cellButton, cellDescription, moviePlayer, indexPath;//, homeVC;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        cellFace = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 250)];
        cellButton = [[DOJOCellButton alloc] initWithFrame:CGRectMake(0, 44, self.frame.size.width, self.frame.size.height-44)];
        [cellButton setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
        
        [self.contentView addSubview:cellButton];
        [self.contentView addSubview:cellFace];
        
        //[self.contentView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"dojosan.png"]]];
        //self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dojito180.png"]];
        //[self.contentView.layer setCornerRadius:14];
        //[self.contentView.layer setRasterizationScale:[[UIScreen mainScreen] scale]];
        //[self.contentView.layer setShouldRasterize:YES];
    }
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    // reset image property of imageView for reuse
    self.cellFace.image = nil;
    
    // update frame position of subviews
    self.cellFace.frame = self.contentView.bounds;
    //[self.tapArea.imageView setContentMode:UIViewContentModeScaleAspectFill];
}

-(void)awakeFromNib
{
    cellFace = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 250)];
    [self.contentView addSubview:cellFace];
    self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dojito180.png"]];
}

@end
