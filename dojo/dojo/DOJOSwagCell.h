//
//  DOJOSwagCell.h
//  dojo
//
//  Created by Michael Zuccarino on 12/11/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DOJOPeekButton.h"
#import "networkConstants.h"
#import "DojoPageMessageView.h"

@protocol Swagdelete <NSObject>

@optional
-(void)touchBeginning:(NSIndexPath *)cellTag;
-(void)touchSwiping:(NSNumber *)distanceMoved;
-(void)touchSwipeCancelled;
-(void)chatEngaged:(NSIndexPath *)cellPath;
-(void)selectCell:(NSIndexPath *)cellPath;

@end


@interface DOJOSwagCell : UITableViewCell

@property (strong, nonatomic) IBOutlet DojoPageMessageView *messageView;
@property (nonatomic) BOOL containsActiveMessageView;
@property (nonatomic) BOOL isRunningActiveMessageView;

@property (nonatomic, weak) id<Swagdelete> poopdelegate;
@property (nonatomic) CGPoint startTouch;
@property (nonatomic) CGRect startRect;
@property (nonatomic) CGPoint startingDojoPoint;
@property (nonatomic) CGPoint startingPeekPoint;
@property (strong, nonatomic) NSIndexPath *cellPath;

@property (strong, nonatomic) UIColor *initialColor;

@property (strong, nonatomic) IBOutlet UILabel *dojoNameLabel;
@property (strong, nonatomic) IBOutlet UITextView *postTextLabel;
@property (strong, nonatomic) IBOutlet DOJOPeekButton *peekButton;
@property (strong, nonatomic) IBOutlet UIButton *chatButton;
@property (strong, nonatomic) IBOutlet UIImageView *colorbar;
@property (strong, nonatomic) IBOutlet UIImageView *notiBubble;
@property (strong, nonatomic) IBOutlet UILabel *infoLabel;

@end
