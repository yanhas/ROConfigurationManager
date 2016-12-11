//
//  TestingAppROTestUtils.m
//  TestingAppRO
//
//  Created by Yaniv on 12/10/16.
//  Copyright © 2016 Yaniv. All rights reserved.
//

#import "TestingAppROTestUtils.h"

@implementation TestingAppROTestUtils

-(instancetype)initWithEndpoint:(NSString *)endpoint {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.endPointForServer = endpoint;
    
    return self;
}

-(void)updateServerBlocking:(NSDictionary *)json {
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.endPointForServer]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:2];
    NSError *err;
    request.HTTPMethod = @"POST";
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:json
                                                       options:0
                                                         error:&err];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                          delegate:nil
                                                     delegateQueue:nil];
    
    NSURLSessionDataTask *dt = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable responseData, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        dispatch_group_leave(group);
    }];
    
    [dt resume];
    
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
}

@end
