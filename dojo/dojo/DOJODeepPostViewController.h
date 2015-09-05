//
//  DOJODeepPostViewController.h
//  Dojo
//
//  Created by Michael Zuccarino on 8/18/15.
//  Copyright (c) 2015 Michael Zuccarino. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DOJODeepPostViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIImageView *postImageview;
@property (strong, nonatomic) IBOutlet UIScrollView *contentScrollView;
@property (strong, nonatomic) IBOutlet UIImageView *upvoteView;
@property (strong, nonatomic) IBOutlet UIImageView *downvoteview;
@property (strong, nonatomic) IBOutlet UILabel *numVotesLabel;
@property (strong, nonatomic) IBOutlet UILabel *numRepostsLabel;

@property (strong, nonatomic) NSString *postDescription;

-(IBAction)closeMe;
-(IBAction)shareButton;
-(IBAction)likeThis;
-(IBAction)dislikeThis;
-(IBAction)repostThis;

@end
