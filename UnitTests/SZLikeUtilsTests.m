//
//  SZLikeUtilsTests.m
//  Socialize
//
//  Created by Nathaniel Griswold on 8/1/12.
//  Copyright (c) 2012 Socialize. All rights reserved.
//

#import "SZLikeUtilsTests.h"
#import "SZLikeUtils.h"

@implementation SZLikeUtilsTests

- (void)setUp {
    [super setUp];
    
    [self startMockingSharedSocialize];
    [SZTwitterUtils startMockingClass];
    [SZFacebookUtils startMockingClass];
    [SZUserUtils startMockingClass];
    [SZLocationUtils startMockingClass];
}

- (void)tearDown {
    [super tearDown];
    
    [self stopMockingSharedSocialize];
    [SZFacebookUtils stopMockingClassAndVerify];
    [SZTwitterUtils stopMockingClassAndVerify];
    [SZUserUtils stopMockingClassAndVerify];
    [SZLocationUtils stopMockingClassAndVerify];
}

- (void)testSucceedingFacebookOGLike {
    SZEntity *entity = [SZEntity entityWithKey:@"key" name:@"name"];
    
    [self stubOGLikeEnabled];
    [self stubIsAuthenticated];
    [self stubFacebookUsable];
    [self stubLocationSharingDisabled:NO];

    SZLikeOptions *options = [SZLikeOptions defaultOptions];

    __block BOOL willPostCalled = NO;
    options.willAttemptPostingToSocialNetworkBlock = ^(SZSocialNetwork network, SZSocialNetworkPostData *postData) {
        GHAssertEquals(network, SZSocialNetworkFacebook, @"Should be facebook");
        GHAssertEqualStrings(postData.path, @"me/og.likes", @"Should be og likes endpoint");
        willPostCalled = YES;
    };
    
    __block BOOL didPostCalled = NO;
    options.didSucceedPostingToSocialNetworkBlock = ^(SZSocialNetwork network, id result) {
        GHAssertEquals(network, SZSocialNetworkFacebook, @"Should be facebook");
        didPostCalled = YES;
    };

    __block BOOL didFailCalled = NO;
    options.didFailPostingToSocialNetworkBlock = ^(SZSocialNetwork network, NSError *error) {
        didFailCalled = YES;
    };
    
    [self succeedFacebookPostWithVerify:^void(NSString *path, NSDictionary *params) {
        GHAssertEqualStrings(path, @"me/og.likes", @"Should be og likes endpoint");
    }];
    
    [self succeedLikeCreateWithVerify:nil];
    [self stubShouldShareLocation];
    [self succeedGetLocation];
    
    [self prepare];
    [SZLikeUtils likeWithEntity:entity options:options networks:SZSocialNetworkFacebook success:^(id<SocializeLike> like) {
        [self notify:kGHUnitWaitStatusSuccess];
    } failure:^(NSError *error) {
        [self notify:kGHUnitWaitStatusFailure];
    }];

    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:0.5];
    
    GHAssertTrue(willPostCalled, @"willPost event not called");
    GHAssertTrue(didPostCalled, @"didPost event not called");
    GHAssertFalse(didFailCalled, @"didFail should not have been called");
}

- (void)testFailingFacebookLike {
    SZEntity *entity = [SZEntity entityWithKey:@"key" name:@"name"];
    
    [self stubOGLikeDisabled];
    [self stubIsAuthenticated];
    [self stubFacebookUsable];
    [self stubLocationSharingDisabled:NO];
    
    SZLikeOptions *options = [SZLikeOptions defaultOptions];
    
    __block BOOL willPostCalled = NO;
    options.willAttemptPostingToSocialNetworkBlock = ^(SZSocialNetwork network, SZSocialNetworkPostData *postData) {
        willPostCalled = YES;
    };
    
    __block BOOL didPostCalled = NO;
    options.didSucceedPostingToSocialNetworkBlock = ^(SZSocialNetwork network, id result) {
        didPostCalled = YES;
    };
    
    __block BOOL didFailCalled = NO;
    options.didFailPostingToSocialNetworkBlock = ^(SZSocialNetwork network, NSError *error) {
        didFailCalled = YES;
    };
    
    [self failFacebookPost];
    
    [self succeedLikeCreateWithVerify:nil];
    [self stubShouldShareLocation];
    [self succeedGetLocation];
    
    [self prepare];
    [SZLikeUtils likeWithEntity:entity options:options networks:SZSocialNetworkFacebook success:^(id<SocializeLike> like) {
        [self notify:kGHUnitWaitStatusSuccess];
    } failure:^(NSError *error) {
        [self notify:kGHUnitWaitStatusFailure];
    }];
    
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:0.5];
    
    GHAssertTrue(willPostCalled, @"willPost");
    GHAssertFalse(didPostCalled, @"didPost");
    GHAssertTrue(didFailCalled, @"didFail");
}

- (void)testSucceedingFacebookLike {
    SZEntity *entity = [SZEntity entityWithKey:@"key" name:@"name"];
    
    [self stubOGLikeDisabled];
    [self stubIsAuthenticated];
    [self stubFacebookUsable];
    [self stubLocationSharingDisabled:NO];

    SZLikeOptions *options = [SZLikeOptions defaultOptions];
    
    __block BOOL willPostCalled = NO;
    options.willAttemptPostingToSocialNetworkBlock = ^(SZSocialNetwork network, SZSocialNetworkPostData *postData) {
        GHAssertEquals(network, SZSocialNetworkFacebook, @"Should be facebook");
        GHAssertEqualStrings(postData.path, @"me/feed", @"Should be feed endpoint");
        willPostCalled = YES;
    };
    
    __block BOOL didPostCalled = NO;
    options.didSucceedPostingToSocialNetworkBlock = ^(SZSocialNetwork network, id result) {
        GHAssertEquals(network, SZSocialNetworkFacebook, @"Should be facebook");
        didPostCalled = YES;
    };
    
    __block BOOL didFailCalled = NO;
    options.didFailPostingToSocialNetworkBlock = ^(SZSocialNetwork network, id result) {
        didFailCalled = YES;
    };
    
    [self succeedFacebookPostWithVerify:^void(NSString *path, NSDictionary *params) {
        GHAssertEqualStrings(path, @"me/feed", @"Should be feed endpoint");
    }];
    
    [self succeedLikeCreateWithVerify:nil];
    [self stubShouldShareLocation];
    [self succeedGetLocation];
    
    [self prepare];
    [SZLikeUtils likeWithEntity:entity options:options networks:SZSocialNetworkFacebook success:^(id<SocializeLike> like) {
        [self notify:kGHUnitWaitStatusSuccess];
    } failure:^(NSError *error) {
        [self notify:kGHUnitWaitStatusFailure];
    }];
    
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:0.5];
    
    GHAssertTrue(willPostCalled, @"willPost event not called");
    GHAssertTrue(didPostCalled, @"didPost event not called");
    GHAssertFalse(didFailCalled, @"didFail should not have been called");
}

@end
