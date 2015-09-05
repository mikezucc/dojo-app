//
//  DOJOAppDelegate.h
//  dojo
//
//  Created by Michael Zuccarino on 7/9/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DOJOAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSTimer *scheduleMessageChecker;
@property (strong, nonatomic) NSArray *checkPayload;
-(void)checkNotificationService;

@property (strong, nonatomic) dispatch_queue_t uploadQueue;

-(void)errorDuringUpload:(NSString *)codeKey;
-(void)updateProgessOfUpload:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t) totalBytesExpectedToSend;
-(void)finishedUpload:(NSString *)codeKey;
-(void)beginUploadWithKey:(NSString *)codeKey;

@property (nonatomic) BOOL shouldLogout;
@property (nonatomic) BOOL isIphone4;

@end
