//
//  DOJOPage.m
//  dojo
//
//  Created by Michael Zuccarino on 12/13/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import "DOJOPage.h"
#import "DOJOUpdateSettingsViewController.h"

@interface DOJOPage () <scrolled, SampleViewDelegate>

@end

@implementation DOJOPage

@synthesize dojoInfo, messageViewBox, cameraButton, blurredView, preventJumping, fieldContainer, messageField, sendButton, smallDescription, furtherButton, sampleView, postList, userEmail, dojoHeader;

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.messageViewBox.dojoData = dojoInfo;
    self.messageViewBox = [self.messageViewBox initWithFrame:CGRectMake(0, 290, 320, 159)];
    self.preventJumping = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardFrameDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardFrameWillChange:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
    
    self.messageViewBox.delegate = self;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [messageViewBox.bongReloader invalidate];
    messageViewBox.bongReloader = nil;
    [self.sampleView.videoPlayer stop];
}

-(void)viewWillAppear:(BOOL)animated
{
    //UIButton *imView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 23, 20)];
    //[imView setImage:[UIImage imageNamed:@"furthericon.png"] forState:UIControlStateNormal];
    //self.furtherButton.customView = imView;

    @try {
        
        //[self.navigationController.view setBackgroundColor:[UIColor colorWithRed:0 green:0.678 blue:255 alpha:1]];
        // Pass any objects to the view controller here, like...
        NSError *error;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"userProperties.plist"]];
        NSDictionary *userProperties = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
        NSLog(@"user email is %@",[dojoInfo valueForKey:@"dojohash"]);
        NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[[userProperties objectForKey:@"userEmail"],[dojoInfo valueForKey:@"dojohash"]] forKeys:@[@"email",@"dojohash"]];
        NSData *result =[NSJSONSerialization dataWithJSONObject:dataDict options:0 error:&error];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%sgetDojoPostList.php",SERVERADDRESS]]];
        
        //customize request information
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:[NSString stringWithFormat:@"%ld", (long)dataDict.count] forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody:result];
        
        NSURLResponse *response = nil;
        error = nil;
        
        //fire the request and wait for response
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
         {
            NSError *error;
            postList = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
             NSLog(@"retrieved post list %@",postList);
             if ([postList count] >0)
             {
                 self.sampleView = [[DOJOSampleView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 232)];
                 self.sampleView.multipleTouchEnabled = YES;
                 self.sampleView.delegate = self;
                 //[self.sampleView initMinor];
                 //[self.sampleView setFrame:CGRectMake(0, (self.tableView.contentOffset.y)/2, self.view.frame.size.width, self.view.frame.size.height)];
                 //self.sampleView.backgroundColor = [UIColor greenColor];
                 self.sampleView.selectedPostInfo = [postList objectAtIndex:0];
                 self.sampleView.userEmail = self.userEmail;
                 self.sampleView.dojoPostList = postList;
                 //self.sampleView.frame = self.view.frame;
                 self.sampleView.zoomable = YES;
                 [self.sampleView setHidden:NO];
                 [self.sampleView.postDescription setHidden:YES];
                 [self.view addSubview:self.sampleView];
                 [self.sampleView loadAPost];
                 [self.sampleView.postDescription sizeToFit];
                 [self.sampleView.postDescription setFrame:CGRectMake(0, self.sampleView.frame.size.height-self.sampleView.postDescription.frame.size.height, self.sampleView.frame.size.width, self.sampleView.postDescription.frame.size.height)];
                 [self.sampleView.videoPlayer.view setFrame:self.sampleView.frame];
             }
         }];
    }
    @catch (NSException *exception) {
        NSLog(@"network latency issue");
    }
    @finally {
    }
    
    @try {
        
        //[self.navigationController.view setBackgroundColor:[UIColor colorWithRed:0 green:0.678 blue:255 alpha:1]];
        // Pass any objects to the view controller here, like...
        NSError *error;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"userProperties.plist"]];
        NSDictionary *userProperties = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
        NSLog(@"user email is %@",[dojoInfo valueForKey:@"dojohash"]);
        NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[[userProperties objectForKey:@"userEmail"],[dojoInfo valueForKey:@"dojohash"]] forKeys:@[@"email",@"dojohash"]];
        NSLog(@"DOJOPAGE dacia sandero is %@", dataDict);
        NSData *result =[NSJSONSerialization dataWithJSONObject:dataDict options:0 error:&error];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%scheckIfFollow.php",SERVERADDRESS]]];
        
        //customize request information
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:[NSString stringWithFormat:@"%ld", (long)dataDict.count] forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody:result];
        
        NSURLResponse *response = nil;
        error = nil;
        
        //fire the request and wait for response
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
         {
             NSError *error;
             NSString *decodedString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
             NSLog(@"follow status: %@",decodedString);
             if ([decodedString isEqualToString:@"not"])
             {
                 [self.furtherButton setTitle:@"Follow"];
                 [self.furtherButton setTarget:self];
                 [self.furtherButton setAction:@selector(followDojo)];
             }
             else
             {
                 if ([decodedString isEqualToString:@"\"joined\""])
                 {
                     [self.furtherButton setTarget:self];
                     [self.furtherButton setAction:@selector(goToUpdate)];
                     UIImage *segmentImage = [UIImage imageNamed:@"furthericon.png"];
                     UIGraphicsBeginImageContextWithOptions(CGSizeMake(33, 33),NO,0.0);
                     [segmentImage drawInRect:CGRectMake(8, 6, 24, 20)];
                     UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
                     UIGraphicsEndImageContext();
                     [self.furtherButton setImage:resizedImage];
                 }
                 else if ([decodedString isEqualToString:@"\"requested\""])
                 {
                     [self.furtherButton setTitle:@"Requested"];
                     [self.furtherButton setEnabled:NO];
                 }
                 else if ([decodedString isEqualToString:@"\"invited\""])
                 {
                     [self.furtherButton setTitle:@"Accept"];
                     [self.furtherButton setTarget:self];
                     [self.furtherButton setAction:@selector(followDojo)];
                 }
             }
             
         }];
         
    }
    @catch (NSException *exception) {
        NSLog(@"network latency issue");
    }
    @finally {
    }
    
    //UILabel *title = [[UILabel alloc] init];
    //[title setFont:[UIFont fontWithName:@"AvenirNext-Bold" size:17]];
    [dojoHeader setText:[dojoInfo objectForKey:@"dojo"]];
    
    //self.navigationItem.title = title.text;
}

