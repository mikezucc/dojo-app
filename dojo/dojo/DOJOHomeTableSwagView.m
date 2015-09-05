//
//  DOJOHomeTableSwagView.m
//  dojo
//
//  Created by Michael Zuccarino on 1/30/15.
//  Copyright (c) 2015 Michael Zuccarino. All rights reserved.
//

#import "DOJOHomeTableSwagView.h"

@implementation DOJOHomeTableSwagView

@synthesize startTouch, homeMainView;

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.touchDelegate homeTableViewTouchStarted:touches withEvent:event];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.touchDelegate homeTableViewTouchSwiping:touches withEvent:event];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.touchDelegate homeTableViewTouchCancelled];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.touchDelegate homeTableViewTouchCancelled];
}

@end
