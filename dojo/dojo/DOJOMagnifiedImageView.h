//
//  DOJOMagnifiedImageView.h
//  dojo
//
//  Created by Michael Zuccarino on 1/25/15.
//  Copyright (c) 2015 Michael Zuccarino. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MagnifiedDelegate <NSObject>

@required
-(void)tapDetected;

@end

@interface DOJOMagnifiedImageView : UIView

@property (strong, nonatomic) id<MagnifiedDelegate> delegate;
@property (strong, nonatomic) IBOutlet UIImageView *magnifiedImage;

@end