-(void)viewDidAppear:(BOOL)animated
{
    @try {
        [self.messageViewBox reloadTheBoard];
    }
    @catch (NSException *exception) {
        NSLog(@"exception is %@",exception);
        UIAlertView *unable = [[UIAlertView alloc] initWithTitle:@"hmm" message:@"reload the messageboard" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [unable show];
    }
    @finally {
        NSLog(@"ran through reload board block");
    }
}

- (void)keyboardFrameDidShow:(NSNotification *)notification
{
    if ([self.messageField isFirstResponder])
    {
        CGRect keyboardFrame;
        [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];
        
        NSLog(@"keyboard frame is %ld",(long)keyboardFrame.origin.y);
        CGRect frm = self.fieldContainer.frame;
        frm.origin.y = (keyboardFrame.origin.y < 320 ? 200 : 230);
        self.fieldContainer.frame = frm;
        NSLog(@"will change field container location is %ld",(long)self.fieldContainer.frame.origin.y);
    }
}


- (void)keyboardFrameWillChange:(NSNotification *)notification
{
    if ([self.messageField isFirstResponder])
    {
        CGRect keyboardFrame;
        [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];
        
        NSLog(@"keyboard frame is %ld",(long)keyboardFrame.origin.y);
        CGRect frm = self.fieldContainer.frame;
        frm.origin.y = (keyboardFrame.origin.y < 320 ? 200 : 230);
        self.fieldContainer.frame = frm;
        NSLog(@"will change field container location is %ld",(long)self.fieldContainer.frame.origin.y);
    }
}

-(void)acceptInvite
{
    @try {
        NSString *dojohash = [dojoInfo objectForKey:@"dojohash"];
        NSError *error;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"userProperties.plist"]];
        NSDictionary *userProperties = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
        NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[[userProperties objectForKey:@"userEmail"], dojohash, @"self"] forKeys:@[@"email", @"dojohash", @"byWho"]];
        NSLog(@"dacia sandero is %@",dataDict);
        NSData *result =[NSJSONSerialization dataWithJSONObject:dataDict options:0 error:&error];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%sinviteUserToDojo.php",SERVERADDRESS]]];
        
        //customize request information
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:[NSString stringWithFormat:@"%ld", (long)dataDict.count] forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody:result];
        
        NSURLResponse *response = nil;
        error = nil;
        
        //fire the request and wait for response
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            NSString *decodedString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"follow status: %@",decodedString);
            if ([decodedString isEqualToString:@"\"now invited\""])
            {
                NSLog(@"now invited");
                [self.furtherButton setTitle:@"Requested"];
                [self.furtherButton setAction:@selector(doNothingREKT)];
                [self.furtherButton setEnabled:NO];
            }
            if ([decodedString isEqualToString:@"\"now joined\""])
            {
                NSLog(@"now joined");
                [self.furtherButton setTitle:@"Following!"];
                [self.furtherButton setAction:@selector(doNothingREKT)];
                [self.furtherButton setEnabled:NO];
            }
            else
            {
                
            }
        }];
    
    }
    @catch (NSException *exception) {
        NSLog(@"exception occured %@",exception);
    }
    @finally {
        //
    }
}

