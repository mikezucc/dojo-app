//
//  DOJOAppDelegate.m
//  dojo
//
//  Created by Michael Zuccarino on 7/9/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import "DOJOAppDelegate.h"
#import "DOJOLoginViewController.h"
#import "networkConstants.h"
#import "DOJOPerformAPIRequest.h"

@interface DOJOAppDelegate () <APIRequestDelegate>

@property (strong,nonatomic) DOJOPerformAPIRequest *apiBot;

@end

@implementation DOJOAppDelegate

@synthesize scheduleMessageChecker, checkPayload, apiBot, uploadQueue, shouldLogout, isIphone4;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //Facebook login stuff
    // Whenever a person opens the app, check for a cached session
    @try {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:2.0];
    }
    @catch (NSException *exception) {
        NSLog(@"issues setting up user notification thing");
    }
    @finally {
        NSLog(@"wanky wank");
    }
    
    self.shouldLogout = NO;
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *historyPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"uploadHistory.plist"]];
    
    NSMutableDictionary *historyDict;
    if ([[NSFileManager defaultManager] fileExistsAtPath:historyPath])
    {
        historyDict = [[NSMutableDictionary alloc] initWithContentsOfFile:historyPath];
        NSLog(@"history dict is %@",historyDict);
        
        /*
         AWSS3TransferManager *localTransMan = [AWSS3TransferManager defaultS3TransferManager];
         AWSStaticCredentialsProvider *credentialsProvider = [AWSStaticCredentialsProvider credentialsWithAccessKey:ACCESS_KEY_ID secretKey:SECRET_KEY];
         AWSServiceConfiguration *configuration = [AWSServiceConfiguration configurationWithRegion:AWSRegionUSWest1 credentialsProvider:credentialsProvider];
         [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
         
         NSMutableArray *tasks = [NSMutableArray new];
         
         AWSS3TransferManagerUploadRequest *uploadRequestBig = [AWSS3TransferManagerUploadRequest new];
         uploadRequestBig = self.uploadRequest;
         AWSS3TransferManagerUploadRequest *uploadRequestSmall = [AWSS3TransferManagerUploadRequest new];
         uploadRequestSmall = self.uploadRequest2;
         
         uploadRequestBig.uploadProgress = ^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend){
         dispatch_async(dispatch_get_main_queue(), ^{
         //Update progress.
         DOJOAppDelegate *appdelegate = (DOJOAppDelegate *)[[UIApplication sharedApplication] delegate];
         [appdelegate updateProgessOfUpload:bytesSent totalBytesSent:totalBytesSent totalBytesExpectedToSend:totalBytesExpectedToSend];
         });};
         
         DOJOAppDelegate *appdelegate = (DOJOAppDelegate *)[[UIApplication sharedApplication] delegate];
         
         [appdelegate beginUploadWithKey:codeKey];
         [tasks addObject:[[localTransMan upload:uploadRequestBig] continueWithExecutor:[BFExecutor executorWithDispatchQueue:appdelegate.uploadQueue] withBlock:^id(BFTask *task)
         {
         if (task.error != nil) {
         NSLog(@"Error: [%@]", task.error);
         [appdelegate errorDuringUpload:codeKey];
         //UIAlertView *failureAlert = [[UIAlertView alloc] initWithTitle:@"wait" message:@"could not up yo content" delegate:self cancelButtonTitle:@"ok :[" otherButtonTitles:nil];
         //[failureAlert show];
         } else {
         NSLog(@"completed upload");
         [appdelegate finishedUpload:codeKey];
         }
         return nil;
         }]];
         
         [tasks addObject:[[localTransMan upload:uploadRequestSmall] continueWithExecutor:[BFExecutor executorWithDispatchQueue:appdelegate.uploadQueue] withBlock:^id(BFTask *task) {
         if (task.error != nil) {
         NSLog(@"Error: [%@]", task.error);
         [appdelegate errorDuringUpload:codeKey];
         //UIAlertView *failureAlert = [[UIAlertView alloc] initWithTitle:@"wait" message:@"could not up yo content" delegate:self cancelButtonTitle:@"ok :[" otherButtonTitles:nil];
         //[failureAlert show];
         } else {
         NSLog(@"completed upload");
         //[self.storyboard instantiateViewControllerWithIdentifier:@"sendViewController"];
         //[self performSegueWithIdentifier:@"toSendSegue" sender:self];
         }
         return nil;
         }]];
         
         */
    }

    self.uploadQueue = dispatch_queue_create("annotateUploadQueue", DISPATCH_QUEUE_SERIAL);

    NSFileManager *fMan = [NSFileManager defaultManager];
    error = nil;
    NSArray *directoryContents = [fMan contentsOfDirectoryAtPath:documentsDirectory error:&error];
    //NSLog(@"these are the directory contents %@",directoryContents);
    NSString *match = @"*.jpeg";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF like %@", match];
    NSArray *results = [directoryContents filteredArrayUsingPredicate:predicate];
    //NSLog(@"FILTERED RESULTS \n%@",results);
    for (int i=0;i<[results count];i++)
    {
        NSString *plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:[results objectAtIndex:i]]];
        if([fMan removeItemAtPath:plistPath error:&error])
        {
            NSLog(@"SUCCESS: %@",[results objectAtIndex:i]);
        }
        else
        {
            NSLog(@"FAILURE: %@",[results objectAtIndex:i]);
        }
    }
    
    match = @"*.mov";
    predicate = [NSPredicate predicateWithFormat:@"SELF like %@", match];
    results = [directoryContents filteredArrayUsingPredicate:predicate];
    //NSLog(@"FILTERED RESULTS \n%@",results);
    for (int i=0;i<[results count];i++)
    {
        NSString *plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:[results objectAtIndex:i]]];
        if([fMan removeItemAtPath:plistPath error:&error])
        {
            NSLog(@"SUCCESS: %@",[results objectAtIndex:i]);
        }
        else
        {
            NSLog(@"FAILURE: %@",[results objectAtIndex:i]);
        }
    }
    
    NSArray* temp = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:NSTemporaryDirectory() error:NULL];
    for (NSString *file in temp) {
        [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), file] error:NULL];
    }


    /*
    if (self.scheduleMessageChecker == nil)
    {
        self.scheduleMessageChecker = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(checkNotificationService) userInfo:nil repeats:YES];
    }
    NSLog(@"APP <didFinish> scheduled with %@",self.scheduleMessageChecker);
     */
    [self.window makeKeyAndVisible];
    return YES;
}

