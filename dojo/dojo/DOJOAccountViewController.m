//
//  DOJOAccountViewController.m
//  dojo
//
//  Created by Kian Anderson on 7/13/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import "DOJOAccountViewController.h"
#import <MessageUI/MessageUI.h>
#import "DOJOHomeTableViewController.h"
#import "DOJONavigationController.h"
#import "DOJONotificationViewController.h"
#import "DOJOPerformAPIRequest.h"
#import "DOJOAppDelegate.h"

#define ACCESS_KEY_ID                 @""

#define SECRET_KEY                    @""

#import "AWSiOSSDKv2/AWSS3TransferManager.h"
#import "AWSiOSSDKv2/AWSS3.h"
#import <AWSiOSSDKv2/AWSCredentialsProvider.h>
#import <AWSiOSSDKv2/AWSS3PreSignedURL.h>
#import <AWSiOSSDKv2/AWSCore.h>

@interface DOJOAccountViewController () <MFMailComposeViewControllerDelegate, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, APIRequestDelegate, UITextViewDelegate, MFMessageComposeViewControllerDelegate>

@property (strong, nonatomic) DOJOPerformAPIRequest *apiBot;
@property (nonatomic, strong) AWSS3TransferManagerUploadRequest *uploadRequest;
@property (nonatomic, strong) AWSS3TransferManagerDownloadRequest *downloadRequest;

@end

@implementation DOJOAccountViewController

@synthesize phoneNumberLabel, locationLabel, emailLabel, profilePictureview, changeButton, personInfo, apiBot, uploadRequest, downloadRequest, saveButton, profileVC, personBio, changePFPictureButton, spreadButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return  UIStatusBarStyleLightContent;
}

-(void)bioUpdated
{
    [self.personBio resignFirstResponder];
    [self.saveButton setTitle:@"Saved" forState:UIControlStateNormal];
}

-(IBAction)saveBio:(id)sender
{
    [self.saveButton setTitle:@"Saving" forState:UIControlStateNormal];
    [self.saveButton setEnabled:NO];
    [self.apiBot saveBio:self.personBio.text];
}

-(IBAction)logout
{
    
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Wait!" message:@"Do you want to logout?" delegate:self  cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yeam I'm sure", nil];
    alertView.tag = 1;
    [alertView show];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.apiBot = [[DOJOPerformAPIRequest alloc] init];
    self.apiBot.delegate = self;
    
    NSLog(@"about to get user info");
    [self.apiBot getUserInfo];
    
    [self.spreadButton.layer setCornerRadius:15];
    [self.spreadButton setClipsToBounds:YES];
    [self.spreadButton.layer setMasksToBounds:YES];
    
    [self.navigationItem setTitle:@"Settings"];
}

-(void)gotUserInfo:(NSArray *)userInfo
{
    self.personInfo = [userInfo objectAtIndex:0];
    phoneNumberLabel.text = [[userInfo objectAtIndex:0] objectForKey:@"fullname"];
    
    self.personBio.text = [[userInfo objectAtIndex:0] objectForKey:@"bio"];
    
    if ([self.personBio.text isEqualToString:@""])
    {
        self.personBio.text = @"Something about yourself...";
    }
    
    NSString *profilehash = [[userInfo objectAtIndex:0] objectForKey:@"profilehash"];
    if ([profilehash isEqualToString:@""])
    {
        profilePictureview.image = [UIImage imageNamed:@"iconwhite200.png"];
        profilePictureview.contentMode = UIViewContentModeScaleAspectFit;
    }
    else
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *picNameCache = [NSString stringWithFormat:@"%@.jpeg",profilehash];
        NSString *picPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:picNameCache]];
        UIImage *image = [[UIImage alloc] init];
        if ([[NSFileManager defaultManager] fileExistsAtPath:picPath])
        {
            image = [[UIImage alloc] initWithContentsOfFile:picPath];
            [self.profilePictureview setImage:image];
        }
        else
        {
            AWSStaticCredentialsProvider *credentialsProvider = [AWSStaticCredentialsProvider credentialsWithAccessKey:ACCESS_KEY_ID secretKey:SECRET_KEY];
            AWSServiceConfiguration *configuration = [AWSServiceConfiguration configurationWithRegion:AWSRegionUSWest1 credentialsProvider:credentialsProvider];
            [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
            
            AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
            
            self.downloadRequest = [AWSS3TransferManagerDownloadRequest new];
            self.downloadRequest.bucket = @"dojopicbucket";
            self.downloadRequest.key = profilehash;
            self.downloadRequest.downloadingFileURL = [NSURL fileURLWithPath:picPath];
            
            [[transferManager download:self.downloadRequest] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
                if (task.error != nil) {
                    NSLog(@"Error: [%@]", task.error);
                    @try {
                        UIImage *dlthumb = [[UIImage alloc] initWithContentsOfFile:picPath];
                        [self.profilePictureview setImage:dlthumb];
                    }
                    @catch (NSException *exception) {
                        NSLog(@"could not load image exception executor %@",exception);
                    }
                    @finally {
                        NSLog(@"ran through try block executor");
                    }
                } else {
                    NSLog(@"completed download");
                    UIImage *dlthumb = [[UIImage alloc] initWithContentsOfFile:picPath];
                    [self.profilePictureview setImage:dlthumb];
                }
                return nil;
            }];
        }
    }
}