-(void)followDojo
{
    @try {
        NSString *dojohash = [dojoInfo objectForKey:@"dojohash"];
        NSError *error;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"userProperties.plist"]];
        NSDictionary *userProperties = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
        NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[[userProperties objectForKey:@"userEmail"], dojohash, @"self"] forKeys:@[@"email", @"dojohash", @"byWho"]];
        NSLog(@"dacia sandero is %@",dataDict);
        NSData *result =[NSJSONSerialization dataWithJSONObject:dataDict options:0 error:&error];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%sinviteUserToDojo.php",SERVERADDRESS]]];
        
        //customize request information
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:[NSString stringWithFormat:@"%ld", (long)dataDict.count] forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody:result];
        
        NSURLResponse *response = nil;
        error = nil;
        
        //fire the request and wait for response
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            NSString *decodedString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"follow status: %@",decodedString);
            if ([decodedString isEqualToString:@"\"now invited\""])
            {
                NSLog(@"now invited");
                [self.furtherButton setTitle:@"Requested"];
                [self.furtherButton setAction:@selector(doNothingREKT)];
                [self.furtherButton setEnabled:NO];
            }
            if ([decodedString isEqualToString:@"\"now joined\""])
            {
                NSLog(@"now joined");
                [self.furtherButton setTitle:@"Following!"];
                [self.furtherButton setAction:@selector(doNothingREKT)];
                [self.furtherButton setEnabled:NO];
            }
            else
            {
                
            }
        }];
    }
    @catch (NSException *exception) {
        NSLog(@"exception occured is %@",exception);
    }
    @finally {
        //
    }
    
}

-(void)doNothingREKT
{
    
}

-(void)goToUpdate
{
    [self.storyboard instantiateViewControllerWithIdentifier:@"updateVC"];
    [self performSegueWithIdentifier:@"toUpdateVC" sender:self];
}

-(void)magnifyMessageBoard
{
    [self.view bringSubviewToFront:self.fieldContainer];
    NSLog(@"DOJO magnify THAT shit");
    if (messageViewBox.bounds.size.height > 350)
    {
        [UIView animateWithDuration:0.6 animations:^{
            [self.view addSubview:self.messageViewBox];
            [self.blurredView setAlpha:0];
            /*
             UICollectionViewFlowLayout *flow = (UICollectionViewFlowLayout *)messageViewBox.messageCollectionView.collectionViewLayout;
             //flow.itemSize = CGSizeMake(self.view.frame.size.width, 250);
             UICollectionViewFlowLayout *new = [[UICollectionViewFlowLayout alloc] init];
             new = flow;
             [latestCollectionView.collectionViewLayout invalidateLayout];
             [latestCollectionView setCollectionViewLayout:new];
             */
            messageViewBox.backgroundColor = [UIColor groupTableViewBackgroundColor];
            [messageViewBox.messageCollectionView setBackgroundColor:[UIColor whiteColor]];
            [messageViewBox setFrame:CGRectMake(0, 300, self.view.frame.size.width, self.view.frame.size.height-300)];
            [messageViewBox.messageCollectionView setFrame:CGRectMake(0, 0, self.view.frame.size.width, messageViewBox.frame.size.height)];
            [fieldContainer setHidden:YES];
            [messageField resignFirstResponder];
            //[self.blurredView setImage:[UIImage imageNamed:@"invisible.png"]];
            [messageViewBox.messageCollectionView reloadData];
        } completion:^(BOOL completed){
        }];
        //[messageViewBox setFrame:CGRectMake(0, 300, self.view.frame.size.width, self.view.frame.size.height-300)];
    }
    else
    {
        self.blurredView = [[UIImageView alloc] initWithFrame:CGRectMake(-10, 0, self.view.frame.size.width+15, self.view.frame.size.height)];
        UIImage *uiBeginImage = (UIImage *)self.sampleView.imagePost.image;//(UIImage *)tempCell.cellFace.image;
        UIImageOrientation originalOrientation = uiBeginImage.imageOrientation;
        CIImage *inputImage = [[CIImage alloc] initWithCGImage:[uiBeginImage CGImage]];
        CIFilter *blurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
        [blurFilter setDefaults];
        [blurFilter setValue:inputImage forKey:@"inputImage"];
        [blurFilter setValue:[NSNumber numberWithDouble:6.00f] forKey:@"inputRadius"];
        CIImage *blurredImage = [blurFilter outputImage];
        CIContext* context = [CIContext contextWithOptions:nil];
        CGImageRef imgRef = [context createCGImage:blurredImage fromRect:self.view.frame] ;
        UIImage* img = [[UIImage alloc] initWithCGImage:imgRef scale:0.5 orientation:originalOrientation];
        CGImageRelease(imgRef);
        self.blurredView.image = img;
        [self.blurredView setAlpha:0];
        [UIView animateWithDuration:0.6 animations:^{
            [self.view addSubview:self.messageViewBox];
            [self.blurredView setAlpha:1];

            /*
             UICollectionViewFlowLayout *flow = (UICollectionViewFlowLayout *)messageViewBox.messageCollectionView.collectionViewLayout;
             //flow.itemSize = CGSizeMake(self.view.frame.size.width, 250);
             UICollectionViewFlowLayout *new = [[UICollectionViewFlowLayout alloc] init];
             new = flow;
             [latestCollectionView.collectionViewLayout invalidateLayout];
             [latestCollectionView setCollectionViewLayout:new];*/
            [self.view addSubview:self.blurredView];
            [messageViewBox.messageCollectionView setBackgroundColor:[UIColor clearColor]];
            [messageViewBox setBackgroundColor:[UIColor clearColor]];
            [messageViewBox setFrame:CGRectMake(0, 0, 288, self.view.frame.size.height-87)];
            [messageViewBox.messageCollectionView setFrame:CGRectMake(0, 0, self.view.frame.size.width, messageViewBox.frame.size.height)];
            [self.view addSubview:self.messageViewBox];
            [fieldContainer setHidden:NO];
            [self.view addSubview:self.fieldContainer];
            [messageViewBox.messageCollectionView reloadData];
        } completion:^(BOOL completed){
        }];
    }
}