-(void)beginUploadWithKey:(NSString *)codeKey
{
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *historyPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"uploadHistory.plist"]];
    
    NSMutableDictionary *historyDict;
    if ([[NSFileManager defaultManager] fileExistsAtPath:historyPath])
    {
        historyDict = [[NSMutableDictionary alloc] initWithContentsOfFile:historyPath];
        [historyDict setObject:@"start" forKey:codeKey];
        [historyDict writeToFile:historyPath atomically:YES];
    }
    else
    {
        historyDict = [[NSMutableDictionary alloc] init];
        [historyDict setObject:@"start" forKey:codeKey];
        [historyDict writeToFile:historyPath atomically:YES];
    }
    NSLog(@"BEGIN UPLOAD>> %@",historyDict);
}

-(void)finishedUpload:(NSString *)codeKey
{
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *historyPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"uploadHistory.plist"]];
    
    NSMutableDictionary *historyDict;
    if ([[NSFileManager defaultManager] fileExistsAtPath:historyPath])
    {
        historyDict = [[NSMutableDictionary alloc] initWithContentsOfFile:historyPath];
        [historyDict setObject:@"done" forKey:codeKey];
        [historyDict writeToFile:historyPath atomically:YES];
    }
    else
    {
        historyDict = [[NSMutableDictionary alloc] init];
        [historyDict setObject:@"done" forKey:codeKey];
        [historyDict writeToFile:historyPath atomically:YES];
    }
    NSLog(@"FINISHED UPLOAD>> %@",historyDict);
}

-(void)errorDuringUpload:(NSString *)codeKey
{
    
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *historyPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"uploadHistory.plist"]];
    
    NSMutableDictionary *historyDict;
    if ([[NSFileManager defaultManager] fileExistsAtPath:historyPath])
    {
        historyDict = [[NSMutableDictionary alloc] initWithContentsOfFile:historyPath];
        [historyDict setObject:@"error" forKey:codeKey];
        [historyDict writeToFile:historyPath atomically:YES];
    }
    else
    {
        historyDict = [[NSMutableDictionary alloc] init];
        [historyDict setObject:@"error" forKey:codeKey];
        [historyDict writeToFile:historyPath atomically:YES];
    }
    NSLog(@"ERROR UPLOAD>> %@",historyDict);
}

-(void)updateProgessOfUpload:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t) totalBytesExpectedToSend
{
    NSLog(@"APP DELEGATE >> bytes sent %ld, totalByes sent %ld, totalBytesExpected to send %ld",(long)bytesSent,(long)totalBytesSent,(long)totalBytesExpectedToSend);
}

