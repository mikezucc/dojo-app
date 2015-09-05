//
//  NSObject+DOJOPerformAPIRequest.m
//  dojo
//
//  Created by Michael Zuccarino on 1/27/15.
//  Copyright (c) 2015 Michael Zuccarino. All rights reserved.
//

#import "DOJOPerformAPIRequest.h"
#import "networkConstants.h"

@interface DOJOPerformAPIRequest ()

@end

@implementation DOJOPerformAPIRequest

-(id)init
{
    self = [super init];
    return  self;
}

-(void)postTextPost:(NSString *)post toDojo:(NSString *)dojohash
{
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *keysPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"keysNkrates.plist"]];
    NSDictionary *meInfo = [[NSDictionary alloc] initWithContentsOfFile:keysPath];
    
    NSMutableDictionary *postxhashList = [[NSMutableDictionary alloc] init];
    //[postxhashList setValue:resultLoadedArray forKey:@"dojos"];
    
    NSMutableString *unlimitedStrings = [[NSMutableString alloc] init];
    [unlimitedStrings appendString:[NSString stringWithFormat:@"%@,",dojohash]];
    
    [postxhashList setObject:unlimitedStrings forKey:@"dojos"];
    [postxhashList setObject:[NSString stringWithFormat:@"text-%@",[self generateCode]] forKey:@"posthash"];
    [postxhashList setObject:post forKey:@"description"];
    [postxhashList setObject:[meInfo objectForKey:@"username"] forKey:@"username"];
    [postxhashList setObject:[meInfo objectForKey:@"token"] forKey:@"token"];
    
    NSLog(@"posthash:%@",postxhashList);
    
    @try {
        NSError *error = nil;
        NSData *result =[NSJSONSerialization dataWithJSONObject:postxhashList options:0 error:&error];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%spostToDojo.php",SERVERADDRESS]]];
        
        //customize request information
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:[NSString stringWithFormat:@"%ld", (long)postxhashList.count] forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody:result];
        
        NSURLResponse *response = nil;
        
        //fire the request and wait for response
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            @try {
                NSString *decodedString = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
                NSLog(@"decoded string is %@",decodedString);
                [self.delegate postedTextPost];
            }
            @catch (NSException *exception) {
                NSLog(@"issue trying to post is %@",exception);
            }
            @finally {
                NSLog(@"finally n shit");
            }
        }];
    }
    @catch (NSException *exception)
    {
        NSLog(@"exception is %@",exception);
    }
    @finally
    {
        NSLog(@"elevate yo self");
    }
}

-(void)saveBio:(NSString *)bio
{
    @try {
        //[self.navigationController.view setBackgroundColor:[UIColor colorWithRed:0 green:0.678 blue:255 alpha:1]];
        // Pass any objects to the view controller here, like...
        NSError *error;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *keysPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"keysNkrates.plist"]];
        NSDictionary *meInfo = [[NSDictionary alloc] initWithContentsOfFile:keysPath];
        NSLog(@"bio is %@",bio);
        NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[[meInfo objectForKey:@"username"],bio, [meInfo objectForKey:@"token"]] forKeys:@[@"username",@"bio",@"token"]];
        NSData *result =[NSJSONSerialization dataWithJSONObject:dataDict options:0 error:&error];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%supdateBio.php",SERVERADDRESS]]];
        
        //customize request information
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:[NSString stringWithFormat:@"%ld", (long)dataDict.count] forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody:result];
        
        error = nil;
        
        //fire the request and wait for response
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            @try {
                            [self.delegate bioUpdated];
            }
            @catch (NSException *exception) {
                NSLog(@"save bio exception is %@",exception);
            }
            @finally {
                
            }
        }];
    }
    @catch (NSException *exception) {
        NSLog(@"delete issue with %@",exception);
    }
    @finally {
    }
}

-(void)deleteAPost:(NSString *)posthash
{
    @try {
        //[self.navigationController.view setBackgroundColor:[UIColor colorWithRed:0 green:0.678 blue:255 alpha:1]];
        // Pass any objects to the view controller here, like...
        NSError *error;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *keysPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"keysNkrates.plist"]];
        NSDictionary *meInfo = [[NSDictionary alloc] initWithContentsOfFile:keysPath];
        NSLog(@"posthash is %@",posthash);
        NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[[meInfo objectForKey:@"username"],posthash, [meInfo objectForKey:@"token"]] forKeys:@[@"username",@"posthash",@"token"]];
        NSData *result =[NSJSONSerialization dataWithJSONObject:dataDict options:0 error:&error];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%sdeleteAPost.php",SERVERADDRESS]]];
        
        //customize request information
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:[NSString stringWithFormat:@"%ld", (long)dataDict.count] forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody:result];
        
        error = nil;
        
        //fire the request and wait for response
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            @try {
                [self.delegate deletedPost];
            }
            @catch (NSException *exception) {
                NSLog(@"delete a post exception is %@",exception);
            }
            @finally {
                
            }
        }];
    }
    @catch (NSException *exception) {
        NSLog(@"delete issue with %@",exception);
    }
    @finally {
    }
}

-(void)deleteADojo:(NSString *)dojohash
{
    @try {
        //[self.navigationController.view setBackgroundColor:[UIColor colorWithRed:0 green:0.678 blue:255 alpha:1]];
        // Pass any objects to the view controller here, like...
        NSError *error;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *keysPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"keysNkrates.plist"]];
        NSDictionary *meInfo = [[NSDictionary alloc] initWithContentsOfFile:keysPath];
        NSLog(@"dojohash to delete is %@",dojohash);
        NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[[meInfo objectForKey:@"username"], dojohash, [meInfo objectForKey:@"token"]] forKeys:@[@"username",@"dojohash",@"token"]];
        NSData *result =[NSJSONSerialization dataWithJSONObject:dataDict options:0 error:&error];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%sdeleteDojo.php",SERVERADDRESS]]];
        
        //customize request information
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:[NSString stringWithFormat:@"%ld", (long)dataDict.count] forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody:result];
        
        error = nil;
        
        //fire the request and wait for response
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            [self.delegate deletedDojo];
        }];
    }
    @catch (NSException *exception) {
        NSLog(@"delete issue with %@",exception);
    }
    @finally {
    }
}

