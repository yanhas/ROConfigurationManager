//
//  ROConfigurationManger.m
//  ROConfigurationManager
//
//  Created by Yaniv on 12/10/16.
//  Copyright © 2016 Yaniv. All rights reserved.
//

#import "ROConfigurationManger.h"

static NSDictionary<NSString *, NSString *> *responseObject;
const NSString * _Nonnull serverEndPoint  = @"http://localhost:3004/people";

@implementation ROConfigurationManager

-(instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:serverEndPoint]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:5];
    request.HTTPMethod = @"GET";
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *dt = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable responseData, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse *)response;
        
        // we don't want to assume a decode error if perhaps there is no data
        if (!responseData) {
            return ;
        }
        
        NSError *err = nil;
        NSDictionary *jsonArray = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&err];
        
        if (err != nil) {
            NSLog(@"Error parsing JSON.");
        }
        else {
            responseObject = jsonArray;
            NSLog(@"Array: %@", jsonArray);
        }
    }];
    
    [dt resume];
    
    return self;
}

-(id)ro_valueForKey:(NSString *)key {
    if (!responseObject) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
        });
    }
    
    return responseObject[key];
}

@end
