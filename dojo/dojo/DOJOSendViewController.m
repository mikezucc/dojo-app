//
//  DOJOSendViewController.m
//  dojo
//
//  Created by Kian Anderson on 7/13/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import "DOJOSendViewController.h"
#import "DOJOPerformAPIRequest.h"

@interface DOJOSendViewController () <APIRequestDelegate>

@property dispatch_queue_t uploadQueue;
@property (strong, nonatomic) DOJOPerformAPIRequest *apiBot;

@end

@implementation DOJOSendViewController

@synthesize sendViewBox, userEmail, postDescription, postHash, postButton, isRepost, apiBot;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.isRepost = NO;
        
    }
    return self;
}

- (void)viewDidLoad
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"userProperties.plist"]];
    NSDictionary *dictToStore = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    
    userEmail = [dictToStore valueForKey:@"email"];
    
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString *widePath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"isWidescreen.plist"]];
    
    NSDictionary *widescreenDict = [[NSDictionary alloc] initWithContentsOfFile:widePath];
    
    NSString *wideString = [[NSString alloc] initWithString:[widescreenDict valueForKeyPath:@"widescreen"]];
    
    float adjustHeight;
    if ([wideString isEqualToString:@"not"])
    {
        adjustHeight = 120;
    }
    else
    {
        adjustHeight = 120;
    }
    
    self.uploadQueue = dispatch_queue_create("executorQueue", DISPATCH_QUEUE_SERIAL);
    NSLog(@"tried to add in the ****ing button");
    
    self.apiBot = [[DOJOPerformAPIRequest alloc] init];
    self.apiBot.delegate = self;
}

