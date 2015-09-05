//
//  DOJOWelcomeSequence.m
//  dojo
//
//  Created by Michael Zuccarino on 2/23/15.
//  Copyright (c) 2015 Michael Zuccarino. All rights reserved.
//

#import "DOJOWelcomeSequence.h"

@implementation DOJOWelcomeSequence

@synthesize welcomeImageView, sequenceCount;

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    // something here
    self.sequenceCount = 0;
    
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *keysPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"keysNkrates.plist"]];
    NSMutableDictionary *keysDict = [[NSMutableDictionary alloc] initWithContentsOfFile:keysPath];
    switch (self.sequenceCount) {
        case 0:
            [self.welcomeImageView setImage:[UIImage imageNamed:@"firstwelcomepage.png"]];
            break;
        case 1:
            [self.welcomeImageView setImage:[UIImage imageNamed:@"secondwelcomepage.png"]];
            break;
        case 2:
            [self.welcomeImageView setImage:[UIImage imageNamed:@"thirdwelcomepage.png"]];
            break;
            
        default:
            break;
    }
    if (self.sequenceCount == 3)
    {
        [keysDict setValue:@"done" forKey:@"firstTime"];
        [keysDict writeToFile:keysPath atomically:NO];
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    self.sequenceCount++;
}

@end
