//
//  DOJOSampleView.h
//  dojo
//
//  Created by Michael Zuccarino on 12/11/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#define ACCESS_KEY_ID                 @""

#define SECRET_KEY                    @""

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "networkConstants.h"
#import "AWSiOSSDKv2/AWSS3TransferManager.h"
#import "AWSiOSSDKv2/AWSS3.h"
#import <AWSiOSSDKv2/AWSCredentialsProvider.h>
#import <AWSiOSSDKv2/AWSS3PreSignedURL.h>
#import <AWSiOSSDKv2/AWSCore.h>

@protocol SampleViewDelegate <NSObject>

@optional
-(void)didEndZooming;

@end

@interface DOJOSampleView : UIView <MPMediaPlayback>

@property (nonatomic, weak) id<SampleViewDelegate> delegate;

@property (nonatomic, strong) AWSS3TransferManagerDownloadRequest *downloadRequest;
@property (strong, nonatomic) UIImageView *imagePost;
@property (strong, nonatomic) MPMoviePlayerController *videoPlayer;
@property (strong, nonatomic) UIWebView *linkViewer;
@property (strong, nonatomic) UITextView *postDescription;

@property (strong, nonatomic) NSArray *dojoPostList;
@property (nonatomic, strong) NSDictionary *selectedPostInfo;
@property (strong, nonatomic) NSString *postType;

@property (strong, nonatomic) NSMutableArray *activeDownloads;
@property (strong, nonatomic) NSMutableArray *activeMovieDownloads;

@property (strong, nonatomic) NSString *userEmail;

@property (strong, nonatomic) NSNumber *currentPost;

@property (nonatomic, strong) NSString *parentType;

@property (nonatomic) BOOL zoomable;
@property (nonatomic) CGPoint touchedFirst;
@property (nonatomic) NSInteger touchCount;

-(void)loadAPost;
-(void)initMinor;

@end
