//
//  DOJOCaptureButton.m
//  dojo
//
//  Created by Michael Zuccarino on 12/13/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import "DOJOCaptureButton.h"

@implementation DOJOCaptureButton

@synthesize delegate;

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.delegate touchedAt:[NSNumber numberWithFloat:[(UITouch *)[touches anyObject] locationInView:self].x]];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.delegate touchIsOfPercentage:[NSNumber numberWithFloat:[(UITouch *)[touches anyObject] locationInView:self].x]];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.delegate touchLiftedAt:[NSNumber numberWithFloat:[(UITouch *)[touches anyObject] locationInView:self].x]];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

@end
