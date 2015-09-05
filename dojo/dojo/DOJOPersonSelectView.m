//
//  DOJOPersonSelectView.m
//  dojo
//
//  Created by Michael Zuccarino on 1/6/15.
//  Copyright (c) 2015 Michael Zuccarino. All rights reserved.
//

#import "DOJOPersonSelectView.h"

@implementation DOJOPersonSelectView

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touches began in the table view");
    [self.selectdelegate selectTouchBegin:[[touches anyObject] locationInView:self]];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.selectdelegate selectTouchMoved:[touches anyObject]];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.selectdelegate selectTouchCancelled:[[touches anyObject] locationInView:self]];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.selectdelegate selectTouchEnded:[[touches anyObject] locationInView:self]];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