-(IBAction)goToProfile
{
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:picker.sourceType];
    //NSLog( [[self.parentViewController class] isSubclassOfClass:[DOJOHomeTableViewController class]] ? @"is the right one" : @"NOPE");
    [picker setDelegate:self];
    picker.allowsEditing = YES;
    NSLog(@"before show");
    [self presentViewController:picker animated:YES completion:nil];
    
    /*
    NSLog(@"will go to profile now");
    @try {
        DOJONavigationController *naviVC = (DOJONavigationController *)self.presentingViewController;
        DOJOHomeTableViewController *homeVC = (DOJOHomeTableViewController *)[[naviVC viewControllers] objectAtIndex:0];
        [self dismissViewControllerAnimated:YES completion:^{
            [homeVC goToProfileVC:self.personInfo];
        }];
        

    }
    @catch (NSException *exception) {
        NSLog(@"swag swag eexception is %@", exception);
    }
    @finally {
        NSLog(@"either way we ride to die");
    }
     */
    
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo: (NSDictionary *) info
{
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    
    // Handle a still image picked from a photo album
    UIImage *editedImage = (UIImage *) [info objectForKey:
                                          UIImagePickerControllerEditedImage];
    NSData *imageData = UIImageJPEGRepresentation(editedImage, 0.9);
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSURL *selectedPath = [[NSURL alloc] initFileURLWithPath:[documentsDirectory stringByAppendingPathComponent:@"capturedprofilepic.jpeg"]];
    [imageData writeToURL:selectedPath atomically:YES];
    
    //[[[ALAssetsLibrary alloc] init] writeImageToSavedPhotosAlbum:[image CGImage] orientation:(ALAssetOrientation)[image imageOrientation] completionBlock:nil];
    
    AWSStaticCredentialsProvider *credentialsProvider = [AWSStaticCredentialsProvider credentialsWithAccessKey:ACCESS_KEY_ID secretKey:SECRET_KEY];
    AWSServiceConfiguration *configuration = [AWSServiceConfiguration configurationWithRegion:AWSRegionUSWest1 credentialsProvider:credentialsProvider];
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
    
    NSString *codeKey = [self generateCode];
    
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    NSLog(@"transferManager is %@",transferManager);
    AWSS3TransferManagerUploadRequest *uploadRequestBig = [AWSS3TransferManagerUploadRequest new];
    uploadRequestBig = [AWSS3TransferManagerUploadRequest new];
    uploadRequestBig.bucket = @"dojopicbucket";
    uploadRequestBig.key = codeKey;
    uploadRequestBig.contentType = @"image/jpeg";
    uploadRequestBig.contentLength = [NSNumber numberWithFloat:[imageData length]];
    uploadRequestBig.body = selectedPath;
    __weak DOJOAccountViewController *weakSelf = self;
    uploadRequestBig.uploadProgress =  ^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend){
        dispatch_async(dispatch_get_main_queue(), ^{
            //Update progress.
            DOJOAccountViewController *strongSelf = weakSelf;
            [strongSelf updateProgessOfUpload:bytesSent totalBytesSent:totalBytesSent totalBytesExpectedToSend:totalBytesExpectedToSend];
        });};

    [[transferManager upload:uploadRequestBig] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
        if (task.error != nil) {
            NSLog(@"Error: [%@]", task.error);
        } else {
            [self.apiBot changeProfilePicture:codeKey];
        }
        return nil;
    }];
    

    [picker dismissViewControllerAnimated:YES completion:^{
        [self viewDidAppear:NO];
    }];
}

