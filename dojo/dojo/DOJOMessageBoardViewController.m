//
//  DOJOMessageBoardViewController.m
//  dojo
//
//  Created by Michael Zuccarino on 9/23/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import "DOJOMessageBoardViewController.h"

@interface DOJOMessageBoardViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITextViewDelegate>

@end

@implementation DOJOMessageBoardViewController

@synthesize messageCollectionView, messageCell, messageField, preventJumping, fieldContainer, dojoData, userEmail, boardData, bongReloader;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(BOOL)prefersStatusBarHidden
{
    return true;
}

- (void)viewDidLoad
{
    self.preventJumping = NO;
    // Do any additional setup after loading the view.
    UICollectionViewFlowLayout *latestLayout = [[UICollectionViewFlowLayout alloc] init];
    [latestLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    messageCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(20, self.view.frame.origin.y+55, self.view.frame.size.width-40, 450) collectionViewLayout:latestLayout];
    messageCollectionView.backgroundColor = [UIColor whiteColor];//[UIColor colorWithRed:0.29019 green:0.56471 blue:0.88627 alpha:1.0];
    // [latestCollectionView registerClass:[CustomCellClass class] forCellWithReuseIdentifier:@"collectCell"];
    [messageCollectionView setDelegate:self];
    [messageCollectionView setDataSource:self];
    messageCollectionView.tag = 1;
    [messageCollectionView registerClass:[DOJOMessageCell class] forCellWithReuseIdentifier:@"messageCellID"];
    messageCollectionView.alwaysBounceVertical = YES;
    
    [self.view addSubview:messageCollectionView];
    
    [self.view addSubview:fieldContainer];
    
   // [self.view setBackgroundColor:[UIColor colorWithRed:0.29019 green:0.56471 blue:0.88627 alpha:1.0]];
    
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated
{
    CGRect boundSize = [[UIScreen mainScreen] bounds];
    NSLog(@"height is %f, width is %f",boundSize.size.height, boundSize.size.width);
    
    if (boundSize.size.height < 500)
    {
        [fieldContainer setFrame:CGRectMake(0, boundSize.size.height-86, boundSize.size.width, 86)];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    boardData = [[NSArray alloc] init];
    @try {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        //load user email lols
        NSString *plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"userProperties.plist"]];
        //NSDictionary *dictToStore = [[NSDictionary alloc] initWithObjects:@[userEmail] forKeys:@[@"userEmail"]];
        NSDictionary *loadedDict = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
        userEmail = [loadedDict valueForKey:@"userEmail"];
        
        NSError *error;
        NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[[dojoData objectForKey:@"dojohash"],userEmail] forKeys:@[@"dojohash",@"email"]];
        NSLog(@"dictionary is :%@",dataDict);
        NSData *result =[NSJSONSerialization dataWithJSONObject:dataDict options:0 error:&error];
        NSLog(@"encoded json is %@",result);
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://54.193.25.91/dojo-site-api/elevate18/getMessageBoard.php"]]];
        
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
        result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        boardData = [NSJSONSerialization JSONObjectWithData:result options:0 error:&error];
        NSString *decodedString = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
        NSLog(@"%@",result);
        NSLog(@"%@",boardData);
        NSLog(@"%@",decodedString);
        [messageCollectionView reloadData];
    }
    @catch (NSException *exception) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"nets troubles" message:@"shotty connection 2 my servers fyi" delegate:self cancelButtonTitle:@"kk" otherButtonTitles:nil];
        [alert show];
    }
    @finally {
        NSLog(@"ran through exception block");
    }
    bongReloader = [NSTimer scheduledTimerWithTimeInterval:4.0 target:self selector:@selector(reloadTheBoard) userInfo:nil repeats:YES];//imerWithTimeInterval:2 target:self selector:@selector(reloadTheBoard) userInfo:nil repeats:YES];
    //[bongReloader fire];
}

