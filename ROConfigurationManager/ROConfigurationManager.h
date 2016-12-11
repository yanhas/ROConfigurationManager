//
//  ROConfigurationManger.h
//  ROConfigurationManager
//
//  Created by Yaniv on 12/10/16.
//  Copyright © 2016 Yaniv. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ROConfigurationManager : NSObject

//Return the singleton of configurationManager
+(instancetype)configurationManager;
//Fake API just to set the new endpoint
-(void)setEndpoint:(NSString *)endPoint;

//Return the value of the key requested
-(id)ro_valueForKey:(NSString *)key;
//Refetch the configuration from server and cache it
-(void)ro_refetchResponseFromServer;

@end