-(void)checkNotificationService
{
    /*
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"userProperties.plist"]];
    NSDictionary *userProperties = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[[userProperties objectForKey:@"userEmail"]] forKeys:@[@"email"]];
    NSData *result =[NSJSONSerialization dataWithJSONObject:dataDict options:0 error:&error];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%sgetNotificationService.php",SERVERADDRESS]]];
    
    //customize request information
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%ld", (long)dataDict.count] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:result];
    
    NSURLResponse *response = nil;
    error = nil;
    
    //fire the request and wait for response
    result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSLog(@"result is %@", result);
    checkPayload = [NSJSONSerialization JSONObjectWithData:result options:NSJSONReadingAllowFragments error:&error];
    NSString *decodedString = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
    NSLog(@"GET checkPayload LIST IS \n%@",checkPayload);
    
    NSString *continueNotification = [checkPayload objectAtIndex:0];
    NSArray *newPostsArr = [checkPayload objectAtIndex:1];
    NSArray *newMessageArr = [checkPayload objectAtIndex:2];
    
    if ([continueNotification isEqualToString:@"yes"])
    {
        UILocalNotification* localNotification = [[UILocalNotification alloc] init];
        localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:10];
        localNotification.alertBody = [NSString stringWithFormat:@"%d unseen posts, %d unseen msgs",(int)[newPostsArr count],(int)[newMessageArr count]];
        localNotification.timeZone = [NSTimeZone defaultTimeZone];
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    }
    else
    {
        // do nuffin
    }
*/
    
    //NSLog(@"decodestring = GET HOME LIST IS %@",decodedString);
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    /*
    NSLog(@"scheduled with %@",self.scheduleMessageChecker);
    if (self.scheduleMessageChecker == nil)
    {
        self.scheduleMessageChecker = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(checkNotificationService) userInfo:nil repeats:YES];
    }
    */
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    if ( application.applicationState == UIApplicationStateInactive || application.applicationState == UIApplicationStateBackground  )
    {
        //opened from a push notification when the app was on background
        
    }
}

