//
//  ROConfigurationManger.m
//  ROConfigurationManager
//
//  Created by Yaniv on 12/10/16.
//  Copyright © 2016 Yaniv. All rights reserved.
//

#import "ROConfigurationManager.h"
#import "TMDiskCache.h"

//Here to save time so we won't fetch from cache every time
static NSMutableDictionary<NSString *, NSString *> *responseObject;
const int timeInterval = 5;

//Error handling
typedef void(^ErrorBlock)(void);
typedef void(^SuccessBlock)(void);

@interface ROConfigurationManager()

@property (nonatomic, strong) NSString *endPoint;
@property (nonatomic, strong) TMDiskCache *cache;
@property (nonatomic, strong) NSMutableDictionary *appValues;

@end

@implementation ROConfigurationManager


#pragma mark -
#pragma mark LifeCycle methods
static ROConfigurationManager *cm = nil;
-(NSString *)description {
    return [NSString stringWithFormat:@"Configuration:\nendpoint = %@\ncache = %@\nappValues = %@\ro = %@", self.endPoint, self.cache, self.appValues, responseObject];
}

+(instancetype)configurationManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cm = [[ROConfigurationManager alloc] initWithEndPoint:@"http://localhost:3004/people"];
    });
    
    return cm;
}

-(void)setEndpoint:(NSString *)endPoint {
    cm = [[ROConfigurationManager configurationManager] initWithEndPoint:endPoint];
}

-(instancetype)initWithEndPoint:(NSString *)endPoint {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    if (!endPoint) {
        return nil;
    }
    
    self.endPoint = endPoint;
    self.cache = [TMDiskCache sharedCache];
    self.appValues = [NSMutableDictionary new];
    
    [self getResponseFromServerNonBlockingApp:endPoint];
    
    return self;
}


#pragma mark -
#pragma mark APIs

-(id)ro_valueForKey:(NSString *)key {
    if (!self.appValues[key]) {
        //Check if we do not have something in cache
        if (![self.cache objectForKey:@"response"]) {
            [self getResponseFromServerBlockingApp:self.endPoint
                                        errorBlock:^{
                                            @synchronized (responseObject) {
                                                responseObject = (NSMutableDictionary *)[self.cache objectForKey:@"response"];
                                                if (responseObject[key]) {
                                                    [self.appValues setObject:responseObject[key] forKey:key];
                                                }
                                            }
                                        }
                                      successBlock:^{
                                          @synchronized (responseObject) {
                                              if (responseObject[key]) {
                                                  [self.appValues setObject:responseObject[key] forKey:key];
                                              }
                                          }
                                      }];
        } else {
            //We have something in cache, use that
            @synchronized (responseObject) {
                responseObject = (NSMutableDictionary *)[self.cache objectForKey:@"response"];
                if (responseObject[key]) {
                    [self.appValues setObject:responseObject[key] forKey:key];
                }
            }
                
        }
    }
    
    return [self.appValues objectForKey:key];
}

-(void)ro_refetchResponseFromServer {
    [self getResponseFromServerNonBlockingApp:self.endPoint];
}


#pragma mark -
#pragma mark Internals
-(void)getResponseFromServerNonBlockingApp:(NSString *)endPoint {
    
    NSMutableURLRequest *request = [self createRequest:endPoint];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                          delegate:nil
                                                     delegateQueue:nil];
    
    NSURLSessionDataTask *dt = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable responseData, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (!responseData || error) {
            return;
        }
        
        NSError *err = nil;
        NSDictionary *jsonArray = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&err];
        
        if (err != nil) {
            NSLog(@"Error parsing JSON.");
        } else {
            @synchronized (responseObject) {
                responseObject = [jsonArray copy];
                [self.cache setObject:responseObject forKey:@"response"];
            }
        }
    }];
    
    [dt resume];
}

-(void)getResponseFromServerBlockingApp:(NSString *)endPoint
                             errorBlock:(ErrorBlock)errorBlock
                           successBlock:(SuccessBlock)successBlock {
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    
    
    NSMutableURLRequest *request = [self createRequest:endPoint];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                          delegate:nil
                                                     delegateQueue:nil];
    
    NSURLSessionDataTask *dt = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable responseData, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (!responseData || error) {
            errorBlock();
            dispatch_group_leave(group);
            return;
        }
        
        NSError *err = nil;
        NSDictionary *jsonArray = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&err];
        
        if (err != nil) {
            NSLog(@"Error parsing JSON.");
            errorBlock();
        } else {
            @synchronized (responseObject) {
                responseObject = [jsonArray copy];
                [self.cache setObject:responseObject forKey:@"response"];
                successBlock();
            }
        }
        
        dispatch_group_leave(group);
    }];
    
    [dt resume];
    
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
}

-(NSMutableURLRequest *)createRequest:(NSString *)endPoint {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:endPoint]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:timeInterval];
    request.HTTPMethod = @"GET";
    return request;
}

@end
