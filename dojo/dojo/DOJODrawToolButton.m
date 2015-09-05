//
//  DOJODrawToolButton.m
//  dojo
//
//  Created by Michael Zuccarino on 1/15/15.
//  Copyright (c) 2015 Michael Zuccarino. All rights reserved.
//

#import "DOJODrawToolButton.h"

@implementation DOJODrawToolButton

@synthesize startPoint;

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.startPoint = [[touches anyObject] locationInView:self];
    [self.drawDelegate activatedInDrawButton:[touches anyObject]];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touch is now at %fx %fy",[[touches anyObject] locationInView:self].x,[[touches anyObject] locationInView:self].y);
    [self.drawDelegate movingInDrawButton:[touches anyObject]];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
     NSLog(@"touch ended at %fx %fy",[[touches anyObject] locationInView:self].x,[[touches anyObject] locationInView:self].y);
    [self.drawDelegate releasedInDrawButton:[touches anyObject]];
}

@end
