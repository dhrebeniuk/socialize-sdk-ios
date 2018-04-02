
//
//  SocializeFacebookInterface.m
//  SocializeSDK
//
//  Created by Nathaniel Griswold on 10/31/11.
//  Copyright (c) 2011 Socialize, Inc. All rights reserved.
//

#import "SocializeFacebookInterface.h"
#import "SocializeThirdPartyFacebook.h"
#import "socialize_globals.h"
#import "SZFacebookUtils.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>

static const int FBRESTAPIAccessTokenErrorCode = 190;

static SocializeFacebookInterface *sharedFacebookInterface;

typedef void (^RequestCompletionBlock)(id result, NSError *error);

@interface SocializeFacebookInterface () <SocializeFBRequestDelegate>
@end

@implementation SocializeFacebookInterface
@synthesize facebook = facebook_;
@synthesize handlers = handlers_;

- (void)dealloc {
    self.facebook = nil;
    self.handlers = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dealloc];
}

- (id)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    
    return self;
}

- (void)tryToExtendAccessToken {
    if ([SZFacebookUtils isAvailable] && [SZFacebookUtils isLinked]) {
        [self.facebook extendAccessToken];
    }
}

- (void)applicationDidBecomeActive:(NSNotification*)notification {
    [self tryToExtendAccessToken];
}

+ (void)load {
    (void)[self sharedFacebookInterface];
}

+ (SocializeFacebookInterface*)sharedFacebookInterface {
    if (sharedFacebookInterface == nil) {
        sharedFacebookInterface = [[SocializeFacebookInterface alloc] init];
    }
    
    return sharedFacebookInterface;
}

- (SocializeFacebook*)facebook {
    if (facebook_ == nil) {// || ![facebook_ isForCurrentSocializeSession]) {
        facebook_ = [[SocializeThirdPartyFacebook createFacebookClient] retain];
        facebook_.sessionDelegate = self;
    }

    return facebook_;
}

- (NSMutableDictionary*)handlers {
    if (handlers_ == nil) handlers_ = [[NSMutableDictionary alloc] init];
    return handlers_;
}

- (NSValue*)requestIdentifier:(FBSDKGraphRequest *)request {
    return [NSValue valueWithPointer:request];
}

- (void)removeHandlerForRequest:(FBSDKGraphRequest *)request {
    NSValue *requestId = [self requestIdentifier:request];
    if ([self.handlers objectForKey:requestId]) {
        [self.handlers removeObjectForKey:requestId];
    }
}

- (void)requestWithGraphPath:(NSString*)graphPath
                      params:(NSDictionary*)params
                  httpMethod:(NSString*)httpMethod
                  completion:(void (^)(id result, NSError *error))completion {
    if (params == nil) {
        params = [NSMutableDictionary dictionary];
    }
	FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:graphPath parameters:[[params mutableCopy] autorelease] HTTPMethod:httpMethod];

	[request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
		if (error == nil) {
			RequestCompletionBlock completionBlock = [self.handlers objectForKey:[self requestIdentifier:request]];
			completionBlock(result, nil);
			[self removeHandlerForRequest:request];
		}
		else {
			if ([[[[error userInfo] objectForKey:@"error"] objectForKey:@"code"] integerValue] == FBRESTAPIAccessTokenErrorCode) {
				[self wipeLocalSession];
			}
			
			DebugLog(@"Facebook Wall Post Failed! Description: %@ %@", [error localizedDescription], [error userInfo]);
			RequestCompletionBlock completionBlock = [self.handlers objectForKey:[self requestIdentifier:request]];
			completionBlock(nil, error);
			[self removeHandlerForRequest:request];
		}
	}];
	
	NSValue *requestId = [self requestIdentifier:request];
    NSAssert([self.handlers objectForKey:requestId] == nil, @"Key for request %@ already exists (should be nil)", requestId);
    
    if (completion != nil) {
        [self.handlers setObject:[[completion copy] autorelease] forKey:requestId];
    }
}

- (void)wipeLocalSession {
    self.facebook = nil;
    [SocializeThirdPartyFacebook removeLocalCredentials];
}

- (void)fbDidLogin {
    // Unused here    
}

- (void)fbDidLogout {
    // Unused here    
}

- (void)fbDidExtendToken:(NSString *)accessToken expiresAt:(NSDate *)expiresAt {
    [SocializeThirdPartyFacebook storeLocalCredentialsWithAccessToken:accessToken expirationDate:expiresAt];
}

- (void)fbDidNotLogin:(BOOL)cancelled {
    // Unused here
}

- (void)fbSessionInvalidated {
    [self wipeLocalSession];
}

@end