-(void)changeProfilePicture:(NSString *)profhash
{
    @try {

    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *keysPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"keysNkrates.plist"]];
    NSDictionary *meInfo = [[NSDictionary alloc] initWithContentsOfFile:keysPath];
    NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[[meInfo objectForKey:@"username"],profhash,[meInfo objectForKey:@"token"]] forKeys:@[@"username",@"hash",@"token"]];
    NSData *result =[NSJSONSerialization dataWithJSONObject:dataDict options:0 error:&error];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%schangeProfilePicture.php",SERVERADDRESS]]];
    
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
        @try {
            NSString *decoded = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"decodedswag is %@",decoded);
            [self.delegate changedProfilePicture];
        }
        @catch (NSException *exception) {
            NSLog(@"change profile picture exception is %@",exception);
        }
        @finally {
            
        }
    }];
    }
    @catch (NSException *exception) {
        NSLog(@"exception is %@",exception);
    }
    @finally {
        NSLog(@"ran through view did load try block");
    }
}

-(void)changeName:(NSString *)newName
{
    @try {
        NSError *error;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *keysPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"keysNkrates.plist"]];
        NSDictionary *meInfo = [[NSDictionary alloc] initWithContentsOfFile:keysPath];
        
        NSString *nameString = [meInfo objectForKey:@"name"];
        NSString *numberString = [meInfo objectForKey:@"number"];
        NSString *word = [meInfo objectForKey:@"word"];
        NSString *username = [meInfo objectForKey:@"username"];
        
        const char *nameStringUTF8 = newName.UTF8String;
        
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
        
        NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[[meInfo objectForKey:@"username"],newName,[meInfo objectForKey:@"token"],[NSString stringWithFormat:@"%f",salt1]] forKeys:@[@"username",@"fullname",@"token",@"salt1"]];
        NSData *result =[NSJSONSerialization dataWithJSONObject:dataDict options:0 error:&error];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%schangeName.php",SERVERADDRESS]]];
        
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
            @try {
                NSString *decoded = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSLog(@"decodedswag is %@",decoded);
                [self.delegate changedName];
            }
            @catch (NSException *exception) {
                NSLog(@"change username exception is %@",exception);
            }
            @finally {
                
            }

        }];
    }
    @catch (NSException *exception) {
        NSLog(@"exception is %@",exception);
    }
    @finally {
        NSLog(@"ran through view did load try block");
    }
}

-(void)followSomeone:(NSDictionary *)personInfo
{
    @try {
        NSError *error;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *keysPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"keysNkrates.plist"]];
        NSDictionary *meInfo = [[NSDictionary alloc] initWithContentsOfFile:keysPath];
        
        NSLog(@"user email is %@",[personInfo valueForKey:@"username"]);
        NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[[meInfo objectForKey:@"username"],[personInfo objectForKey:@"username"],[meInfo objectForKey:@"token"]] forKeys:@[@"username", @"person",@"token"]];
        NSData *result =[NSJSONSerialization dataWithJSONObject:dataDict options:0 error:&error];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%sfollowSomeone.php",SERVERADDRESS]]];
        
        //customize request information
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:[NSString stringWithFormat:@"%ld", (long)dataDict.count] forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody:result];
        
        error = nil;
        
        //fire the request and wait for response
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            @try {
                NSError *error;
                NSArray *fetchedData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
                NSString *decodedstring = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSLog(@"fetched data is %@",fetchedData);
                NSLog(@"decoded string is %@",decodedstring);
                [self.delegate followedPerson:fetchedData];
            }
            @catch (NSException *exception) {
                NSLog(@"exception is %@",exception);
            }
            @finally {
                NSLog(@"ran thorugh dojo info retrieval");
            }
        }];
    }
    @catch (NSException *exception) {
        NSLog(@"network latency issue with %@",exception);
    }
    @finally {
    }
}

-(void)getNotificationService
{
    @try {
        NSError *error;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *keysPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"keysNkrates.plist"]];
        NSDictionary *meInfo = [[NSDictionary alloc] initWithContentsOfFile:keysPath];
        
        NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[[meInfo objectForKey:@"username"],[meInfo objectForKey:@"token"]] forKeys:@[@"username",@"token"]];
        NSData *result =[NSJSONSerialization dataWithJSONObject:dataDict options:0 error:&error];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%sgetNotificationService.php",SERVERADDRESS]]];
        
        //customize request information
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:[NSString stringWithFormat:@"%ld", (long)dataDict.count] forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody:result];
        
        NSURLResponse *response = nil;
        error = nil;
        
        //fire the request and wait for response
        result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        NSLog(@"result is %@", result);
        NSArray *checkPayload = [NSJSONSerialization JSONObjectWithData:result options:NSJSONReadingAllowFragments error:&error];
        NSString *decodedString = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
        NSLog(@"GET checkPayload LIST IS \n%@",checkPayload);
        [self.delegate receivedPushNotiSWAG:checkPayload];
    }
    @catch (NSException *exception) {
        NSLog(@"exception for get notification service is %@",exception);
    }
    @finally {
        
    }
    
}

-(void)followADojo:(NSDictionary *)dojoInfo
{
    @try {
        NSError *error;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *keysPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"keysNkrates.plist"]];
        NSDictionary *meInfo = [[NSDictionary alloc] initWithContentsOfFile:keysPath];
        
        NSLog(@"user dojohash is %@",[dojoInfo valueForKey:@"dojohash"]);
        NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[[meInfo objectForKey:@"username"],[dojoInfo valueForKey:@"dojohash"],[meInfo objectForKey:@"token"]] forKeys:@[@"username",@"dojohash",@"token"]];
        NSData *result =[NSJSONSerialization dataWithJSONObject:dataDict options:0 error:&error];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%sfollowDojo2.php",SERVERADDRESS]]];
        
        //customize request information
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:[NSString stringWithFormat:@"%ld", (long)dataDict.count] forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody:result];
        
        error = nil;
        
        //fire the request and wait for response
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            @try {
                NSError *error;
                NSArray *fetchedData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
                NSString *decodedstring = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSLog(@"fetched data is %@",fetchedData);
                NSLog(@"decoded string is %@",decodedstring);
                
                [self.delegate followedADojo:fetchedData];
                
            }
            @catch (NSException *exception) {
                NSLog(@"exception is %@",exception);
            }
            @finally {
                NSLog(@"ran thorugh dojo info retrieval");
            }
        }];
    }
    @catch (NSException *exception) {
        NSLog(@"network latency issue with %@",exception);
    }
    @finally {
    }
}

