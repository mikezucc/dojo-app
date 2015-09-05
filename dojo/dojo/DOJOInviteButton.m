//
//  DOJOInviteButton.m
//  dojo
//
//  Created by Michael Zuccarino on 11/8/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import "DOJOInviteButton.h"

@implementation DOJOInviteButton

@synthesize section, searchType, magnifyDelegate, initialTouchLocation;

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touch event begin, count is %ld",(long) touches.count);
    UITouch *singleTouch = [touches anyObject];
    NSLog(@"single touch is %@",singleTouch);
    self.initialTouchLocation = [singleTouch locationInView:self];
    [self tapBegan];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *aTouch = [touches anyObject];
    NSLog(@"touch event ended with %@",aTouch);
    CGPoint currentTouchPosition = [aTouch locationInView:self];
            [self tapEnded];
    
    //  Detect if swipe vertically up
    if (fabsf(self.initialTouchLocation.x - currentTouchPosition.x) >= 50 &&
        fabsf(self.initialTouchLocation.y - currentTouchPosition.y) <= 200)
    {
        NSLog(@"swipe vertically");
        // SWIPE VERTICAL UP
        if (self.initialTouchLocation.y < currentTouchPosition.y) {
            //[self swipeUp];
        }
        self.initialTouchLocation = CGPointZero;
    }
    else if (fabsf(self.initialTouchLocation.x - currentTouchPosition.x) <= 19 &&
             fabsf(self.initialTouchLocation.y - currentTouchPosition.y) <= 19)
    {
        NSLog(@"tap anywhere");
        // TAP
        self.initialTouchLocation = CGPointZero;
    }
    
    
    //detect is tap anywhere
    
}

-(void)swipeUp
{
    NSLog(@"swipe up");
    
    //[self.touchEventDelegate swipeUpEvent:self.tag];
}

-(void)tapEnded
{
    [self.magnifyDelegate tapEnded];
}

-(void)tapBegan
{
    NSLog(@"plagnify");
    //__weak DOJOCellButton *weakSelf = self;
    //[self.touchEventDelegate plagnifyEvent:self.tag withSection:self.titleLabel.text.integerValue];
    [self.magnifyDelegate tapBegan];
}

@end
