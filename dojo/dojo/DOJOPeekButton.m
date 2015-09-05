//
//  DOJOPeekButton.m
//  dojo
//
//  Created by Michael Zuccarino on 12/11/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import "DOJOPeekButton.h"

@implementation DOJOPeekButton

@synthesize initialTouchLocation, postNumber, sectionMajor, sectionMinor;

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touch event begin, count is %ld",(long) touches.count);
    UITouch *singleTouch = [touches anyObject];
    NSLog(@"single touch is %@",singleTouch);
    self.initialTouchLocation = [singleTouch locationInView:self];
    [self tapBegan];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.delegate tapMovedPeek];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self tapEnded];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self tapEnded];
}

-(void)tapBegan
{
    [self.delegate tapBegan:self.postNumber withSectionMajor:self.sectionMajor withSectionMinor:self.sectionMinor];
}

-(void)tapEnded
{
    [self.delegate tapEnded];
}

@end