-(void)downvoteAPost:(NSDictionary *)postInfo
{
    @try {
        NSError *error;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *keysPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"keysNkrates.plist"]];
        NSDictionary *meInfo = [[NSDictionary alloc] initWithContentsOfFile:keysPath];
        
        NSLog(@"user email is %@",[postInfo valueForKey:@"dojohash"]);
        NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[[meInfo objectForKey:@"username"],[postInfo valueForKey:@"dojohash"],[postInfo valueForKey:@"posthash"],@"down",[meInfo objectForKey:@"token"]] forKeys:@[@"username",@"dojohash",@"posthash",@"vote",@"token"]];
        NSData *result =[NSJSONSerialization dataWithJSONObject:dataDict options:0 error:&error];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%svoteAPost.php",SERVERADDRESS]]];
        
        //customize request information
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:[NSString stringWithFormat:@"%ld", (long)dataDict.count] forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody:result];
        
        error = nil;
        
        //fire the request and wait for response
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            @try {
                NSError *error;
                NSArray *fetchedData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
                NSString *decodedstring = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSLog(@"fetched data is %@",fetchedData);
                NSLog(@"decoded string is %@",decodedstring);
                [self.delegate voteReported:fetchedData];
            }
            @catch (NSException *exception) {
                NSLog(@"exception is %@",exception);
            }
            @finally {
                NSLog(@"ran thorugh dojo info retrieval");
            }
        }];
    }
    @catch (NSException *exception) {
        NSLog(@"network latency issue with %@",exception);
    }
    @finally {
    }
}

-(void)upvoteAPost:(NSDictionary *)postInfo
{
    @try {
        NSError *error;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *keysPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"keysNkrates.plist"]];
        NSDictionary *meInfo = [[NSDictionary alloc] initWithContentsOfFile:keysPath];
        
        NSLog(@"user email is %@",[postInfo valueForKey:@"dojohash"]);
        NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[[meInfo objectForKey:@"username"],[postInfo valueForKey:@"dojohash"],[postInfo valueForKey:@"posthash"],@"up",[meInfo objectForKey:@"token"]] forKeys:@[@"username",@"dojohash",@"posthash",@"vote",@"token"]];
        NSData *result =[NSJSONSerialization dataWithJSONObject:dataDict options:0 error:&error];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%svoteAPost.php",SERVERADDRESS]]];
        
        //customize request information
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:[NSString stringWithFormat:@"%ld", (long)dataDict.count] forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody:result];
        
        error = nil;
        
        //fire the request and wait for response
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            @try {
                NSError *error;
                NSArray *fetchedData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
                NSString *decodedstring = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSLog(@"fetched data is %@",fetchedData);
                NSLog(@"decoded string is %@",decodedstring);
                [self.delegate voteReported:fetchedData];
            }
            @catch (NSException *exception) {
                NSLog(@"exception is %@",exception);
            }
            @finally {
                NSLog(@"ran thorugh dojo info retrieval");
            }
        }];
    }
    @catch (NSException *exception) {
        NSLog(@"network latency issue with %@",exception);
    }
    @finally {
    }
}

-(void)postToDojos:(NSArray *)dojos withHash:(NSString *)alabamaKush withDescription:(NSString *)postDescription isRepost:(BOOL)isRepost
{
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *keysPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"keysNkrates.plist"]];
    NSDictionary *meInfo = [[NSDictionary alloc] initWithContentsOfFile:keysPath];
    
    NSMutableDictionary *postxhashList = [[NSMutableDictionary alloc] init];
    //[postxhashList setValue:resultLoadedArray forKey:@"dojos"];
    
    NSMutableString *unlimitedStrings = [[NSMutableString alloc] init];
    for (NSString *dojo in dojos)
    {
        NSLog(@"dojo read from dojos only is %@", dojo);
        [unlimitedStrings appendString:[NSString stringWithFormat:@"%@,",dojo]];
    }
    //postHash = [self generateCode];
    
    [postxhashList setObject:unlimitedStrings forKey:@"dojos"];
    [postxhashList setObject:alabamaKush forKey:@"posthash"];
    [postxhashList setObject:postDescription forKey:@"description"];
    [postxhashList setObject:[meInfo objectForKey:@"username"] forKey:@"username"];
    [postxhashList setObject:[meInfo objectForKey:@"token"] forKey:@"token"];
    
    NSLog(@"posthash:%@",postxhashList);
    if (isRepost)
    {
        @try {
            NSError *error = nil;
            NSData *result =[NSJSONSerialization dataWithJSONObject:postxhashList options:0 error:&error];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%srepostAPost.php",SERVERADDRESS]]];
            
            //customize request information
            [request setHTTPMethod:@"POST"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [request setValue:[NSString stringWithFormat:@"%ld", (long)postxhashList.count] forHTTPHeaderField:@"Content-Length"];
            [request setHTTPBody:result];
            
            NSURLResponse *response = nil;
            
            //fire the request and wait for response
            [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                @try {
                    NSString *decodedString = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
                    NSLog(@"decoded string is %@",decodedString);
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                    NSString *documentsDirectory = [paths objectAtIndex:0];
                    NSString *plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"didPost.plist"]];
                    NSDictionary *didpostdict = [[NSDictionary alloc] initWithObjects:@[@"yes"] forKeys:@[@"didPost"]];
                    [didpostdict writeToFile:plistPath atomically:YES];
                    [self.delegate postedToDojos];
                }
                @catch (NSException *exception) {
                    NSLog(@"repost issue trying to post is %@",exception);
                }
                @finally {
                    NSLog(@"finally n shit");
                }
                //[self performSegueWithIdentifier:@"returnToHomeVC" sender:self];
            }];
        }
        @catch (NSException *exception)
        {
            NSLog(@"repost exception is %@",exception);
        }
        @finally
        {
            NSLog(@"finally through repost block");
        }
    }
    else
    {
        @try {
            NSError *error = nil;
            NSData *result =[NSJSONSerialization dataWithJSONObject:postxhashList options:0 error:&error];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%spostToDojo.php",SERVERADDRESS]]];
            
            //customize request information
            [request setHTTPMethod:@"POST"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [request setValue:[NSString stringWithFormat:@"%ld", (long)postxhashList.count] forHTTPHeaderField:@"Content-Length"];
            [request setHTTPBody:result];
            
            NSURLResponse *response = nil;
            
            //fire the request and wait for response
            [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                @try {
                    NSString *decodedString = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
                    NSLog(@"decoded string is %@",decodedString);
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                    NSString *documentsDirectory = [paths objectAtIndex:0];
                    NSString *plistPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"didPost.plist"]];
                    NSDictionary *didpostdict = [[NSDictionary alloc] initWithObjects:@[@"yes"] forKeys:@[@"didPost"]];
                    [didpostdict writeToFile:plistPath atomically:YES];
                    [self.delegate postedToDojos];
                }
                @catch (NSException *exception) {
                    NSLog(@"issue trying to post is %@",exception);
                }
                @finally {
                    NSLog(@"finally n shit");
                }
            }];
        }
        @catch (NSException *exception)
        {
            NSLog(@"exception is %@",exception);
        }
        @finally
        {
            NSLog(@"elevate yo self");
        }
    }
}

