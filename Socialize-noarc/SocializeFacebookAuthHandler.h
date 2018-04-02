//
//  SocializeFacebookAuthHandler.h
//  SocializeSDK
//
//  Created by Nathaniel Griswold on 3/4/12.
//  Copyright (c) 2012 Socialize, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SocializeFacebook.h"

@interface SocializeFacebookAuthHandler : NSObject <SocializeFBSessionDelegate>

+ (SocializeFacebookAuthHandler*)sharedFacebookAuthHandler;
- (void)authenticateWithAppId:(NSString*)appId
              urlSchemeSuffix:(NSString*)urlSchemeSuffix
                  permissions:(NSArray*)permissions
 				fromViewController:(UIViewController *)fromViewController
                      success:(void(^)())success
                   foreground:(void(^)())foreground
                      failure:(void(^)(NSError*))failure;
- (BOOL)handleOpenURL:(NSURL*)url;
- (void)cancelAuthentication;

@property (nonatomic, retain) NSArray *permissions;
@property (nonatomic, copy) void (^successBlock)(NSString *accessToken, NSDate *expirationDate);
@property (nonatomic, copy) void (^foregroundBlock)();
@property (nonatomic, copy) void (^failureBlock)(NSError *error);
@property (nonatomic, retain) SocializeFacebook *facebook;
@property (nonatomic, assign) BOOL authenticating;
@end
