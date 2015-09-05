//
//  DOJOTrueLogin.m
//  dojo
//
//  Created by Michael Zuccarino on 1/27/15.
//  Copyright (c) 2015 Michael Zuccarino. All rights reserved.
//

#import "DOJOTrueLogin.h"
#import "networkConstants.h"
#import "DOJOPerformAPIRequest.h"

@interface DOJOTrueLogin ()  <UITextFieldDelegate>

@property (strong, nonatomic) DOJOPerformAPIRequest *apiBot;

@end

@implementation DOJOTrueLogin

@synthesize numberLabel, nameLabel, notRightLabel, passwordLabel, apiBot;

-(IBAction)closeMe:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)login:(id)sender
{
    NSString *nameString = self.nameLabel.text;
    NSString *numberString = self.numberLabel.text;
    NSString *word = self.passwordLabel.text;
    
    if ([nameString isEqualToString:@""] || [numberString isEqualToString:@""] || [word isEqualToString:@""])
    {
        return;
    }
    
    NSDictionary *accountInfo = [[NSDictionary alloc] initWithObjects:@[nameString,numberString, word] forKeys:@[@"name",@"number",@"word"]];
    NSLog(@"CREATING ACCOUNT WITH DICT: %@",accountInfo);
    self.apiBot = [[DOJOPerformAPIRequest alloc] init];
    NSDictionary *returnedInfo = [self.apiBot loginAccount:accountInfo];
    NSLog(@"return dict is %@",returnedInfo);
    @try {
        if ([[returnedInfo objectForKey:@"result"] isEqualToString:@"success"])
        {
            [self closeMe:self];
            [self.notRightLabel setHidden:YES];
        }
        else
        {
            [self.notRightLabel setHidden:NO];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"create account excpetion is %@", exception);
    }
    @finally {
        NSLog(@"finally poop");
    }

}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([textField.text isEqualToString:@"Enter Name..."] || [textField.text isEqualToString:@"Enter Number..."] || [textField.text isEqualToString:@"Enter Password..."])
    {
        textField.text = @"";
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([self.nameLabel.text isEqualToString:@""])
    {
        self.nameLabel.text = @"Enter Name...";
    }
    if ([self.numberLabel.text isEqualToString:@""])
    {
        self.numberLabel.text = @"Enter Number...";
    }
    if ([self.passwordLabel.text isEqualToString:@""])
    {
        self.passwordLabel.text = @"Enter Password...";
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([self.nameLabel isFirstResponder])
    {
        [self.nameLabel resignFirstResponder];
    }
    if ([self.numberLabel isFirstResponder])
    {
        [self.numberLabel resignFirstResponder];
    }
    if ([self.passwordLabel isFirstResponder])
    {
        [self.passwordLabel resignFirstResponder];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([self.nameLabel isFirstResponder])
    {
        [self.numberLabel becomeFirstResponder];
        return NO;
    }
    if ([self.numberLabel isFirstResponder])
    {
        [self.passwordLabel becomeFirstResponder];
        return NO;
    }
    if ([self.passwordLabel isFirstResponder])
    {
        [self.passwordLabel resignFirstResponder];
        return YES;
    }
    return YES;
}



@end