-(void)updateProgessOfUpload:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
{
    NSLog(@"bytes sent %ld, totalByes sent %ld, totalBytesExpected to send %ld",(long)bytesSent,(long)totalBytesSent,(long)totalBytesExpectedToSend);
    @try {
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            
        } completion:nil];
    }
    @catch (NSException *exception) {
        NSLog(@"exception for rendering is %@",exception);
       
    }
    @finally {
        NSLog(@"ran through anim block");
    }
}

-(void)changedProfilePicture
{
     [self.apiBot getUserInfo];
}

- (NSString *)generateCode
{
    static NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXZY";
    static NSString *digits = @"0123456789";
    NSMutableString *s = [NSMutableString stringWithCapacity:8];
    //returns 40 random chars into array (mutable string)
    for (NSUInteger i = 0; i < 10; i++) {
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

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)changedName
{
   [changeButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [self.apiBot getUserInfo];
    [self.phoneNumberLabel resignFirstResponder];
}

-(IBAction)changeName
{
    [self.apiBot changeName:phoneNumberLabel.text];
}

-(IBAction)sendHelpEmail:(id)sender
{
    MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    NSArray *toRecipients = [NSArray arrayWithObjects:@"mikezuccarino@gmail.com", nil];
    [controller setToRecipients:toRecipients];
    [controller setTitle:@"Request/Issue"];
    [controller setSubject:@"Something isn't right"];
    [controller setMessageBody:@"Request/Issue Phrase:\n\nDescription:\n" isHTML:NO];
    
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [self becomeFirstResponder];
    NSString *strMailResult;
    switch (result)
    {
        case MFMailComposeResultCancelled:
            strMailResult = NSLocalizedString(@"E-Mail Cancelled",@"");
            break;
        case MFMailComposeResultSaved:
            strMailResult = NSLocalizedString(@"E-Mail Saved",@"");
            break;
        case MFMailComposeResultSent:
            strMailResult = NSLocalizedString(@"E-Mail Sent",@"");
            break;
        case MFMailComposeResultFailed:
            strMailResult = NSLocalizedString(@"E-Mail Failed",@"");
            break;
        default:
            strMailResult = NSLocalizedString(@"E-Mail Not Sent",@"");
            break;
    }
    
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Message",@"") message:strMailResult delegate:self  cancelButtonTitle:NSLocalizedString(@"OK",@"") otherButtonTitles:nil];
    [alertView show];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)deleteAccount:(id)sender
{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Wait!" message:@"Delete your account?" delegate:self  cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yeam I'm sure", nil];
    alertView.tag = 0;
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1)
    {
        if ((int)buttonIndex == 1)
        {
            DOJOAppDelegate *app = [[UIApplication sharedApplication] delegate];
            app.shouldLogout = YES;
            
            NSLog(@"logout action is called on %@", self.profileVC);
            UINavigationController *vc = self.profileVC.navigationController;
            [vc popToRootViewControllerAnimated:NO];
            [self dismissViewControllerAnimated:NO completion:nil];
            return;
            //[vc dismissViewControllerAnimated:NO completion:nil];
            //[vc dismissViewControllerAnimated:NO completion:nil];
        }
        return;
    }
    if ((int)buttonIndex == 1)
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"userProperties.plist"]];
        //NSDictionary *dictToStore = [[NSDictionary alloc] initWithObjects:@[userEmail] forKeys:@[@"userEmail"]];
        NSDictionary *loadedDict = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
        NSString *userEmail = [loadedDict valueForKey:@"userEmail"];
        @try {
            NSError *error;
            NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[userEmail] forKeys:@[@"email"]];
            NSData *result =[NSJSONSerialization dataWithJSONObject:dataDict options:0 error:&error];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%sdeleteAccount.php",SERVERADDRESS]]];
            
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
            //NSArray *userInfoList = [NSJSONSerialization JSONObjectWithData:result options:NSJSONReadingAllowFragments error:&error];
            //NSLog(@"user info array is %@",userInfoList);
            [self dismissViewControllerAnimated:YES completion:^{
                NSFileManager *fM = [NSFileManager defaultManager];
                NSError *error;
                NSArray *directoryContents = [fM contentsOfDirectoryAtPath:documentsDirectory error:&error];
                if (error == nil) {
                    for (NSString *path in directoryContents) {
                        NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:path];
                        BOOL removeSuccess = [fM removeItemAtPath:fullPath error:&error];
                    }
                }
                NSDictionary *clearedAccount = [[NSDictionary alloc] initWithObjects:@[@"yes"] forKeys:@[@"deleted"]];
                NSString *plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"deleteAccount.plist"]];
                [clearedAccount writeToFile:plistPath atomically:YES];
                [self.parentViewController dismissViewControllerAnimated:YES completion:^{
                    NSLog(@"dismissed up tha trees");
                }];
            }];
        }
        @catch (NSException *exception) {
            UIAlertView *unable = [[UIAlertView alloc] initWithTitle:@"oops" message:@"trouble with network" delegate:nil cancelButtonTitle:@"ok :(" otherButtonTitles:nil];
            [unable show];
        }
        @finally {
            NSLog(@"ran through try block");
        }

    }
}

