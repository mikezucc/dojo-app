//
//  DOJOMapAnno.h
//  Dojo
//
//  Created by Michael Zuccarino on 8/14/15.
//  Copyright (c) 2015 Michael Zuccarino. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapboxGL/MapboxGL.h>

@interface DOJOMapGLAnnotation : MGLPointAnnotation

@property (nonatomic) NSUInteger tag;
@property (nonatomic) BOOL seenFlag;
@property (strong, nonatomic) NSString *dojohash;

+ (instancetype)annotationWithLocation:(CLLocationCoordinate2D)coordinate title:(NSString *)title subtitle:(NSString *)subtitle;

- (instancetype)initWithLocation:(CLLocationCoordinate2D)coordinate title:(NSString *)title subtitle:(NSString *)subtitle;

@end