-(BOOL)textShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self scrollDown];
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSUInteger oldLength = [textView.text length];
    NSUInteger replacementLength = [text length];
    NSUInteger rangeLength = range.length;
    
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
    NSLog(@"newLength is %u",newLength);
    BOOL returnKey = [text rangeOfString: @"\n"].location != NSNotFound;
    
    return newLength <= 200 || returnKey;
}

-(IBAction)submitMessage:(id)sender
{
    if ([self.messageField.text isEqualToString:@""])
    {
        
    }
    else
    {
        @try {
            //post message
            NSString *hash = [self generateCode];
            NSLog(@"dojoData read as %@",dojoInfo);
            NSError *error;
            
            NSDate *currentTime = [NSDate date];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"hh-mm"];
            NSString *resultString = [dateFormatter stringFromDate: currentTime];
            NSLog(@"time posted is %@",resultString);
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"userProperties.plist"]];
            NSDictionary *userProperties = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
            
            NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[[dojoInfo objectForKey:@"dojohash"],[userProperties objectForKey:@"userEmail"],hash,self.messageField.text, resultString] forKeys:@[@"dojohash",@"email",@"messagehash",@"message",@"made"]];
            NSLog(@"dictionary is :%@",dataDict);
            NSData *result =[NSJSONSerialization dataWithJSONObject:dataDict options:0 error:&error];
            NSLog(@"encoded json is %@",result);
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%ssubmitMessage.php",SERVERADDRESS]]];
            
            //customize request information
            [request setHTTPMethod:@"POST"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [request setValue:[NSString stringWithFormat:@"%ld", (long)dataDict.count] forHTTPHeaderField:@"Content-Length"];
            NSLog(@"data .count is %ld", (long)dataDict.count);
            [request setHTTPBody:result];
            
            NSURLResponse *response = nil;
            error = nil;
            
            //fire the request and wait for response
            [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                NSError *error;
                NSArray *dataConv = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                NSString *decodedString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSLog(@"%@",result);
                NSLog(@"%@",dataConv);
                NSLog(@"%@",decodedString);
                if ([decodedString rangeOfString:@"posted"].location == NSNotFound)
                {
                    // not posted
                    NSLog(@"exception message is %@",decodedString);
                    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"could not post!" message:@"send us this error report" delegate:self cancelButtonTitle:@"nah" otherButtonTitles:@"sure", nil];
                    [av show];
                }
                else
                {
                    [self.messageField setText:@""];
                }
                [messageViewBox reloadTheBoard];
            }];
            
        }
        @catch (NSException *exception) {
            NSLog(@"exception is %@",exception);
        }
        @finally {
            NSLog(@"this is the swagness run through");
        }
        
    }
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    NSLog(@"%dx %dy prevent:%@", (int)fieldContainer.frame.origin.x, (int)fieldContainer.frame.origin.y,(self.preventJumping ? @"yes" : @"no"));
    if ([self.messageField.text isEqualToString:@"Say something to this group"])
    {
        [self.messageField setText:@""];
    }
    if (self.messageViewBox.frame.origin.y > 150)
    {
        [self magnifyMessageBoard];
    }
    NSLog(@"BEGINcenter is %fl",self.fieldContainer.center.y);
    if (self.fieldContainer.center.y > 300)
    {
        [self scrollUp];
    }
    else
    {
        NSLog(@"already up");
    }
}