-(void)retrieveSendList
{
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *keysPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"keysNkrates.plist"]];
    NSDictionary *meInfo = [[NSDictionary alloc] initWithContentsOfFile:keysPath];
    
    NSString *stringPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"location.plist"]];
    NSDictionary *coordDict = [[NSDictionary alloc] initWithContentsOfFile:stringPath];
    NSNumber *lati = [coordDict objectForKey:@"lati"];
    NSNumber *longi = [coordDict objectForKey:@"longi"];
    @try {
        NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[[meInfo objectForKey:@"username"], lati, longi, [meInfo objectForKey:@"token"]] forKeys:@[@"username",@"lati",@"longi",@"token"]];
        NSLog(@"data dict is %@",dataDict);
        NSData *result =[NSJSONSerialization dataWithJSONObject:dataDict options:0 error:&error];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%sgetSendList.php",SERVERADDRESS]]];
        
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
            NSError *error;
            NSArray *swagData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            NSString *decodedString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"GET HOME LIST IS \n%@",swagData);
            NSLog(@"decodestring = GET HOME LIST IS %@",decodedString);
            [self.delegate retrievedSendList:swagData];
        }];
        
    }
    @catch (NSException *exception) {
        NSLog(@"exception is %@",exception);
    }
    @finally {
        NSLog(@"ran through send table view box");
    }
}

-(void)retrieveSendListForRepost:(NSString *)posthash
{
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *keysPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"keysNkrates.plist"]];
    NSDictionary *meInfo = [[NSDictionary alloc] initWithContentsOfFile:keysPath];
    
    NSString *stringPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"location.plist"]];
    NSDictionary *coordDict = [[NSDictionary alloc] initWithContentsOfFile:stringPath];
    NSNumber *lati = [coordDict objectForKey:@"lati"];
    NSNumber *longi = [coordDict objectForKey:@"longi"];
    
    @try {
        NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[[meInfo objectForKey:@"username"], lati, longi, posthash,[meInfo objectForKey:@"token"]] forKeys:@[@"username",@"lati",@"longi",@"posthash",@"token"]];
        NSLog(@"datadict for repost is %@",dataDict);
        NSData *result =[NSJSONSerialization dataWithJSONObject:dataDict options:0 error:&error];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%sgetSendListForRepost.php",SERVERADDRESS]]];
        
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
            NSError *error;
            NSArray *swagData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            NSString *decodedString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"GET HOME LIST IS \n%@",swagData);
            NSLog(@"deceoded get home list is %@",decodedString);
            
            [self.delegate retrievedSendListForRepost:swagData];
        }];
    }
    @catch (NSException *exception) {
        NSLog(@"exception is %@",exception);
    }
    @finally {
        NSLog(@"ran through send table view box");
    }
}

-(void)submitAComment:(NSDictionary *)postInfo withText:(NSString *)text
{
    @try {
        NSLog(@"CHATOPEN somewhere");
        NSString *hash = [self generateCode];
        NSError *error;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *keysPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"keysNkrates.plist"]];
        
        NSDictionary *meInfo = [[NSDictionary alloc] initWithContentsOfFile:keysPath];
        
        NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[[postInfo objectForKey:@"posthash"],[meInfo objectForKey:@"username"],hash,text,[meInfo objectForKey:@"token"]] forKeys:@[@"posthash",@"username",@"messagehash",@"message",@"token"]];
        //NSLog(@"dictionary is :%@",dataDict);
        NSData *result =[NSJSONSerialization dataWithJSONObject:dataDict options:0 error:&error];
        //NSLog(@"encoded json is %@",result);
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%ssubmitAComment.php",SERVERADDRESS]]];
        
        //customize request information
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:[NSString stringWithFormat:@"%ld", (long)dataDict.count] forHTTPHeaderField:@"Content-Length"];
        //NSLog(@"data .count is %ld", (long)dataDict.count);
        [request setHTTPBody:result];
        
        NSURLResponse *response = nil;
        error = nil;
        
        //fire the request and wait for response
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            @try {
                NSError *error;
                NSArray *dataConv = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                NSString *decodedString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                //NSLog(@"%@",result);
                //NSLog(@"%@",dataConv);
                //NSLog(@"%@",decodedString);
                [self.delegate sentMessage:decodedString];
            }
            @catch (NSException *exception) {
                NSLog(@"submit a comment inner asynch exception is %@",exception);
            }
            @finally {
                NSLog(@"finally");
            }
        }];
        
    }
    @catch (NSException *exception) {
        NSLog(@"COMMENT exception is %@",exception);
    }
    @finally {
        NSLog(@"TRYNA FOGETCHA BAE this is the swagness run through");
    }
}

