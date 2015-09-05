//
//  DOJOPostCell.m
//  dojo
//
//  Created by Michael Zuccarino on 1/21/15.
//  Copyright (c) 2015 Michael Zuccarino. All rights reserved.
//

#import "DOJOPostCell.h"

@implementation DOJOPostCell

@synthesize delegate, startPoint, payloadLabel, timeLabel, profilePicView, postView, descriptionLabel, shitbutton;

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    
    [self.postView setFrame:CGRectMake(257, 12, 54, 54)];
    [self.postView setClipsToBounds:YES];
    self.postView.backgroundColor = [UIColor colorWithRed:132.0/255.0 green:125.0/255.0 blue:229.0/255.0 alpha:1.0];
    self.postView.contentMode = UIViewContentModeScaleAspectFill;
    
    
    self.profilePicView.contentMode = UIViewContentModeScaleAspectFill;
    [self.profilePicView setClipsToBounds:YES];
    [self.profilePicView setFrame:CGRectMake(8, 15, 40, 40)];
    [self.profilePicView.layer setCornerRadius:20];
    
    self.descriptionLabel.textColor = [UIColor colorWithWhite:0.7 alpha:0.9];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

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
