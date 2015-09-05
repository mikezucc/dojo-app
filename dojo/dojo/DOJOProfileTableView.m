//
//  DOJOProfileTableView.m
//  dojo
//
//  Created by Michael Zuccarino on 1/5/15.
//  Copyright (c) 2015 Michael Zuccarino. All rights reserved.
//

#import "DOJOProfileTableView.h"

@implementation DOJOProfileTableView

@synthesize touchDelegate;

/*
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touches began in the table view");
    NSIndexPath *iPath = [NSIndexPath indexPathForItem:0 inSection:0];
    UITableViewCell *cell = (UITableViewCell *)[self cellForRowAtIndexPath:iPath];
    CGRect frm = cell.frame;
    if (frm.origin.y <= [[touches anyObject] locationInView:self.backgroundView].y)
    {
        NSLog(@"within there");
        [self.touchDelegate tableTouchBegin:[[touches anyObject] locationInView:self.backgroundView]];
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSIndexPath *iPath = [NSIndexPath indexPathForItem:0 inSection:0];
    UITableViewCell *cell = (UITableViewCell *)[self cellForRowAtIndexPath:iPath];
    CGRect frm = cell.frame;
    if (frm.origin.y <= [[touches anyObject] locationInView:self.backgroundView].y)
    {
        [self.touchDelegate tableTouchMoved:[[touches anyObject] locationInView:self.backgroundView]];
    }
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSIndexPath *iPath = [NSIndexPath indexPathForItem:0 inSection:0];
    UITableViewCell *cell = (UITableViewCell *)[self cellForRowAtIndexPath:iPath];
    CGRect frm = cell.frame;
    if (frm.origin.y <= [[touches anyObject] locationInView:self.backgroundView].y)
    {
        [self.touchDelegate tableTouchCancelled:[[touches anyObject] locationInView:self.backgroundView]];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSIndexPath *iPath = [NSIndexPath indexPathForItem:0 inSection:0];
    UITableViewCell *cell = (UITableViewCell *)[self cellForRowAtIndexPath:iPath];
    CGRect frm = cell.frame;
    if (frm.origin.y <= [[touches anyObject] locationInView:self.backgroundView].y)
    {
        [self.touchDelegate tableTouchEnded:[[touches anyObject] locationInView:self.backgroundView]];
    }
}
*/
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