-(void)submitMessage:(NSDictionary *)dojoInfo withText:(NSString *)text
{
    @try {
        //post message
        NSString *hash = [self generateCode];
        NSError *error;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *keysPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"keysNkrates.plist"]];
        
        NSDictionary *meInfo = [[NSDictionary alloc] initWithContentsOfFile:keysPath];
        
        NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[[dojoInfo objectForKey:@"dojohash"],[meInfo objectForKey:@"username"],hash,text,[meInfo objectForKey:@"token"]] forKeys:@[@"dojohash",@"username",@"messagehash",@"message",@"token"]];
        //NSLog(@"dictionary is :%@",dataDict);
        NSData *result =[NSJSONSerialization dataWithJSONObject:dataDict options:0 error:&error];
        //NSLog(@"encoded json is %@",result);
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%ssubmitMessage.php",SERVERADDRESS]]];
        
        //customize request information
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:[NSString stringWithFormat:@"%ld", (long)dataDict.count] forHTTPHeaderField:@"Content-Length"];
        //NSLog(@"data .count is %ld", (long)dataDict.count);
        [request setHTTPBody:result];
        
        NSURLResponse *response = nil;
        error = nil;
        
        //fire the request and wait for response
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            @try {
                NSError *error;
                NSArray *dataConv = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                NSString *decodedString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSLog(@"%@",result);
                NSLog(@"%@",dataConv);
                NSLog(@"%@",decodedString);
                [self.delegate sentMessage:decodedString];
            }
            @catch (NSException *exception) {
                NSLog(@"exception is %@",exception);
            }
            @finally {
                NSLog(@"finally");
            }
        }];
        
    }
    @catch (NSException *exception) {
        NSLog(@"exception is %@",exception);
    }
    @finally {
        NSLog(@"this is the swagness run through");
    }
}

-(void)getUserInfo
{
    @try {
        NSError *error;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *keysPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"keysNkrates.plist"]];
        
        NSDictionary *meInfo = [[NSDictionary alloc] initWithContentsOfFile:keysPath];
        NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[[meInfo objectForKey:@"username"],[meInfo objectForKey:@"token"]] forKeys:@[@"username",@"token"]];
        NSLog(@"dacia sandero is %@",dataDict);
        NSData *result =[NSJSONSerialization dataWithJSONObject:dataDict options:0 error:&error];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%sgetUserInfo.php",SERVERADDRESS]]];
        
        //customize request information
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:[NSString stringWithFormat:@"%ld", (long)dataDict.count] forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody:result];
        
        NSURLResponse *response = nil;
        error = nil;
        
        //fire the request and wait for response
        result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        NSArray *userData = [NSJSONSerialization JSONObjectWithData:result options:NSJSONReadingAllowFragments error:&error];
        NSString *decodedString = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
        NSLog(@"GET HOME LIST IS \n%@",userData);
        NSLog(@"decodestring = GET HOME LIST IS %@",decodedString);
        [self.delegate gotUserInfo:userData];
        
    }
    @catch (NSException *exception) {
        NSLog(@"gotuser info the exception is as so %@",exception);
        //UIAlertView *unable = [[UIAlertView alloc] initWithTitle:@"oops" message:@"trouble with network" delegate:nil cancelButtonTitle:@"ok :(" otherButtonTitles:nil];
        //[unable show];
    }
    @finally {
        NSLog(@"ran through view did load try block");
    }
}

-(void)checkSomeoneOut:(NSDictionary *)userInfo
{
    @try {

        NSError *error;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *keysPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"keysNkrates.plist"]];
        
        NSDictionary *meInfo = [[NSDictionary alloc] initWithContentsOfFile:keysPath];
        NSLog(@"person name is %@",[userInfo valueForKey:@"username"]);
        NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[[meInfo objectForKey:@"username"],[userInfo objectForKey:@"username"],[meInfo objectForKey:@"token"]] forKeys:@[@"username", @"person",@"token"]];
        NSData *result =[NSJSONSerialization dataWithJSONObject:dataDict options:0 error:&error];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%scheckIfFollowSomeone.php",SERVERADDRESS]]];
        
        //customize request information
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:[NSString stringWithFormat:@"%ld", (long)dataDict.count] forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody:result];
        
        error = nil;
        
        //fire the request and wait for response
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            @try {
                NSError *error;
                NSArray *fetchedData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
                NSString *decodedstring = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSLog(@"fetched data is %@",fetchedData);
                NSLog(@"decoded string is %@",decodedstring);
                
                [self.delegate checkedSomeoneOut:fetchedData];
            }
            @catch (NSException *exception) {
                NSLog(@"exception is %@",exception);
            }
            @finally {
                NSLog(@"ran thorugh dojo info retrieval");
            }
        }];
    }
    @catch (NSException *exception) {
        NSLog(@"network latency issue with %@",exception);
    }
    @finally {
    }
}

-(void)loadProfiledata:(NSDictionary *)userInfo
{
    @try {

        NSError *error;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *keysPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"keysNkrates.plist"]];
        
        NSDictionary *meInfo = [[NSDictionary alloc] initWithContentsOfFile:keysPath];
        NSLog(@"username is %@",[meInfo valueForKey:@"username"]);
        NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[[meInfo objectForKey:@"username"],[userInfo objectForKey:@"username"],[meInfo objectForKey:@"token"]] forKeys:@[@"username",@"person", @"token"]];
        NSLog(@"LOAD PERSON IS %@",dataDict);
        NSData *result =[NSJSONSerialization dataWithJSONObject:dataDict options:0 error:&error];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%sfetchProfile.php",SERVERADDRESS]]];
        
        //customize request information
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:[NSString stringWithFormat:@"%ld", (long)dataDict.count] forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody:result];
        
        error = nil;
        
        //fire the request and wait for response
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            @try {
                NSError *error;
                NSArray *fetchedData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
                NSString *decodedstring = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSLog(@"fetched data is %@",fetchedData);
                NSLog(@"decoded string is %@",decodedstring);
                
                [self.delegate loadedProfile:fetchedData];
            }
            @catch (NSException *exception) {
                NSLog(@"fetch profile exception is %@",exception);
            }
            @finally {
                NSLog(@"ran thorugh dojo info retrieval");
            }
        }];
    }
    @catch (NSException *exception) {
        NSLog(@"network latency issue with %@",exception);
    }
    @finally {
    }
}


