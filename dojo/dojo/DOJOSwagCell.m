//
//  DOJOSwagCell.m
//  dojo
//
//  Created by Michael Zuccarino on 12/11/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import "DOJOSwagCell.h"

@implementation DOJOSwagCell

@synthesize startTouch, poopdelegate, colorbar, peekButton, dojoNameLabel, postTextLabel, initialColor, startRect, startingDojoPoint, startingPeekPoint, cellPath, messageView, containsActiveMessageView, isRunningActiveMessageView, notiBubble, infoLabel;

-(void)awakeFromNib
{
    [self.peekButton setHidden:YES];
    [self.peekButton.layer setCornerRadius:self.peekButton.frame.size.height/2];
    self.peekButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.dojoNameLabel.userInteractionEnabled = NO;
    self.postTextLabel.userInteractionEnabled = NO;
    [self.peekButton setClipsToBounds:YES];
    [self.notiBubble.layer setCornerRadius:7];

}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UIView *v = self.contentView;
    UIView *prev;
    while (v.superview && [v.superview isKindOfClass:[UIView class]]){
        v = v.superview;
        prev = v;
    }
    self.startTouch = [[touches anyObject] locationInView:v];
    self.initialColor = self.colorbar.backgroundColor;
    self.startRect = self.colorbar.frame;
    self.startingPeekPoint = self.peekButton.frame.origin;
    self.startingDojoPoint = self.dojoNameLabel.frame.origin;
    [self.poopdelegate touchBeginning:self.cellPath];
    NSLog(@"detected touch in swag cell");
}

-(void)engageChat
{
    [self.poopdelegate chatEngaged:self.cellPath];
}

-(void)selectThisCell
{
    [self.poopdelegate selectCell:self.cellPath];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UIView *v = self.contentView;
    UIView *prev;
    while (v.superview && [v.superview isKindOfClass:[UIView class]]){
        v = v.superview;
        prev = v;
    }
    CGPoint nowTouch = [((UITouch *)[touches anyObject]) locationInView:v];
    
    [self.poopdelegate touchSwiping:[NSNumber numberWithFloat:(nowTouch.x-startTouch.x)]];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.poopdelegate touchSwipeCancelled];
    
    self.colorbar.frame = self.startRect;
    [self.colorbar setBackgroundColor:self.initialColor];
    
    CGRect frm = self.peekButton.frame;
    frm.origin.x = self.startingPeekPoint.x;
    self.peekButton.frame = frm;
}

-(IBAction)egnageChatThroughButton:(id)sender
{
    [self engageChat];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.colorbar.frame = self.startRect;
    [self.colorbar setBackgroundColor:self.initialColor];
    
    CGRect frm = self.dojoNameLabel.frame;
    frm.origin.x = self.startingDojoPoint.x;
    self.dojoNameLabel.frame = frm;
    
    frm = self.peekButton.frame;
    frm.origin.x = self.startingPeekPoint.x;
    self.peekButton.frame = frm;
}

@end