-(void)reloadTheBoard
{
    NSLog(@"board reloaded");
    boardData = [[NSArray alloc] init];
    @try {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        //load user email lols
        NSString *plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"userProperties.plist"]];
        //NSDictionary *dictToStore = [[NSDictionary alloc] initWithObjects:@[userEmail] forKeys:@[@"userEmail"]];
        NSDictionary *loadedDict = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
        userEmail = [loadedDict valueForKey:@"userEmail"];
        
        NSError *error;
        NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[[dojoData objectForKey:@"dojohash"],userEmail] forKeys:@[@"dojohash",@"email"]];
        NSLog(@"dictionary is :%@",dataDict);
        NSData *result =[NSJSONSerialization dataWithJSONObject:dataDict options:0 error:&error];
        NSLog(@"encoded json is %@",result);
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://54.193.25.91/dojo-site-api/elevate18/getMessageBoard.php"]]];
        
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
        result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        boardData = [NSJSONSerialization JSONObjectWithData:result options:0 error:&error];
        NSString *decodedString = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
        NSLog(@"%@",result);
        NSLog(@"%@",boardData);
        NSLog(@"%@",decodedString);
        [messageCollectionView reloadData];
    }
    @catch (NSException *exception) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"nets troubles" message:@"shotty connection 2 my servers fyi" delegate:self cancelButtonTitle:@"kk" otherButtonTitles:nil];
        [alert show];
    }
    @finally {
        NSLog(@"ran through exception block");
    }
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    self.preventJumping = NO;
    [messageField setReturnKeyType: UIReturnKeySend];
    if ([boardData count] > 0)
    {
        return [boardData count];
    }
    else
    {
        return 1;
    }
}

