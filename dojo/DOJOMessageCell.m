//
//  DOJOMessageCell.m
//  dojo
//
//  Created by Michael Zuccarino on 9/23/14.
//  Copyright (c) 2014 Michael Zuccarino. All rights reserved.
//

#import "DOJOMessageCell.h"

@implementation DOJOMessageCell

@synthesize messageBody, nameLabel, posttime, profPicture, background;

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        messageBody = [[UITextView alloc] init];
        nameLabel = [[UILabel alloc] init];
        posttime = [[UILabel alloc] init];
        background = [[UIView alloc] initWithFrame:CGRectMake(75, 7,  self.frame.size.width-80, self.frame.size.height-10)];
        [background.layer setCornerRadius:10];
        background.userInteractionEnabled = NO;
        
        [messageBody setFont:[UIFont fontWithName:@"Avenir" size:14.0]];
        [nameLabel setFont:[UIFont fontWithName:@"Avenir" size:14.0]];
        [nameLabel setTextColor:[UIColor colorWithRed:0.2 green:0.678 blue:1 alpha:1]];
        
        [messageBody setTextColor:[UIColor darkGrayColor]];
        [messageBody setBackgroundColor:[UIColor clearColor]];
      //  [posttime setBackgroundColor:[UIColor redColor]];
        
        [messageBody setEditable:NO];
        [messageBody setUserInteractionEnabled:YES];
        [messageBody setSelectable:YES];
        [messageBody setDataDetectorTypes:(UIDataDetectorTypeAll)];
        [messageBody setFrame:CGRectMake(80, 20, self.frame.size.width-85, self.frame.size.height-20)];
        
        [nameLabel setFrame:CGRectMake(65, 10, self.frame.size.width-90, 20)];
        
        profPicture = [[UIImageView alloc] initWithFrame:CGRectMake(8, 10, 40, 40)];
        [profPicture.layer setCornerRadius:profPicture.frame.size.height/2];
        profPicture.clipsToBounds = YES;
        
        //[background setBackgroundColor:[UIColor colorWithRed:0 green:0.678 blue:1 alpha:1]];
        [background setBackgroundColor:[UIColor colorWithWhite:0.99 alpha:1]];
        
        [self.contentView addSubview:background];
        [self.contentView addSubview:messageBody];
        [self.contentView addSubview:nameLabel];
        [self.contentView addSubview:profPicture];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
