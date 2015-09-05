//
//  NSObject+DOJOPerformAPIRequest.h
//  dojo
//
//  Created by Michael Zuccarino on 1/27/15.
//  Copyright (c) 2015 Michael Zuccarino. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol APIRequestDelegate <NSObject>

@optional
-(void)receivedLocationData:(NSArray *)locationData;
-(void)receivedSearchData:(NSArray *)searchData;
-(void)createdDojo:(NSArray *)createData;
-(void)loadedDojo:(NSArray *)dojoData;
-(void)loadedMessageBoard:(NSArray *)swagData;
-(void)loadedCommentBoard:(NSArray *)commentData;
-(void)loadedProfile:(NSArray *)profileData;
-(void)checkedSomeoneOut:(NSArray *)resultData;
-(void)gotUserInfo:(NSArray *)userInfo;
-(void)sentMessage:(NSString *)decodeString;
-(void)retrievedSendList:(NSArray *)sendList;
-(void)retrievedSendListForRepost:(NSArray *)sendList;
-(void)postedToDojos;
-(void)voteReported:(NSArray *)reportData;
-(void)followedADojo:(NSArray *)fetchedData;
-(void)receivedPushNotiSWAG:(NSArray *)delicious;
-(void)followedPerson:(NSArray *)fetchedData;
-(void)changedName;
-(void)changedProfilePicture;
-(void)deletedDojo;
-(void)deletedPost;
-(void)bioUpdated;
-(void)postedTextPost;

@end

@interface DOJOPerformAPIRequest : NSObject

@property (strong, nonatomic) id<APIRequestDelegate> delegate;

// admin stuffs
-(NSDictionary *)addADojo:(NSDictionary *)dojoInfo;
-(NSDictionary *)createAccount:(NSDictionary *)accountInfo;
-(NSDictionary *)loginAccount:(NSDictionary *)accountInfo;
-(NSDictionary *)deleteAccount:(NSDictionary *)accountInfo;
-(NSDictionary *)authMe:(NSDictionary *)accountInfo;
-(NSDictionary *)authMeRight:(NSDictionary *)accountInfo;

-(void)getHomeDataWithLongitude:(double)longitude latitude:(double)latitude;
-(void)getNotificationList:(NSString *)searchText;
-(void)createDojoWithName:(NSString *)name withLati:(double)lati withLongi:(double)longi;
-(void)loadDojo:(NSDictionary *)dojoInfo;
-(void)loadMessageBoard:(NSDictionary *)dojoInfo;
-(void)loadCommentBoard:(NSDictionary *)postInfo;
-(void)loadProfiledata:(NSDictionary *)userInfo;
-(void)checkSomeoneOut:(NSDictionary *)userInfo;
-(void)getUserInfo;
-(void)submitMessage:(NSDictionary *)dojoInfo withText:(NSString *)text;
-(void)submitAComment:(NSDictionary *)postInfo withText:(NSString *)text;
-(void)retrieveSendList;
-(void)retrieveSendListForRepost:(NSString *)posthash;
-(void)postToDojos:(NSArray *)dojos withHash:(NSString *)alabamaKush withDescription:(NSString *)postDescription isRepost:(BOOL)isRepost;
-(void)upvoteAPost:(NSDictionary *)postInfo;
-(void)downvoteAPost:(NSDictionary *)postInfo;
-(void)followADojo:(NSDictionary *)dojoInfo;
-(void)getNotificationService;
-(void)followSomeone:(NSDictionary *)personInfo;
-(void)changeName:(NSString *)newName;
-(void)changeProfilePicture:(NSString *)profhash;
-(void)deleteADojo:(NSString *)dojoash;
-(void)deleteAPost:(NSString *)posthash;
-(void)saveBio:(NSString *)bio;
-(void)postTextPost:(NSString *)post toDojo:(NSString *)dojohash;

// page data types
/*
-(NSDictionary *)checkIfFollow2Dojo2:(NSDictionary *)followInfo;
-(NSDictionary *)checkifFollowSomeone:(NSDictionary *)followInfo;
-(NSDictionary *)getDojoInfo:(NSDictionary *)dojoInfo;
-(NSDictionary *)getNotificationPage:(NSDictionary *)userInfo;
-(NSDictionary *)getNotificationService:(NSDictionary *)userInfo;
-(NSDictionary *)getUserInfo:(NSDictionary *)userInfo;
-(NSDictionary *)searchByLocation:(NSDictionary *)searchInfo;
-(NSDictionary *)searchMixed:(NSDictionary *)searchInfo;

// comments/ messages
-(NSDictionary *)getMessageBoard:(NSDictionary *)dojoInfo;
-(NSDictionary *)getMessageBoardForPost:(NSDictionary *)postInfo;
-(NSDictionary *)submitMessage:(NSDictionary *)messageInfo;
-(NSDictionary *)submitAComment:(NSDictionary *)messageInfo;

// posts
-(NSDictionary *)getSendList:(NSDictionary *)userInfo;
-(NSDictionary *)getSendListForRepost:(NSDictionary *)userInfo;
-(NSDictionary *)postToDojo:(NSDictionary *)postInfo;
-(NSDictionary *)repostAPost:(NSDictionary *)postInfo;
-(NSDictionary *)deleteAPost:(NSDictionary *)postInfo;
-(NSDictionary *)voteAPost:(NSDictionary *)postInfo;
*/
@end