-(IBAction)spreadTheWord
{
    if(![MFMessageComposeViewController canSendText])
    {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warningAlert show];
        return;
    }
    
    NSArray *recipents = @[];
    NSString *message = [NSString stringWithFormat:@"You've been summoned to the Dojo. Join your friends on the new social network. https://itunes.apple.com/us/app/dojo-social-network/id931108727?mt=8"];
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    [messageController setRecipients:recipents];
    [messageController setBody:message];
    
    // Present message view controller on screen
    [self presentViewController:messageController animated:YES completion:nil];
}

-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
        [[[UIAlertView alloc] initWithTitle:nil message:@"Thank you for supporting indie developers and our vision!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    [controller dismissViewControllerAnimated:YES completion:nil];
}

-(void)viewDidAppear:(BOOL)animated
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *virginityPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"virginity.plist"]];
    NSMutableDictionary *virginDict = [[NSMutableDictionary alloc] init];
    if ([[NSFileManager defaultManager] fileExistsAtPath:virginityPath])
    {
        virginDict = [[NSMutableDictionary alloc] initWithContentsOfFile:virginityPath];
        NSLog(@"virgindict is %@",virginDict);
        if ([[virginDict valueForKey:@"AccountVirgin"] isEqualToString:@"yes"])
        {
           // UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Dojoito say:" message:@"I love you. You can access the Dojo developers by emailing us a note telling us something doesn't vibe or something you want to see. Depending on how much you browse the app, clearing the cache might be a good idea too. <3" delegate:self cancelButtonTitle:@"Ok I get it" otherButtonTitles:nil];
            //[alertView show];
            [virginDict setValue:@"no" forKey:@"AccountVirgin"];
            [virginDict writeToFile:virginityPath atomically:YES];
        }
        else
        {
            // do nothing
        }
    }
    else
    {
        //UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Dojoito say:" message:@"I love you. You can access the Dojo developers by emailing us a note telling us something doesn't vibe or something you want to see. Depending on how much you browse the app, clearing the cache might be a good idea too. <3" delegate:self cancelButtonTitle:@"Ok I get it" otherButtonTitles:nil];
        //[alertView show];
        [virginDict setValue:@"no" forKey:@"AccountVirgin"];    
        [virginDict writeToFile:virginityPath atomically:YES];
    }
    // Do any additional setup after loading the view.
    self.navigationItem.titleView.tintColor = [UIColor darkGrayColor];
}

-(void)viewWillAppear:(BOOL)animated
{
    [profilePictureview.layer setCornerRadius:65.5];
    //[imView.layer setBorderWidth:1.5];
    //imView.layer.borderColor = [UIColor whiteColor].CGColor;
    profilePictureview.layer.masksToBounds = YES;
    
    [self.changePFPictureButton.layer setMasksToBounds:YES];
    //[self.changePFPictureButton.layer setMask:profilePictureview.layer];
    
    [self setNeedsStatusBarAppearanceUpdate];
}

-(IBAction)clearCache:(id)sender
{
    NSFileManager *fMan = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSError *error;
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
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSUInteger oldLength = [textView.text length];
    NSUInteger replacementLength = [text length];
    NSUInteger rangeLength = range.length;
    
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
    if (!self.saveButton.isEnabled)
    {
        [self.saveButton setEnabled:YES];
        [self.saveButton setTitle:@"Save" forState:UIControlStateNormal];
    }
    
    return newLength <= 140;
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"Something about yourself..."])
    {
        textView.text = @"";
    }
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""])
    {
        textView.text = @"Something about yourself...";
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.personBio resignFirstResponder];
}

-(IBAction)closeMe:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
