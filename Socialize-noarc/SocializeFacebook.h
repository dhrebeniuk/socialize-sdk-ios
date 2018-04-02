//
//  SocializeFacebook.h
//  Socialize
//
//  Created by David Jedeikin on 10/20/14.
//  Copyright (c) 2014 Socialize. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@protocol SocializeFBSessionDelegate;
@protocol SocializeFBRequestDelegate;

@interface SocializeFacebook : NSObject

@property (nonatomic, copy) NSString *accessToken;
@property (nonatomic, copy) NSDate *expirationDate;
@property (nonatomic, assign) id<SocializeFBSessionDelegate> sessionDelegate;
@property (nonatomic, copy) NSString *urlSchemeSuffix;
@property (nonatomic, readonly) BOOL isFrictionlessRequestsEnabled;

- (instancetype)initWithAppId:(NSString *)appId
              urlSchemeSuffix:(NSString *)urlSchemeSuffix
                  andDelegate:(id<SocializeFBSessionDelegate>)delegate;

- (void)authorize:(NSArray *)permissions fromViewController:(UIViewController *)fromViewController;

- (BOOL)handleOpenURL:(NSURL *)url;

- (void)extendAccessToken;

- (FBSDKGraphRequest *)requestWithGraphPath:(NSString *)graphPath
                          andParams:(NSMutableDictionary *)params
                      andHttpMethod:(NSString *)httpMethod
                        andDelegate:(id<SocializeFBRequestDelegate>)delegate;

@end

////////////////////////////////////////////////////////////////////////////////

/**
 * Your application should implement this delegate to receive session callbacks.
 */
@protocol SocializeFBSessionDelegate <NSObject>

/**
 * Called when the user successfully logged in.
 */
- (void)fbDidLogin;

/**
 * Called when the user dismissed the dialog without logging in.
 */
- (void)fbDidNotLogin:(BOOL)cancelled;

/**
 * Called after the access token was extended. If your application has any
 * references to the previous access token (for example, if your application
 * stores the previous access token in persistent storage), your application
 * should overwrite the old access token with the new one in this method.
 * See extendAccessToken for more details.
 */
- (void)fbDidExtendToken:(NSString *)accessToken
               expiresAt:(NSDate *)expiresAt;

/**
 * Called when the user logged out.
 */
- (void)fbDidLogout;

/**
 * Called when the current session has expired. This might happen when:
 *  - the access token expired
 *  - the app has been disabled
 *  - the user revoked the app's permissions
 *  - the user changed his or her password
 */
- (void)fbSessionInvalidated;

@end

enum {
    kFBRequestStateReady,
    kFBRequestStateLoading,
    kFBRequestStateComplete,
    kFBRequestStateError
};

////////////////////////////////////////////////////////////////////////////////

/*
 *Your application should implement this delegate
 */
@protocol SocializeFBRequestDelegate <NSObject>

@optional

/**
 * Called just before the request is sent to the server.
 */
- (void)requestLoading:(FBSDKGraphRequest *)request;

/**
 * Called when the Facebook API request has returned a response.
 *
 * This callback gives you access to the raw response. It's called before
 * (void)request:(FBSDKGraphRequest *)request didLoad:(id)result,
 * which is passed the parsed response object.
 */
- (void)request:(FBSDKGraphRequest *)request didReceiveResponse:(NSURLResponse *)response;

/**
 * Called when an error prevents the request from completing successfully.
 */
- (void)request:(FBSDKGraphRequest *)request didFailWithError:(NSError *)error;

/**
 * Called when a request returns and its response has been parsed into
 * an object.
 *
 * The resulting object may be a dictionary, an array or a string, depending
 * on the format of the API response. If you need access to the raw response,
 * use:
 *
 * (void)request:(FBSDKGraphRequest *)request
 *      didReceiveResponse:(NSURLResponse *)response
 */
- (void)request:(FBSDKGraphRequest *)request didLoad:(id)result;

/**
 * Called when a request returns a response.
 *
 * The result object is the raw response from the server of type NSData
 */
- (void)request:(FBSDKGraphRequest *)request didLoadRawResponse:(NSData *)data;

@end
