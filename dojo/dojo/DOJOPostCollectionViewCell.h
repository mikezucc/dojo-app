//
//  DOJOPostCollectionViewCell.h
//  dojo
//
//  Created by Michael Zuccarino on 10/28/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
//#import "DOJOHomeViewController.h"
#import "DOJOCellButton.h"

@interface DOJOPostCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) UIImageView *cellFace;
@property (strong, nonatomic) DOJOCellButton *cellButton;
@property (strong, nonatomic) UITextView *cellDescription;
@property (strong, nonatomic) MPMoviePlayerController *moviePlayer;
//@property DOJOHomeViewController *homeVC;

@property (strong, nonatomic) NSIndexPath *indexPath;

@end
