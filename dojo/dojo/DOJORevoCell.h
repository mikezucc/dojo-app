//
//  DOJORevoCell.h
//  dojo
//
//  Created by Michael Zuccarino on 12/25/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "DojoPageMessageView.h"

@protocol RevolDelegate <NSObject>

@optional
-(void)touchBeginning:(NSIndexPath *)cellTag;
-(void)touchSwiping:(NSNumber *)distanceMoved;
-(void)touchSwipeCancelled;
-(void)chatEngaged:(NSIndexPath *)cellPath;
-(void)selectCell:(NSIndexPath *)cellPath;

@end

@interface DOJORevoCell : UITableViewCell

@property (strong, nonatomic) IBOutlet DojoPageMessageView *messageView;
@property (nonatomic) BOOL containsActiveMessageView;
@property (nonatomic) BOOL isRunningActiveMessageView;
@property (strong, nonatomic) NSIndexPath *cellPath;
@property (nonatomic, weak) id<RevolDelegate> delegate;

@property (strong, nonatomic) IBOutlet UIImageView *profilePicture;
@property (strong, nonatomic) IBOutlet UIImageView *imagePostView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UIButton *playButton;
@property (strong, nonatomic) IBOutlet UIButton *upvoteButton;
@property (strong, nonatomic) IBOutlet UIButton *downvoteButton;
@property (strong, nonatomic) IBOutlet UILabel *postDescription;
@property (strong, nonatomic) IBOutlet UIImageView *postDescriptionBack;
@property (strong, nonatomic) IBOutlet UIImageView *upvoteBackground;
@property (strong, nonatomic) IBOutlet UIImageView *downvoteBackground;
@property (strong, nonatomic) IBOutlet UIImageView *commentBackground;
@property (strong, nonatomic) IBOutlet UIImageView *shareBackground;
@property (strong, nonatomic) IBOutlet UIButton *commentButton;
@property (strong, nonatomic) IBOutlet UIButton *shareButton;
@property (strong, nonatomic) IBOutlet UIImageView *commentestIcon;
@property (strong, nonatomic) IBOutlet UIButton *deleteButton;
@property (strong, nonatomic) IBOutlet UIImageView *deleteIcon;
@property (strong, nonatomic) IBOutlet UILabel *numberOfCommentsLabel;
@property (strong, nonatomic) IBOutlet UIImageView *upthumb;
@property (strong, nonatomic) IBOutlet UIImageView *downthumb;
@property (strong, nonatomic) IBOutlet UIImageView *commentIcon;
@property (strong, nonatomic) IBOutlet UITextView *textpostview;

@property (strong, nonatomic) IBOutlet UILabel *upvoteCount;
@property (strong, nonatomic) IBOutlet UILabel *downvoteCount;

@property (strong, nonatomic) IBOutlet UILabel *repostCount;

@property (strong, nonatomic) IBOutlet UILabel *timestamp;

@property (strong, nonatomic) MPMoviePlayerController *moviePlayer;

@property (nonatomic) float rotateval;
@property (strong, nonatomic) NSTimer *colorRotater;
@property (strong, nonatomic) NSIndexPath *indexPath;

@end
