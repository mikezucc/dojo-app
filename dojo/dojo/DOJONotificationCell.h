//
//  DOJONotificationCell.h
//  dojo
//
//  Created by Michael Zuccarino on 12/12/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DOJOPeekButton.h"

@protocol NotiCellegate <NSObject>

@required
-(void)swipeStarted;
-(void)swipeIsMoving:(NSNumber *)distance;
-(void)swipeLetGoforRow:(NSInteger)row;
-(void)swipeCanceled;
@end

@interface DOJONotificationCell : UITableViewCell

@property (weak, nonatomic) id<NotiCellegate> delegate;
@property (nonatomic) CGPoint startPoint;

@property (strong, nonatomic) IBOutlet UILabel *majorLabel;
@property (strong, nonatomic) IBOutlet UILabel *postTextLabel;
@property (strong, nonatomic) IBOutlet DOJOPeekButton *peekButton;
@property (strong, nonatomic) IBOutlet UIImageView *requestIcon;

@end