-(void)loadDojo:(NSDictionary *)dojoInfo
{
    @try {
        //[self.navigationController.view setBackgroundColor:[UIColor colorWithRed:0 green:0.678 blue:255 alpha:1]];
        // Pass any objects to the view controller here, like...
        NSError *error;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *keysPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"keysNkrates.plist"]];
        
        NSDictionary *userInfo = [[NSDictionary alloc] initWithContentsOfFile:keysPath];
        NSLog(@"dojohash is %@",[dojoInfo valueForKey:@"dojohash"]);
        NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[[userInfo objectForKey:@"username"],[dojoInfo valueForKey:@"dojohash"], [userInfo objectForKey:@"token"]] forKeys:@[@"username",@"dojohash",@"token"]];
        NSData *result =[NSJSONSerialization dataWithJSONObject:dataDict options:0 error:&error];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%sgetDojoInfo.php",SERVERADDRESS]]];
        
        //customize request information
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:[NSString stringWithFormat:@"%ld", (long)dataDict.count] forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody:result];
        
        error = nil;
        
        //fire the request and wait for response
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            @try {
                NSError *error;
                NSArray *fetchedData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
                NSString *decodedString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSLog(@"DECODESTRING get dojo data %@",decodedString);
                [self.delegate loadedDojo:fetchedData];
            }
            @catch (NSException *exception)
            {
                NSLog(@"asynch load dojo error is %@",exception);
            }
            @finally
            {
                NSLog(@"finally ran the asynch load dojo execuvte");
            }
        }];
    }
    @catch (NSException *exception)
    {
        NSLog(@"load dojo exception is %@",exception);
    }
    @finally
    {
        NSLog(@"ran through load dojo shenanigans");
    }
}

-(void)loadCommentBoard:(NSDictionary *)postInfo
{
    NSLog(@"SWAGSWAG IS A POST");
    @try
    {
        NSError *error;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *keysPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"keysNkrates.plist"]];
        NSDictionary *userInfo = [[NSDictionary alloc] initWithContentsOfFile:keysPath];
        
        NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[[postInfo objectForKey:@"posthash"],[userInfo objectForKey:@"username"],[userInfo objectForKey:@"token"]] forKeys:@[@"posthash",@"username",@"token"]];
        NSLog(@"dictionary is :%@",dataDict);
        NSData *result =[NSJSONSerialization dataWithJSONObject:dataDict options:0 error:&error];
        NSLog(@"encoded json is %@",result);
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%sgetMessageBoardForPost.php",SERVERADDRESS]]];
        
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
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
            @try {
                NSArray *boardData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                NSString *decodedString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSLog(@"%@",result);
                NSLog(@"board data is %@",boardData);
                NSLog(@"%@",decodedString);
                [self.delegate loadedCommentBoard:boardData];
            }
            @catch (NSException *exception) {
                NSLog(@"exception is %@",exception);
            }
            @finally {
                NSLog(@"ran through asynch block");
            }
        }];
    }
    @catch (NSException *exception)
    {
        NSLog(@"exception is %@",exception);
    }
    @finally
    {
        NSLog(@"FINALLY1213");
    }
}

-(void)loadMessageBoard:(NSDictionary *)dojoInfo
{
    @try {
        NSError *error;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *keysPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"keysNkrates.plist"]];
        NSDictionary *userInfo = [[NSDictionary alloc] initWithContentsOfFile:keysPath];
        
        NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[[dojoInfo objectForKey:@"dojohash"],[userInfo objectForKey:@"username"],[userInfo objectForKey:@"token"]] forKeys:@[@"dojohash",@"username",@"token"]];
        NSLog(@"IN HYAH dictionary is :%@",dataDict);
        NSData *result =[NSJSONSerialization dataWithJSONObject:dataDict options:0 error:&error];
        NSLog(@"encoded json is %@",result);
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%sgetMessageBoard.php",SERVERADDRESS]]];
        
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
            @try
            {
                NSError *error;
                NSArray *boardData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                NSString *decodedString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSLog(@"%@",result);
                NSLog(@"board data %@",boardData);
                NSLog(@"%@",decodedString);
                [self.delegate loadedMessageBoard:boardData];
            }
            @catch (NSException *exception)
            {
                NSLog(@"didLoad asynch excpetion %@",exception);
            }
            @finally
            {
                NSLog(@"swag motha swag");
            }
        }];
    }
    @catch (NSException *exception)
    {
        NSLog(@"fetch message board asynch excpetion %@",exception);
    }
    @finally
    {
        NSLog(@"daddy king swag swag");
    }
}



-(NSDictionary *)authMe:(NSDictionary *)accountInfo
{
    NSString *nameString = [accountInfo objectForKey:@"name"];
    NSString *numberString = [accountInfo objectForKey:@"number"];
    NSString *word = [accountInfo objectForKey:@"word"];
    NSString *username = [accountInfo objectForKey:@"username"];
    
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
    
    NSDictionary *keysDict = [[NSDictionary alloc] init];
    @try {
        NSError *error;
        NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[[NSString stringWithFormat:@"%f",salt3],nameString] forKeys:@[@"salt3",@"fullname"]];
        NSLog(@"dictionary is :%@",dataDict);
        NSData *result =[NSJSONSerialization dataWithJSONObject:dataDict options:0 error:&error];
        NSLog(@"encoded json is %@",result);
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%sauthMe.php",SERVERADDRESS]]];
        
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
        if ([decodedString isEqualToString:[NSString stringWithFormat:@"%ld",p]])
        {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *keysPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"keysNkrates.plist"]];
            keysDict = [[NSDictionary alloc] initWithObjects:@[nameString, numberString, word] forKeys:@[@"name",@"number",@"word"]];
            [keysDict writeToFile:keysPath atomically:YES];
        }
        else
        {
            
        }
        
    }
    @catch (NSException *exception) {
        NSLog(@"exception is %@", exception);
    }
    @finally {
        NSLog(@"ran through login block");
    }
    return keysDict;
}

