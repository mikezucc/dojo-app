//
//  DOJOMessageBoardViewController.h
//  dojo
//
//  Created by Michael Zuccarino on 9/23/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DOJOMessageCell.h"

@interface DOJOMessageBoardViewController : UIViewController

@property (strong, nonatomic) UICollectionView *messageCollectionView;

@property (strong, nonatomic) IBOutlet UITextView *messageField;
@property (strong, nonatomic) IBOutlet UIView *fieldContainer;
@property (strong, nonatomic) DOJOMessageCell *messageCell;

@property (strong, nonatomic) NSString *userEmail;
@property (strong, nonatomic) NSDictionary *dojoData;

@property (strong, nonatomic) NSArray *boardData;

//@property (weak) DOJOMessageCell *messageCell;

@property (strong, nonatomic) NSTimer *bongReloader;

-(IBAction)returnToDojo:(id)sender;

@property BOOL preventJumping;

@end
