//
//  SZOARequest.m
//  Socialize
//
//  Created by Nathaniel Griswold on 7/10/12.
//  Copyright (c) 2012 Socialize. All rights reserved.
//

#import "SZOARequest.h"
#import "socialize_globals.h"
#import "SDKHelpers.h"
#import <OAuthConsumer/OAuthConsumer.h>

@interface SZOARequest ()
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, strong) OAMutableURLRequest *request;
@property (nonatomic, retain) OADataFetcher *fetcher;
@end

@implementation SZOARequest


- (id)initWithConsumerKey:(NSString*)consumerKey
           consumerSecret:(NSString*)consumerSecret
                    token:(NSString*)token
              tokenSecret:(NSString*)tokenSecret
                   method:(NSString*)method
                   scheme:(NSString*)scheme
                     host:(NSString*)host
                     path:(NSString*)path
               parameters:(NSDictionary*)parameters
                multipart:(BOOL)multipart
                  success:(void(^)(NSURLResponse*, NSData *data))success
                  failure:(void(^)(NSError *error))failure {
    
    if (self = [super init]) {
        
        OAConsumer *consumer = [[OAConsumer alloc] initWithKey:consumerKey secret:consumerSecret];
        OAToken *tokenObject = nil;
        if ([token length] > 0 && [tokenSecret length] > 0) {
            tokenObject = [[OAToken alloc] initWithKey:token secret:tokenSecret];
        }
        
        NSString *trimmedPath = [path stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]];
        NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@://%@/%@", scheme, host, trimmedPath]];
        self.request = [[OAMutableURLRequest alloc] initWithURL:url consumer:consumer token:tokenObject realm:@"" signatureProvider:nil];
        
        [self.request setHTTPMethod:method];
        [self.request setHTTPShouldHandleCookies:NO];

        NSMutableArray *oaParams = [NSMutableArray arrayWithCapacity:[parameters count]];
		[parameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
			if ([obj conformsToProtocol:@protocol(NSFastEnumeration)]) {
				for (id subobject in obj) {
					[oaParams addObject:[OARequestParameter requestParameter:key value:subobject]];
				}
			} else {
				[oaParams addObject:[OARequestParameter requestParameter:key value:obj]];
			}
		}];
		 
		[self.request setParameters:oaParams];
		
		
		
		self.fetcher = [[OADataFetcher alloc] init];
		
        self.successBlock = success;
        self.failureBlock = failure;
    }
    
    return self;
}

- (void)setExecuting:(BOOL)executing {
    if (self.executing != executing) {
        [self willChangeValueForKey:@"isExecuting"];
        self.executing = executing;
        [self didChangeValueForKey:@"isExecuting"];
    }
}

- (void)setFinished:(BOOL)finished {
    if (self.finished != finished) {
        [self willChangeValueForKey:@"isFinished"];
        self.finished = finished;
        [self didChangeValueForKey:@"isFinished"];
    }
}

- (void)start {
    if ([self isCancelled]) {
        self.finished = YES;
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.executing = YES;

		[self.fetcher fetchDataWithRequest:self.request delegate:self didFinishSelector:@selector(fetcherDidFinishWithTicket:data:) didFailSelector:@selector(fetcherDidFailWithTicket:error:)];


    });
}

- (void)cancel {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self isExecuting]) {
            self.executing = NO;
            self.fetcher = nil;
        }

        if (![self isFinished]) {
            self.finished = YES;
            NSError *error = [NSError defaultSocializeErrorForCode:SocializeErrorRequestCancelled];
            BLOCK_CALL_1(self.failureBlock, error);
        }
    });
    
    [super cancel];
}

- (void)fetcherDidFinishWithTicket:(OAServiceTicket*)ticket data:(NSData*)data {
    NSHTTPURLResponse *response = ticket.response;
    if ([response statusCode] < 400) {
        BLOCK_CALL_2(self.successBlock, ticket.response, data);
    } else {
        NSString *responseString = NSStringForHTTPURLResponse(ticket.response, data);
        NSError *error = [NSError socializeServerReturnedHTTPErrorErrorWithResponse:ticket.response responseBody:responseString];
        BLOCK_CALL_1(self.failureBlock, error);
    }
    self.executing = NO;
    self.finished = YES;
}

- (void)fetcherDidFailWithTicket:(OAServiceTicket*)ticket error:(NSError*)error {
    BLOCK_CALL_1(self.failureBlock, error);
    
    self.executing = NO;
    self.finished = YES;
}

@end
