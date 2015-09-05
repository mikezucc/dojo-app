//
//  DOJOMapAnno.m
//  Dojo
//
//  Created by Michael Zuccarino on 8/14/15.
//  Copyright (c) 2015 Michael Zuccarino. All rights reserved.
//

#import "DOJOMapAnno.h"

@interface DOJOMapGLAnnotation ()

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic) NSString *title;
@property (nonatomic) NSString *subtitle;

@end

@implementation DOJOMapGLAnnotation

@synthesize coordinate, title, subtitle, tag, seenFlag, dojohash;

+ (instancetype)annotationWithLocation:(CLLocationCoordinate2D)coordinate title:(NSString *)title subtitle:(NSString *)subtitle
{
    return [[self alloc] initWithLocation:coordinate title:title subtitle:subtitle];
}

- (instancetype)initWithLocation:(CLLocationCoordinate2D)coordinate title:(NSString *)title subtitle:(NSString *)subtitle
{
    if (self = [super init])
    {
        self.coordinate = coordinate;
        self.title = title;
        self.subtitle = subtitle;
        self.tag = 0;
    }
    
    return self;
}
@end
