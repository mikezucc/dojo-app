//
//  DojoPageMessageView.h
//  dojo
//
//  Created by Michael Zuccarino on 10/29/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DOJOMessageCell.h"
#import "networkConstants.h"

@protocol scrolled <NSObject>

@required
-(void)messageViewWasScrolled;
-(void)cellSelected;
-(void)detectedTapInMessageView;

@end

@interface DojoPageMessageView : UIView <UITableViewDataSource, UITableViewDelegate, NSURLConnectionDelegate, NSURLConnectionDataDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) UITableView *messageCollectionView;
@property (strong, nonatomic) DOJOMessageCell *messageCell;
@property (strong, nonatomic) UIRefreshControl *refreshSwag;
@property (strong, nonatomic) UIImageView *backgroundImageView;
//@property (strong, nonatomic) UIView *transLayer;

@property (strong, nonatomic) UITapGestureRecognizer *tapRecog;

@property (strong, nonatomic) NSArray *boardData;
@property (strong, nonatomic) NSString *userEmail;
@property (strong, nonatomic) NSDictionary *dojoData;
@property (strong, nonatomic) NSTimer *bongReloader;
@property (nonatomic) NSInteger delay;

@property (nonatomic, weak) id<scrolled> delegate;
@property BOOL isMoving;
@property (nonatomic) CGPoint initialTouchLocation;
@property (nonatomic) BOOL isAPost;
@property (strong, nonatomic) NSDictionary *postDict;

@property (nonatomic) BOOL isCustomReload;

-(void)reloadTheBoard;
-(void)customReloadTheBoard;
-(void)initiateTheBongReloader;
-(void)endLoadSesh;
-(void)genericRefresh;

@end
