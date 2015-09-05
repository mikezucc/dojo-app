//
//  DOJOCreateAccountViewController.m
//  dojo
//
//  Created by Michael Zuccarino on 12/1/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import "DOJOCreateAccountViewController.h"
#import "DOJOPerformAPIRequest.h"

@interface DOJOCreateAccountViewController () <UITextFieldDelegate>

@property (strong, nonatomic) DOJOPerformAPIRequest *apiBot;

@end

@implementation DOJOCreateAccountViewController

@synthesize nameField, numberField, passField, createButton, apiBot, swag;

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [createButton.layer setCornerRadius:10];
    createButton.layer.masksToBounds = YES;
    createButton.clipsToBounds = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)closeMe:(id)sender
{
    [nameField resignFirstResponder];
    [numberField resignFirstResponder];
    [passField resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([textField.text isEqualToString:@"Enter a Name..."] || [textField.text isEqualToString:@"Enter Area Code..."] || [textField.text isEqualToString:@"Enter a secret word"])
    {
        textField.text = @"";
    }
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:nameField])
    {
        [numberField becomeFirstResponder];
    }
    else if ([textField isEqual:numberField])
    {
        [passField becomeFirstResponder];
    }
    else if ([textField isEqual:passField])
    {
        [textField resignFirstResponder];
    }
    return NO;
}

- (NSString *)generateCode
{
    static NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXZY";
    static NSString *digits = @"0123456789";
    NSMutableString *s = [NSMutableString stringWithCapacity:8];
    //returns 19 random chars into array (mutable string)
    for (NSUInteger i = 0; i < 6; i++) {
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

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([self.nameField.text isEqualToString:@""])
    {
        self.nameField.text = @"Enter a Name...";
    }
    if ([self.numberField.text isEqualToString:@""])
    {
        self.numberField.text = @"Enter Area Code...";
    }
    if ([self.passField.text isEqualToString:@""])
    {
        self.passField.text = @"Enter a secret word";
    }
}

-(IBAction)login:(id)sender
{
    NSString *nameString = self.nameField.text;
    NSString *numberString = self.numberField.text;
    NSString *word = self.passField.text;
    
    if (numberString.length > 10)
    {
        [self.swag setText:@"That's not a phone number"];
        [self.swag setHidden:NO];
        return;
    }
    [self.swag setText:@"Username already exists"];
    
    if ([nameString isEqualToString:@""] || [numberString isEqualToString:@""] || [word isEqualToString:@""])
    {
        return;
    }
    
    NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[nameString,numberString, word, [self generateCode]] forKeys:@[@"name",@"number",@"word",@"username"]];
    
    [self.apiBot authMe:dataDict];
}


-(IBAction)createAccount:(id)sender
{
    NSString *nameString = self.nameField.text;
    NSString *numberString = self.numberField.text;
    NSString *word = self.passField.text;
    
    NSDictionary *accountInfo = [[NSDictionary alloc] initWithObjects:@[nameString,numberString, word, [self generateCode]] forKeys:@[@"name",@"number",@"word",@"username"]];
    NSLog(@"CREATING ACCOUNT WITH DICT: %@",accountInfo);
    self.apiBot = [[DOJOPerformAPIRequest alloc] init];
    NSDictionary *returnedInfo = [self.apiBot createAccount:accountInfo];
    
    @try {
        if ([[returnedInfo objectForKey:@"result"] isEqualToString:@"made"])
        {
            [self closeMe:self];
            [self.swag setHidden:YES];
        }
        else
        {
            [self.swag setHidden:NO];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"create account excpetion is %@", exception);
    }
    @finally {
        NSLog(@"finally poop");
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([self.nameField isFirstResponder])
    {
        [self.nameField resignFirstResponder];
    }
    if ([self.numberField isFirstResponder])
    {
        [self.numberField resignFirstResponder];
    }
    if ([self.passField isFirstResponder])
    {
        [self.passField resignFirstResponder];
    }
}

/*
 
 const char *nameStringUTF8 = nameString.UTF8String;
 
 long q = 0;
 for (int i=0; i < strlen(nameStringUTF8); i++)
 {
 q += (int)nameStringUTF8[i];
 }
 
 NSLog(@"q is %ld",q);
 
 const char *numberStringUTF8 = numberString.UTF8String;
 
 long nameNumber = 0;
 for (int i=0; i < strlen(numberStringUTF8); i++)
 {
 nameNumber += (int)numberStringUTF8[i];
 }
 
 NSLog(@"nameNumber is %ld",nameNumber);
 
 double remainder = q % nameNumber;
 
 NSLog(@"remainder is %f",remainder);
 
 double salt1 = pow(2,remainder);
 
 NSLog(@"salt1 is %f",salt1);
 
 const char *wordStringUTF8 = word.UTF8String;
 
 long p = 0;
 for (int i=0; i < strlen(wordStringUTF8); i++)
 {
 p += (int)wordStringUTF8[i];
 }
 
 NSLog(@"p is %ld",p);
 
 double salt3 = salt1 * p;
 
 NSLog(@"salt3 is %f",salt3);
 */


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
