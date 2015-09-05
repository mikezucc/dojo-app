//
//  DOJOBugFixButton.m
//  dojo
//
//  Created by Michael Zuccarino on 7/16/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import "DOJOBugFixButton.h"

@implementation DOJOBugFixButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)setBackgroundImage:(UIImage *)image forState:(UIControlState)state
{
    BOOL shouldEnable = self.enabled;
    self.enabled = YES;
    [self setBackgroundImage:image forState:state];
    self.enabled = shouldEnable;
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
