//
//  SocializeDataFetcher.h
//  SocializeSDK
//
//  Created by Fawad Haider on 7/13/11.
//  Copyright 2011 Socialize, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OAuthConsumer/OAuthConsumer.h>

@interface SocializeDataFetcher : OADataFetcher {
    NSArray        *_trustedHosts;
}


@property (retain, nonatomic) NSArray* trustedHosts;

@end