-(IBAction)removeYoSelf:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    [self.navigationController popToRootViewControllerAnimated:YES];
    //[self dismissViewControllerAnimated:YES completion:nil];]
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    @try {
        NSLog(@"ENDcenter is %fl",self.fieldContainer.center.y);
        if (self.fieldContainer.center.y < 400)
        {
            if ([self.messageField.text isEqualToString:@""])
            {
                //[self.messageField setText:@"cm on u kno u wanna"];
            }
            else
            {
                
            }
            [self scrollDown];
            self.preventJumping = NO;
        }
        else
        {
            NSLog(@"already down");
        }
        //[textField resignFirstResponder];
    }
    @catch (NSException *exception) {
        NSLog(@"exception is %@",exception);
        UIAlertView *unable = [[UIAlertView alloc] initWithTitle:@"oops" message:@"couldnt post ur messg" delegate:nil cancelButtonTitle:@"ok :(" otherButtonTitles:nil];
        [unable show];
    }
    @finally {
        NSLog(@"did end editing ran through block");
    }
}

-(void)detectedTapInMessageView
{
    NSLog(@"detected tap in message view dojo page");
    [self magnifyMessageBoard];
}

-(void)messageViewWasScrolled
{
    NSLog(@"scrolllllld");
    [messageField resignFirstResponder];
    //[self scrollDown];
}

-(void)scrollUp
{
    [UIView beginAnimations:@"registerScroll" context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.2];
    //self.addFieldView.transform = CGAffineTransformMakeTranslation(0, y);
    self.fieldContainer.center = CGPointApplyAffineTransform(self.fieldContainer.center, CGAffineTransformMakeTranslation(0, -220));
    [UIView commitAnimations];
    /*
    [UIView beginAnimations:@"backgroundTransition" context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.2];
    //[self.view setBackgroundColor:[UIColor whiteColor]];
    //[self.fieldContainer setBackgroundColor:[UIColor colorWithRed:0 green:0.678 blue:1 alpha:1.0]];
    [UIView commitAnimations];
     */
    [self.view bringSubviewToFront:self.fieldContainer];
}

-(void)scrollDown
{
    [UIView beginAnimations:@"registerScroll" context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.4];
    //self.addFieldView.transform = CGAffineTransformMakeTranslation(0, y);
    self.fieldContainer.center = CGPointApplyAffineTransform(self.fieldContainer.center, CGAffineTransformMakeTranslation(0, 220));
    [UIView commitAnimations];
    /*
    [UIView beginAnimations:@"backgroundTransition" context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.4];
    //[self.fieldContainer setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    //[self.view setBackgroundColor:[UIColor whiteColor]];
    [UIView commitAnimations];
     */
    [self.view bringSubviewToFront:self.fieldContainer];
}

-(void)didEndZooming
{
    [self.view bringSubviewToFront:self.sampleView];
    [self.view bringSubviewToFront:self.fieldContainer];
}

- (NSString *)generateCode
{
    static NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXZY";
    static NSString *digits = @"0123456789";
    NSMutableString *s = [NSMutableString stringWithCapacity:8];
    //returns 19 random chars into array (mutable string)
    for (NSUInteger i = 0; i < 3; i++) {
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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"toUpdateVC"])
    {
        DOJOUpdateSettingsViewController *vc = [segue destinationViewController];
        vc.dojoInfo = dojoInfo;
    }
    if ([[segue identifier] isEqualToString:@"toCameraFromPage"])
    {
        DOJOCameraViewController *vc = [segue destinationViewController];
        vc.parentHash = [dojoInfo objectForKey:@"dojohash"];
        NSLog(@"vc.parenthash is %@",vc.parentHash);
    }
}

-(IBAction)openTheCamera:(id)sender
{
    [self performSegueWithIdentifier:@"toCameraFromPage" sender:self];
}

@end
