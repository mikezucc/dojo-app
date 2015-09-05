//
//  DOJOFollowCell.m
//  dojo
//
//  Created by Michael Zuccarino on 1/21/15.
//  Copyright (c) 2015 Michael Zuccarino. All rights reserved.
//

#import "DOJOFollowCell.h"

@implementation DOJOFollowCell

@synthesize delegate, startPoint, profilePicView, payloadLabel, timeLabel, postNumber, pointNumber, shitbutton;

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    [self.profilePicView setFrame:CGRectMake(8, 15, 40, 40)];
    self.profilePicView.contentMode = UIViewContentModeScaleAspectFill;
    [self.profilePicView.layer setCornerRadius:20];
    [self.profilePicView setClipsToBounds:YES];
    
    //self.payloadLabel.dataDetectorTypes = UIDataDetectorTypeLink;
    /*
    NSDictionary *attributesBlue = @ {NSLinkAttributeName : [UIColor colorWithRed:132.0/255.0 green:125.0/255.0 blue:229.0/255.0 alpha:1.0]};
    self.payloadLabel.linkTextAttributes = attributesBlue;
    */
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
