//
//  DOJORevoCell.m
//  dojo
//
//  Created by Michael Zuccarino on 12/25/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import "DOJORevoCell.h"

@implementation DOJORevoCell

@synthesize playButton, postDescription, postDescriptionBack, profilePicture, repostCount, rotateval, textpostview, timestamp, upthumb, upvoteCount, upvoteBackground, upvoteButton, imagePostView, indexPath, isRunningActiveMessageView, shareButton, shareBackground, delegate, downthumb, downvoteBackground, downvoteButton, downvoteCount, deleteIcon, deleteButton, moviePlayer, messageView, commentestIcon, cellPath, colorRotater, commentBackground, commentIcon, commentButton, containsActiveMessageView, nameLabel, numberOfCommentsLabel;

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    self.imagePostView.contentMode = UIViewContentModeScaleAspectFill;
    [self.imagePostView setClipsToBounds:YES];
    
    self.profilePicture.contentMode = UIViewContentModeScaleAspectFill;
}

-(void)prepareForReuse
{
    self.textpostview.editable = YES;
    self.textpostview.editable = NO;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(IBAction)engageChat:(id)sender
{
    [self.delegate chatEngaged:self.cellPath];
}

@end
