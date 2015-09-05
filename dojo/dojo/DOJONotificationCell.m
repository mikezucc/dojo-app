//
//  DOJONotificationCell.m
//  dojo
//
//  Created by Michael Zuccarino on 12/12/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import "DOJONotificationCell.h"

@implementation DOJONotificationCell

@synthesize delegate, startPoint;

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UIView *v = self.contentView;
    UIView *prev;
    while (v.superview && [v.superview isKindOfClass:[UIView class]]){
        v = v.superview;
        prev = v;
    }
    self.startPoint = [[touches anyObject] locationInView:v];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UIView *v = self.contentView;
    UIView *prev;
    while (v.superview && [v.superview isKindOfClass:[UIView class]]){
        v = v.superview;
        prev = v;
    }
    CGPoint nowTouch = [[touches anyObject] locationInView:v];
    [self.delegate swipeIsMoving:[NSNumber numberWithFloat:nowTouch.x-startPoint.x]];
    NSLog(@"distance moved is %f",(nowTouch.x-startPoint.x));
    self.startPoint = nowTouch;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.delegate swipeLetGoforRow:self.contentView.tag];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.delegate swipeCanceled];
    //[self.delegate swipeLetGoforRow:self.contentView.tag];
}

@end