-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *keysPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"keysNkrates.plist"]];
    NSDictionary *meInfo = [[NSDictionary alloc] initWithContentsOfFile:keysPath];
    
    NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[[meInfo objectForKey:@"username"],[meInfo objectForKey:@"token"]] forKeys:@[@"username",@"token"]];
    NSData *result =[NSJSONSerialization dataWithJSONObject:dataDict options:0 error:&error];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%sgetNotificationService.php",SERVERADDRESS]]];
    
    //customize request information
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%ld", (long)dataDict.count] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:result];
    
    NSURLResponse *response = nil;
    error = nil;
    
    //fire the request and wait for response
    result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSLog(@"result is %@", result);
    checkPayload = [NSJSONSerialization JSONObjectWithData:result options:NSJSONReadingAllowFragments error:&error];
    NSString *decodedString = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
    NSLog(@"GET checkPayload LIST IS \n%@",checkPayload);
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[checkPayload count]];
    if ([checkPayload count] > 0)
    {
        NSDictionary *payload = [checkPayload objectAtIndex:0];
        UILocalNotification* localNotification = [[UILocalNotification alloc] init];
        localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:2];
        localNotification.alertBody = [NSString stringWithFormat:@"%@",[payload objectForKey:@"payload"]];
        localNotification.timeZone = [NSTimeZone defaultTimeZone];
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        completionHandler(UIBackgroundFetchResultNewData);
    }
    else
    {
        // do smufftin
        completionHandler(UIBackgroundFetchResultNoData);
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    // Handle the user leaving the app while the Facebook login dialog is being shown
    // For example: when the user presses the iOS "home" button while the login dialog is active
    /*
    NSLog(@"APP <didBecomeACTIVE> scheduled with %@",self.scheduleMessageChecker);
    if (self.scheduleMessageChecker == nil)
    {
        self.scheduleMessageChecker = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(checkNotificationService) userInfo:nil repeats:YES];
    }
    */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *historyPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"uploadHistory.plist"]];
    
    NSMutableDictionary *historyDict;
    if ([[NSFileManager defaultManager] fileExistsAtPath:historyPath])
    {
        historyDict = [[NSMutableDictionary alloc] initWithContentsOfFile:historyPath];
        NSLog(@"history dict is %@",historyDict);
        
        /*
         AWSS3TransferManager *localTransMan = [AWSS3TransferManager defaultS3TransferManager];
         AWSStaticCredentialsProvider *credentialsProvider = [AWSStaticCredentialsProvider credentialsWithAccessKey:ACCESS_KEY_ID secretKey:SECRET_KEY];
         AWSServiceConfiguration *configuration = [AWSServiceConfiguration configurationWithRegion:AWSRegionUSWest1 credentialsProvider:credentialsProvider];
         [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
         
         NSMutableArray *tasks = [NSMutableArray new];
         
         AWSS3TransferManagerUploadRequest *uploadRequestBig = [AWSS3TransferManagerUploadRequest new];
         uploadRequestBig = self.uploadRequest;
         AWSS3TransferManagerUploadRequest *uploadRequestSmall = [AWSS3TransferManagerUploadRequest new];
         uploadRequestSmall = self.uploadRequest2;
         
         uploadRequestBig.uploadProgress = ^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend){
         dispatch_async(dispatch_get_main_queue(), ^{
         //Update progress.
         DOJOAppDelegate *appdelegate = (DOJOAppDelegate *)[[UIApplication sharedApplication] delegate];
         [appdelegate updateProgessOfUpload:bytesSent totalBytesSent:totalBytesSent totalBytesExpectedToSend:totalBytesExpectedToSend];
         });};
         
         DOJOAppDelegate *appdelegate = (DOJOAppDelegate *)[[UIApplication sharedApplication] delegate];
         
         [appdelegate beginUploadWithKey:codeKey];
         [tasks addObject:[[localTransMan upload:uploadRequestBig] continueWithExecutor:[BFExecutor executorWithDispatchQueue:appdelegate.uploadQueue] withBlock:^id(BFTask *task)
         {
         if (task.error != nil) {
         NSLog(@"Error: [%@]", task.error);
         [appdelegate errorDuringUpload:codeKey];
         //UIAlertView *failureAlert = [[UIAlertView alloc] initWithTitle:@"wait" message:@"could not up yo content" delegate:self cancelButtonTitle:@"ok :[" otherButtonTitles:nil];
         //[failureAlert show];
         } else {
         NSLog(@"completed upload");
         [appdelegate finishedUpload:codeKey];
         }
         return nil;
         }]];
         
         [tasks addObject:[[localTransMan upload:uploadRequestSmall] continueWithExecutor:[BFExecutor executorWithDispatchQueue:appdelegate.uploadQueue] withBlock:^id(BFTask *task) {
         if (task.error != nil) {
         NSLog(@"Error: [%@]", task.error);
         [appdelegate errorDuringUpload:codeKey];
         //UIAlertView *failureAlert = [[UIAlertView alloc] initWithTitle:@"wait" message:@"could not up yo content" delegate:self cancelButtonTitle:@"ok :[" otherButtonTitles:nil];
         //[failureAlert show];
         } else {
         NSLog(@"completed upload");
         //[self.storyboard instantiateViewControllerWithIdentifier:@"sendViewController"];
         //[self performSegueWithIdentifier:@"toSendSegue" sender:self];
         }
         return nil;
         }]];
         
         */
    }
    
    self.uploadQueue = dispatch_queue_create("annotateUploadQueue", DISPATCH_QUEUE_SERIAL);
    
    NSFileManager *fMan = [NSFileManager defaultManager];
    error = nil;
    NSArray *directoryContents = [fMan contentsOfDirectoryAtPath:documentsDirectory error:&error];
    //NSLog(@"these are the directory contents %@",directoryContents);
    NSString *match = @"*.jpeg";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF like %@", match];
    NSArray *results = [directoryContents filteredArrayUsingPredicate:predicate];
    //NSLog(@"FILTERED RESULTS \n%@",results);
    for (int i=0;i<[results count];i++)
    {
        NSString *plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:[results objectAtIndex:i]]];
        if([fMan removeItemAtPath:plistPath error:&error])
        {
            NSLog(@"SUCCESS: %@",[results objectAtIndex:i]);
        }
        else
        {
            NSLog(@"FAILURE: %@",[results objectAtIndex:i]);
        }
    }
    
    match = @"*.mov";
    predicate = [NSPredicate predicateWithFormat:@"SELF like %@", match];
    results = [directoryContents filteredArrayUsingPredicate:predicate];
    //NSLog(@"FILTERED RESULTS \n%@",results);
    for (int i=0;i<[results count];i++)
    {
        NSString *plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:[results objectAtIndex:i]]];
        if([fMan removeItemAtPath:plistPath error:&error])
        {
            NSLog(@"SUCCESS: %@",[results objectAtIndex:i]);
        }
        else
        {
            NSLog(@"FAILURE: %@",[results objectAtIndex:i]);
        }
    }
    
    NSArray* temp = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:NSTemporaryDirectory() error:NULL];
    for (NSString *file in temp) {
        [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), file] error:NULL];
    }
}

@end
