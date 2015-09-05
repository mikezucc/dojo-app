//
//  DOJOCommentCell.m
//  dojo
//
//  Created by Michael Zuccarino on 1/21/15.
//  Copyright (c) 2015 Michael Zuccarino. All rights reserved.
//

#import "DOJOCommentCell.h"

@implementation DOJOCommentCell

@synthesize profilePicView, payloadLabel, postPicView, commentLabel, timeLabel, startPoint, delegate, shitbutton;

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    
    //self.commentLabel.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    self.commentLabel.textColor = [UIColor colorWithWhite:0.7 alpha:0.9];
    
    self.profilePicView.contentMode = UIViewContentModeScaleAspectFill;
    
    [self.profilePicView setClipsToBounds:YES];
    [self.profilePicView setFrame:CGRectMake(8, 17, 40, 40)];
    [self.profilePicView.layer setCornerRadius:20];
    
    [self.postPicView setFrame:CGRectMake(257, 8, 54, 54)];
    [self.postPicView setClipsToBounds:YES];
    self.postPicView.backgroundColor = [UIColor colorWithRed:132.0/255.0 green:125.0/255.0 blue:229.0/255.0 alpha:1.0];
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