-(NSDictionary *)loginAccount:(NSDictionary *)accountInfo
{
    NSString *nameString = [accountInfo objectForKey:@"name"];
    NSString *numberString = [accountInfo objectForKey:@"number"];
    NSString *word = [accountInfo objectForKey:@"word"];
    
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
    
    NSMutableDictionary *keysDict = [[NSMutableDictionary alloc] init];
    @try {
        NSError *error;
        NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[[NSString stringWithFormat:@"%f",salt1],nameString] forKeys:@[@"salt1",@"fullname"]];
        NSLog(@"dictionary is :%@",dataDict);
        NSData *result =[NSJSONSerialization dataWithJSONObject:dataDict options:0 error:&error];
        NSLog(@"encoded json is %@",result);
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%sauthMe.php",SERVERADDRESS]]];
        
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
        
        if ([[NSString stringWithFormat:@"%@",[dataConv objectAtIndex:0]] isEqualToString:[NSString stringWithFormat:@"%ld",p]])
        {
            NSLog(@"is the right user");
            NSString *username = [[[dataConv objectAtIndex:1] objectAtIndex:0] objectForKey:@"username"];
            NSError *error;
            NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[[NSString stringWithFormat:@"%f",salt3],username] forKeys:@[@"salt3",@"username"]];
            NSLog(@"dictionary is :%@",dataDict);
            NSData *result =[NSJSONSerialization dataWithJSONObject:dataDict options:0 error:&error];
            NSLog(@"encoded json is %@",result);
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%sauthMeRight.php",SERVERADDRESS]]];
            
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
            NSLog(@"AUTH ME RIGHT <<<<<");
            NSLog(@"%@",result);
            NSLog(@"%@",dataConv);
            NSLog(@"%@",decodedString);
            
            if ([[dataConv objectAtIndex:0] isEqualToString:@"success"])
            {
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentsDirectory = [paths objectAtIndex:0];
                NSString *keysPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"keysNkrates.plist"]];
                
                if ([[NSFileManager defaultManager] fileExistsAtPath:keysPath])
                {
                    [[NSFileManager defaultManager] removeItemAtPath:keysPath error:nil];
                }
                
                keysDict = [[NSMutableDictionary alloc] initWithDictionary:[[dataConv objectAtIndex:1] objectAtIndex:0]];
                [keysDict setObject:nameString forKey:@"name"];
                [keysDict setObject:numberString forKey:@"number"];
                [keysDict setObject:word forKey:@"word"];
                [keysDict setObject:@"success" forKey:@"result"];
                NSLog(@"keys dict is %@",keysDict);
                [keysDict writeToFile:keysPath atomically:YES];
                return keysDict;
            }
        }
        else
        {
            NSLog(@"is the wrong user");
        }
    }
    @catch (NSException *exception) {
        NSLog(@"exception is %@", exception);
    }
    @finally {
        NSLog(@"ran through login block");
    }
    return keysDict;
}

-(NSDictionary *)createAccount:(NSDictionary *)accountInfo
{
    NSString *nameString = [accountInfo objectForKey:@"name"];
    NSString *numberString = [accountInfo objectForKey:@"number"];
    NSString *word = [accountInfo objectForKey:@"word"];
    NSString *username = [accountInfo objectForKey:@"username"];
    
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
    
    NSMutableDictionary *keysDict = [[NSMutableDictionary alloc] init];
    @try {
        NSError *error;
        NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[[NSString stringWithFormat:@"%f",salt3],username,nameString] forKeys:@[@"salt1",@"username",@"fullname"]];
        NSLog(@"dictionary is :%@",dataDict);
        NSData *result =[NSJSONSerialization dataWithJSONObject:dataDict options:0 error:&error];
        NSLog(@"encoded json is %@",result);
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%saddUser.php",SERVERADDRESS]]];
        
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
        
        if ([[dataConv objectAtIndex:0] isEqualToString:@"made"])
        {
            // successfully made account
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *keysPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"keysNkrates.plist"]];
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:keysPath])
            {
                [[NSFileManager defaultManager] removeItemAtPath:keysPath error:nil];
            }
            
            keysDict = [[NSMutableDictionary alloc] initWithDictionary:[[dataConv objectAtIndex:1] objectAtIndex:0]];
            [keysDict setObject:nameString forKey:@"name"];
            [keysDict setObject:numberString forKey:@"number"];
            [keysDict setObject:word forKey:@"word"];
            [keysDict setObject:@"made" forKey:@"result"];
            [keysDict writeToFile:keysPath atomically:YES];
            return keysDict;
        }
        else
        {
            // return
            return keysDict;
        }
        /*
        if ([decodedString isEqualToString:[NSString stringWithFormat:@"%ld",p]])
        {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *keysPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"keysNkrates.plist"]];
            keysDict = [[NSMutableDictionary alloc] initWithDictionary:accountInfo];
            [keysDict writeToFile:keysPath atomically:YES];
        }
        else
        {
            
        }
         */
        
    }
    @catch (NSException *exception) {
        NSLog(@"exception is %@", exception);
    }
    @finally {
        NSLog(@"ran through login block");
    }
    return keysDict;
}

