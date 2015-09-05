//
//  DOJOMagnifiedImageView.m
//  dojo
//
//  Created by Michael Zuccarino on 1/25/15.
//  Copyright (c) 2015 Michael Zuccarino. All rights reserved.
//

#import "DOJOMagnifiedImageView.h"

@implementation DOJOMagnifiedImageView

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.delegate tapDetected];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
