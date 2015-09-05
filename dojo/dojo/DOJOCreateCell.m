//
//  DOJOCreateCell.m
//  dojo
//
//  Created by Michael Zuccarino on 1/21/15.
//  Copyright (c) 2015 Michael Zuccarino. All rights reserved.
//

#import "DOJOCreateCell.h"

@implementation DOJOCreateCell

@synthesize delegate, startPoint, dojoIconView, dojoName, payloadLabel, timeLabel, postNumber, followerNumber, shitbutton;

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    
    [self.dojoIconView setFrame:CGRectMake(8, 15, 40, 40)];
    self.dojoIconView.image = [UIImage imageNamed:@"dojoarches.png"];
    self.dojoIconView.contentMode = UIViewContentModeScaleAspectFit;
    self.dojoIconView.backgroundColor = [UIColor colorWithRed:132.0/255.0 green:125.0/255.0 blue:229.0/255.0 alpha:1.0];
    [self.dojoIconView setClipsToBounds:YES];
    [self.dojoIconView.layer setCornerRadius:20];
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
