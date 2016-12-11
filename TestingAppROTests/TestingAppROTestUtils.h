//
//  TestingAppROTestUtils.h
//  TestingAppRO
//
//  Created by Yaniv on 12/10/16.
//  Copyright © 2016 Yaniv. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TestingAppROTestUtils : NSObject

@property (nonatomic, strong) NSString *endPointForServer;

-(instancetype)initWithEndpoint:(NSString *)endpoint;

-(void)updateServerBlocking:(NSDictionary *)json;

@end
