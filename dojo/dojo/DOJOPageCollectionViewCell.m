//
//  DOJOPageCollectionViewCell.m
//  dojo
//
//  Created by Michael Zuccarino on 7/21/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import "DOJOPageCollectionViewCell.h"

@implementation DOJOPageCollectionViewCell

@synthesize cellImageView, tapArea, backgroundView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        cellImageView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
        tapArea = [[UIButton alloc] initWithFrame:self.contentView.bounds];
        
        [self.contentView addSubview:cellImageView];
        [self.contentView addSubview:tapArea];
        
        //[self.contentView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"dojosan.png"]]];
        self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dojosan.png"]];
    }
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    // reset image property of imageView for reuse
    //self.cellImageView.image = nil;
    
    // update frame position of subviews
    //self.cellImageView.frame = self.contentView.bounds;
    
    //[self.tapArea.imageView setContentMode:UIViewContentModeScaleAspectFill];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