-(void)getHomeDataWithLongitude:(double)longitude latitude:(double)latitude
{
    // successfully made account
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *keysPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"keysNkrates.plist"]];
    
    NSDictionary *userInfo = [[NSDictionary alloc] initWithContentsOfFile:keysPath];
    @try {
        NSError *error;
        NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[[userInfo objectForKey:@"username"], @"", [NSNumber numberWithDouble:latitude], [NSNumber numberWithDouble:longitude],[userInfo objectForKey:@"token"]] forKeys:@[@"username", @"dojo",@"lati",@"longi",@"token"]];
        NSLog(@"dacia sandero is %@",dataDict);
        NSData *result =[NSJSONSerialization dataWithJSONObject:dataDict options:0 error:&error];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%ssearchByLocation.php",SERVERADDRESS]]];
        ////NSLog(@"SERVERUPDATE %@",[NSString stringWithFormat:@"%ssearchForDojo.php",SERVERADDRESS]);
        
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
             @try {
                 NSError *error;
                 //NSLog(@"about to reload this data");
                 NSArray *locationTableViewData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
                 NSLog(@"tableViewData is %@",locationTableViewData);
                 NSString *decodedString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                 NSLog(@"decodestring LOCATION DATA: %@",decodedString);
                 NSString *locationData = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"oldLocationData.plist"]];
                 [locationTableViewData writeToFile:locationData atomically:YES];
                 
                 [self.delegate receivedLocationData:locationTableViewData];
             }
             @catch (NSException *exception) {
                 NSLog(@"super hyper swag %@",exception);
             }
             @finally {
                 NSLog(@"bombazzilly doo damnb");
             }
             [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         }];
    }
    @catch (NSException *exception) {
        NSLog(@"SAWFALDSKG SFinvite yourself serch4dojoproblem load: %@",exception);
        //UIAlertView *networkFailure = [[UIAlertView alloc] initWithTitle:@"netwerk" message:@"connection broke, cant load page" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        //[networkFailure show];
    }
    @finally {
        //NSLog(@"elev8");
    }
}

-(void)getNotificationList:(NSString *)searchText
{
    if ([searchText isEqualToString:@""])
    {
        @try {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *keysPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"keysNkrates.plist"]];
            
            NSDictionary *userInfo = [[NSDictionary alloc] initWithContentsOfFile:keysPath];
            NSError *error;
            NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[[userInfo objectForKey:@"username"], searchText, [NSNumber numberWithDouble:0], [NSNumber numberWithDouble:0], [userInfo objectForKey:@"token"]] forKeys:@[@"username", @"dojo",@"lati",@"longi",@"token"]];
            NSLog(@"dacia sandero mega is %@",dataDict);
            NSData *result =[NSJSONSerialization dataWithJSONObject:dataDict options:0 error:&error];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%sgetNotificationPage.php",SERVERADDRESS]]];
            ////NSLog(@"SERVERUPDATE %@",[NSString stringWithFormat:@"%ssearchForDojo.php",SERVERADDRESS]);
            
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
                 @try {
                     NSError *error;
                     NSArray *ultraLoad = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
                     NSString *decodedString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                     NSLog(@"ultra load IS \n%@",ultraLoad);
                     NSLog(@"decodestring = GET HOME LIST IS %@",decodedString);
                     [self.delegate receivedSearchData:ultraLoad];
                 }
                 @catch (NSException *exception) {
                     NSLog(@"not so volatile anymo my ***** %@",exception);
                 }
                 @finally {
                     NSLog(@"ok we finally ran that thingy");
                 }
                 [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
             }];
        }
        @catch (NSException *exception) {
            NSLog(@"get notification feed load: %@",exception);
            //UIAlertView *networkFailure = [[UIAlertView alloc] initWithTitle:@"netwerk" message:@"connection broke, cant load page" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
            //[networkFailure show];
        }
        @finally {
            //NSLog(@"elev8");
        }
    }
    else
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *keysPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"keysNkrates.plist"]];
        NSDictionary *userInfo = [[NSDictionary alloc] initWithContentsOfFile:keysPath];
        @try {
            NSError *error;
            NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[[userInfo objectForKey:@"username"], searchText, [NSNumber numberWithDouble:0], [NSNumber numberWithDouble:0],[userInfo objectForKey:@"token"]] forKeys:@[@"username", @"string",@"lati",@"longi",@"token"]];
            NSLog(@"dacia sandero 2 is %@",dataDict);
            NSData *result =[NSJSONSerialization dataWithJSONObject:dataDict options:0 error:&error];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%ssearchMixed.php",SERVERADDRESS]]];
            
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
                @try {
                    NSError *error;
                    NSArray *notificationFeedData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
                    NSString *decodedString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    NSLog(@"GET SEARCH LIST IS \n%@",notificationFeedData);
                    NSLog(@"decodestring = GET HOME LIST IS %@",decodedString);
                    [self.delegate receivedSearchData:notificationFeedData];
                }
                @catch (NSException *exception) {
                    NSLog(@"exception is %@",exception);
                }
                @finally {
                    NSLog(@"finally managed to do this");
                }
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            }];
            
        }
        @catch (NSException *exception) {
            NSLog(@"search mixed load issue: %@",exception);
        }
        @finally {
            //NSLog(@"elev8");
        }
    }
}


-(void)createDojoWithName:(NSString *)name withLati:(double)lati withLongi:(double)longi
{
    @try {
        NSError *error;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *keysPath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"keysNkrates.plist"]];
        
        NSDictionary *userInfo = [[NSDictionary alloc] initWithContentsOfFile:keysPath];
        NSDictionary *dataDict = [[NSDictionary alloc] initWithObjects:@[[userInfo objectForKey:@"username"],name,[self generateCode], [NSNumber numberWithDouble:lati], [NSNumber numberWithDouble:longi],[userInfo objectForKey:@"token"]] forKeys:@[@"username",@"name",@"dojohash",@"lati", @"longi",@"token"]];
        NSLog(@"dictionary is :%@",dataDict);
        NSData *result =[NSJSONSerialization dataWithJSONObject:dataDict options:0 error:&error];
        NSLog(@"encoded json is %@",result);
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%sadd_dojo.php",SERVERADDRESS]]];
        
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
        
        [self.delegate createdDojo:dataConv];
    }
    @catch (NSException *exception) {
        NSLog(@"create dojo exception is %@",exception);
    }
    @finally {
        NSLog(@"finally ran this thang");
    }
}
            
-(NSString *)generateCode
{
    static NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXZY";
    static NSString *digits = @"0123456789";
    NSMutableString *s = [NSMutableString stringWithCapacity:8];
    //returns 19 random chars into array (mutable string)
    for (NSUInteger i = 0; i < 4; i++) {
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
    //NSLog(@"s-->%@",s);
    return s;
}

@end