-(DOJOMessageCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"collectiontag == %ld, indexPath is %@",(long)collectionView.tag, indexPath);
    
    messageCell = (DOJOMessageCell *)[messageCollectionView dequeueReusableCellWithReuseIdentifier:@"messageCellID" forIndexPath:indexPath];
    if([boardData count] >0)
    {
        [messageCell setBackgroundColor:[UIColor whiteColor]];
        NSArray *messageArray = [boardData objectAtIndex:indexPath.row];
        NSDictionary *posterDict = [[messageArray objectAtIndex:0] objectAtIndex:0];
        NSDictionary *messageDict = [messageArray objectAtIndex:1];
        NSLog(@"email is %@\nmade is %@\nmessage is %@",[messageDict objectForKey:@"email"],[messageDict objectForKey:@"made"],[messageDict objectForKey:@"message"]);
        messageCell.nameLabel.text = [posterDict objectForKey:@"fullname"];
        [messageCell.nameLabel setTextColor:[UIColor lightGrayColor]];
        
        
        NSDictionary *timeInfo = [messageArray objectAtIndex:2];
        
        messageCell.posttime.text = [NSString stringWithFormat:@"%@s, %@m, %@h, %@d",
                                     [timeInfo objectForKey:@"s"],
                                     [timeInfo objectForKey:@"i"],
                                     [timeInfo objectForKey:@"h"],
                                     [timeInfo objectForKey:@"d"]];
        
        [messageCell.messageBody setText:[messageDict objectForKey:@"message"]];
        [messageCell.messageBody setFrame:CGRectMake(10, 18, messageCell.frame.size.width-30, messageCell.frame.size.height-20)];
        [messageCell.messageBody setScrollEnabled:NO];
        
        [messageCell.posttime setFrame:CGRectMake(10, messageCell.frame.size.height-20, messageCell.frame.size.width, 20)];
        
        return messageCell;
    }
    else
    {
        [messageCell setBackgroundColor:[UIColor whiteColor]];
        messageCell.nameLabel.text = @"dojito";
        [messageCell.nameLabel setTextColor:[UIColor lightGrayColor]];
        
        [messageCell.messageBody setText:@"no messages yet :)"];
        [messageCell.messageBody setFrame:CGRectMake(10, 18, messageCell.frame.size.width-30, messageCell.frame.size.height-20)];
        [messageCell.messageBody setScrollEnabled:NO];
        
        [messageCell.posttime setFrame:CGRectMake(10, messageCell.frame.size.height-20, messageCell.frame.size.width, 20)];
        return messageCell;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([boardData count] > 0)
    {
        NSArray *messageArray = [boardData objectAtIndex:indexPath.row];
        NSDictionary *messageDict = [messageArray objectAtIndex:1];
        NSUInteger strcount = [(NSString *)[messageDict objectForKey:@"message"] length];
        NSLog(@"%ud is strcount",(unsigned int)strcount);
        CGFloat cellHeight;
        cellHeight = 70;
        if (((int)strcount >35) && ((int)strcount < 69))
        {
            cellHeight = 80;
        }
        else if (((int)strcount >70) && ((int)strcount < 104))
        {
            cellHeight = 90;
        }
        else if (((int)strcount >105) && ((int)strcount < 149))
        {
            cellHeight = 100;
        }
        else if ((int)strcount >150)
        {
            cellHeight = 120;
        }
        
        NSLog(@"%f is the height",cellHeight);
        return CGSizeMake(collectionView.frame.size.width, cellHeight);
    }
    else
    {
        return CGSizeMake(collectionView.frame.size.width, 80);
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
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    NSUInteger oldLength = [textView.text length];
    NSUInteger replacementLength = [text length];
    NSUInteger rangeLength = range.length;
    
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
    NSLog(@"newLength is %u",newLength);
    BOOL returnKey = [text rangeOfString: @"\n"].location != NSNotFound;
    
    return newLength <= 200 || returnKey;
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    NSLog(@"%dx %dy prevent:%@", (int)fieldContainer.frame.origin.x, (int)fieldContainer.frame.origin.y,self.preventJumping);
    NSLog(@"BEGINcenter is %fl",self.fieldContainer.center.y);
    if (self.fieldContainer.center.y > 300)
    {
        if ([self.messageField.text isEqualToString:@"holler at ur girls"])
        {
            [self.messageField setText:@""];
        }
        if ([self.messageField.text isEqualToString:@"cm on u kno u wanna"])
        {
            [self.messageField setText:@""];
        }
        [self scrollUp];
    }
    else
    {
        NSLog(@"already up");
    }
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    @try {
        NSLog(@"ENDcenter is %fl",self.fieldContainer.center.y);
        if (self.fieldContainer.center.y < 400)
        {
            if ([self.messageField.text isEqualToString:@""])
            {
                [self.messageField setText:@"cm on u kno u wanna"];
            }
            else
            {
                //post message
                NSString *hash = [self generateCode];
                NSLog(@"dojoData read as %@",dojoData);
                NSError *error;
                
                NSDate *currentTime = [NSDate date];
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"hh-mm"];
                NSString *resultString = [dateFormatter stringFromDate: currentTime];
                NSLog(@"time posted is %@",resultString);
                
                NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[[dojoData objectForKey:@"dojohash"],userEmail,hash,textView.text, resultString] forKeys:@[@"dojohash",@"email",@"messagehash",@"message",@"made"]];
                NSLog(@"dictionary is :%@",dataDict);
                NSData *result =[NSJSONSerialization dataWithJSONObject:dataDict options:0 error:&error];
                NSLog(@"encoded json is %@",result);
                NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://54.193.25.91/dojo-site-api/elevate18/submitMessage.php"]]];
                
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
                result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
                NSArray *dataConv = [NSJSONSerialization JSONObjectWithData:result options:0 error:&error];
                NSString *decodedString = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
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
                    [messageField setText:@""];
                }
                [self reloadTheBoard];
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ((int)buttonIndex == 1)
    {
        //prepare email code
    }
}

-(void)scrollUp
{
    [UIView beginAnimations:@"registerScroll" context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.2];
    //self.addFieldView.transform = CGAffineTransformMakeTranslation(0, y);
    self.fieldContainer.center = CGPointApplyAffineTransform(self.fieldContainer.center, CGAffineTransformMakeTranslation(0, -215));
    [UIView commitAnimations];
    [UIView beginAnimations:@"backgroundTransition" context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.2];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.fieldContainer setBackgroundColor:[UIColor colorWithRed:0.29019 green:0.56471 blue:0.88627 alpha:1.0]];
    [UIView commitAnimations];
}

-(void)scrollDown
{
    [UIView beginAnimations:@"registerScroll" context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.4];
    //self.addFieldView.transform = CGAffineTransformMakeTranslation(0, y);
    self.fieldContainer.center = CGPointApplyAffineTransform(self.fieldContainer.center, CGAffineTransformMakeTranslation(0, 215));
    [UIView commitAnimations];
    [UIView beginAnimations:@"backgroundTransition" context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.4];
    [self.fieldContainer setBackgroundColor:[UIColor lightGrayColor]];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [UIView commitAnimations];
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

-(IBAction)returnToDojo:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated
{
    [bongReloader invalidate];
    bongReloader = nil;
}

-(void)viewDidDisappear:(BOOL)animated
{
    [bongReloader invalidate];
    bongReloader = nil;
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
