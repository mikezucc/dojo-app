//
//  DOJOCellButton.m
//  dojo
//
//  Created by Michael Zuccarino on 11/23/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import "DOJOCellButton.h"

@implementation DOJOCellButton

@synthesize initialTouchLocation, postNumber, sectionMajor, sectionMinor;

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
    [self tapEnded];
    
}

-(void)tapBegan
{
    [self.touchEventDelegate tapBegan:self.postNumber withSectionMajor:self.sectionMajor withSectionMinor:self.sectionMinor];
}

-(void)tapEnded
{
    [self.touchEventDelegate tapEnded];
}

@end