-(void)viewWillAppear:(BOOL)animated
{
    //[postButton setTitleColor:[UIColor colorWithRed:0.29019 green:0.56471 blue:0.88627 alpha:1.0] forState:UIControlStateNormal];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"userProperties.plist"]];
    //NSDictionary *dictToStore = [[NSDictionary alloc] initWithObjects:@[userEmail] forKeys:@[@"userEmail"]];
    NSDictionary *loadedDict = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    userEmail = [loadedDict valueForKey:@"userEmail"];
    
    plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"didPost.plist"]];
    NSDictionary *didpostdict = [[NSDictionary alloc] initWithObjects:@[@"no"] forKeys:@[@"didPost"]];
    [didpostdict writeToFile:plistPath atomically:YES];
    
    postButton = [[UIButton alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-57, self.view.frame.size.width, 57)];
    [postButton addTarget:self action:@selector(postToDojo:) forControlEvents:UIControlEventTouchUpInside];
    [postButton setTitle:(self.isRepost ? @"REPOST" : @"POST") forState:UIControlStateNormal];
    //[postButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [postButton setBackgroundColor:[UIColor colorWithRed:132.0/255.0 green:125.0/255.0 blue:229.0/255.0 alpha:1.0]];
    [postButton.titleLabel setFont:[UIFont fontWithName:@"Avenir-Roman" size:29.0]];
    [postButton.titleLabel setTextColor:[UIColor whiteColor]];//[UIColor colorWithRed:0.29019 green:0.56471 blue:0.88627 alpha:1.0]];
    
    //[self.view insertSubview:cameraButton atIndex:[[self.view subviews] count]];
    [self.view addSubview:postButton];
    
    NSLog(@"before reload swag");
    NSLog(@"is %@ repost, with %@ posthash", self.isRepost ? @"" : @"not",self.postHash);
    self.sendViewBox.isRepost = self.isRepost;
    self.sendViewBox.posthash = postHash;
    [self.sendViewBox reloadTheSwag];
    NSLog(@"after reload swag");    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)postedToDojos
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)postToDojo:(UIButton *)button
{
    //LOAD WHOLE RESULTS LIST
    NSArray *resultLoadedArray = self.sendViewBox.selectedList;
    NSLog(@"resultLoadedArray is %@", resultLoadedArray);
    
    [self.postButton setTitle:@"APPROVING" forState:UIControlStateNormal];
    
    [self.apiBot postToDojos:resultLoadedArray withHash:postHash withDescription:postDescription isRepost:self.isRepost];
    
    /*
    __weak DOJOSendViewController *weakSelf = self;
    self.uploadRequest.uploadProgress =  ^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend){
        dispatch_async(dispatch_get_main_queue(), ^{
            //Update progress.
            DOJOSendViewController *strongSelf = weakSelf;
            [strongSelf updateProgessOfUpload:bytesSent totalBytesSent:totalBytesSent totalBytesExpectedToSend:totalBytesExpectedToSend];
        });};
     */
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
    
    [tasks addObject:[[localTransMan upload:uploadRequestBig] continueWithExecutor:[BFExecutor executorWithDispatchQueue:self.uploadQueue] withBlock:^id(BFTask *task) {
        if (task.error != nil) {
            NSLog(@"Error: [%@]", task.error);
            //UIAlertView *failureAlert = [[UIAlertView alloc] initWithTitle:@"wait" message:@"could not up yo content" delegate:self cancelButtonTitle:@"ok :[" otherButtonTitles:nil];
            //[failureAlert show];
        } else {
            NSLog(@"completed upload");
            //[self.storyboard instantiateViewControllerWithIdentifier:@"sendViewController"];
            //[self performSegueWithIdentifier:@"toSendSegue" sender:self];
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"userProperties.plist"]];
            NSDictionary *dictToStore = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
            
            userEmail = [dictToStore valueForKey:@"userEmail"];
            NSLog(@"email is %@",userEmail);
            
            //LOAD WHOLE RESULTS LIST
            NSArray *resultLoadedArray = self.sendViewBox.selectedList;
            NSLog(@"resultLoadedArray is %@", resultLoadedArray);
            
            NSMutableDictionary *postxhashList = [[NSMutableDictionary alloc] init];
            //[postxhashList setValue:resultLoadedArray forKey:@"dojos"];
            
            NSMutableString *unlimitedStrings = [[NSMutableString alloc] init];
            for (NSString *dojo in resultLoadedArray)
            {
                NSLog(@"dojo read from dojos only is %@", dojo);
                [unlimitedStrings appendString:[NSString stringWithFormat:@"%@,",dojo]];
            }
            //postHash = [self generateCode];
            
            [postxhashList setObject:unlimitedStrings forKey:@"dojos"];
            [postxhashList setObject:postHash forKey:@"posthash"];
            [postxhashList setObject:postDescription forKey:@"description"];
            [postxhashList setObject:userEmail forKey:@"email"];
            
            NSLog(@"posthash:%@",postxhashList);
            
            @try {
                NSError *error = nil;
                NSData *result =[NSJSONSerialization dataWithJSONObject:postxhashList options:0 error:&error];
                NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%spostToDojo.php",SERVERADDRESS]]];
                
                //customize request information
                [request setHTTPMethod:@"POST"];
                [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
                [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                [request setValue:[NSString stringWithFormat:@"%ld", (long)postxhashList.count] forHTTPHeaderField:@"Content-Length"];
                [request setHTTPBody:result];
                
                NSURLResponse *response = nil;
                
                //fire the request and wait for response
                [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                    NSString *decodedString = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
                    NSLog(@"decoded string is %@",decodedString);
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                    NSString *documentsDirectory = [paths objectAtIndex:0];
                    NSString *plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"didPost.plist"]];
                    NSDictionary *didpostdict = [[NSDictionary alloc] initWithObjects:@[@"yes"] forKeys:@[@"didPost"]];
                    [didpostdict writeToFile:plistPath atomically:YES];
                    //[self performSegueWithIdentifier:@"returnToHomeVC" sender:self];
                }];
                [self dismissViewControllerAnimated:YES completion:nil];
            }
            @catch (NSException *exception)
            {
                NSLog(@"exception is %@",exception);
            }
            @finally
            {
                NSLog(@"elevate yo self");
            }
        }
        return nil;
    }]];
    
    [tasks addObject:[[localTransMan upload:uploadRequestSmall] continueWithExecutor:[BFExecutor executorWithDispatchQueue:self.uploadQueue] withBlock:^id(BFTask *task) {
        if (task.error != nil) {
            NSLog(@"Error: [%@]", task.error);
        } else {
            NSLog(@"completed upload");
            //[self.storyboard instantiateViewControllerWithIdentifier:@"sendViewController"];
            //[self performSegueWithIdentifier:@"toSendSegue" sender:self];
        }
        return nil;
    }]];
    */
    /*
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"userProperties.plist"]];
    NSDictionary *dictToStore = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    
    userEmail = [dictToStore valueForKey:@"userEmail"];
    NSLog(@"email is %@",userEmail);
    
    //LOAD WHOLE RESULTS LIST
    plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"sendchecked.plist"]];
    //NSDictionary *dictToStore = [[NSDictionary alloc] initWithObjects:@[userEmail] forKeys:@[@"userEmail"]];
    NSArray *resultLoadedArray = [[NSArray alloc] initWithContentsOfFile:plistPath];
    NSLog(@"resultLoadedArray is %@", resultLoadedArray);
    
    NSMutableDictionary *postxhashList = [[NSMutableDictionary alloc] init];
    //[postxhashList setValue:resultLoadedArray forKey:@"dojos"];
    
    NSMutableString *unlimitedStrings = [[NSMutableString alloc] init];
    for (NSString *dojo in resultLoadedArray)
    {
        NSLog(@"dojo read from dojos only is %@", dojo);
        [unlimitedStrings appendString:[NSString stringWithFormat:@"%@,",dojo]];
    }
    //postHash = [self generateCode];
    
    [postxhashList setObject:unlimitedStrings forKey:@"dojos"];
    [postxhashList setObject:postHash forKey:@"posthash"];
    [postxhashList setObject:postDescription forKey:@"description"];
    [postxhashList setObject:userEmail forKey:@"email"];
    
    NSLog(@"posthash:%@",postxhashList);

    @try {
        NSError *error = nil;
        NSData *result =[NSJSONSerialization dataWithJSONObject:postxhashList options:0 error:&error];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%spostToDojo.php",SERVERADDRESS]]];
        
        //customize request information
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:[NSString stringWithFormat:@"%ld", (long)postxhashList.count] forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody:result];
        
        NSURLResponse *response = nil;
        
        //fire the request and wait for response
        result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        NSString *decodedString = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
        NSLog(@"decoded string is %@",decodedString);
        
        plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"didPost.plist"]];
        NSDictionary *didpostdict = [[NSDictionary alloc] initWithObjects:@[@"yes"] forKeys:@[@"didPost"]];
        [didpostdict writeToFile:plistPath atomically:YES];
        
        [self dismissViewControllerAnimated:YES completion:^{NSLog(@"dismissed");}];
        //[self performSegueWithIdentifier:@"returnToHomeVC" sender:self];
    }
    @catch (NSException *exception)
    {
        UIAlertView *unable = [[UIAlertView alloc] initWithTitle:@"oops" message:@"something went wrong" delegate:nil cancelButtonTitle:@"ok :(" otherButtonTitles:nil];
        [unable show];
    }
    @finally
    {
        NSLog(@"elevate yo self");
    }
     */
}

- (NSString *)generateCode
{
    static NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXZY";
    static NSString *digits = @"0123456789";
    NSMutableString *s = [NSMutableString stringWithCapacity:8];
    //returns 19 random chars into array (mutable string)
    for (NSUInteger i = 0; i < 5; i++) {
        uint32_t r;
        
        // Append 2 random letters:
        r = arc4random_uniform((uint32_t)[letters length]);
        [s appendFormat:@"%C", [letters characterAtIndex:r]];
        r = arc4random_uniform((uint32_t)[letters length]);
        [s appendFormat:@"%C", [letters characterAtIndex:r]];
        
        // Append 2 random digits:
        r = arc4random_uniform((uint32_t)[digits length]);
        [s appendFormat:@"%C", [digits characterAtIndex:r]];
        r = arc4random_uniform((uint32_t)[digits length]);
        [s appendFormat:@"%C", [digits characterAtIndex:r]];
        
    }
    NSLog(@"s-->%@",s);
    return s;
}

-(IBAction)removeSelf:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{NSLog(@"dismissed from send view");}];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
