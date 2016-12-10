//
//  ROConfigurationManger.h
//  ROConfigurationManager
//
//  Created by Yaniv on 12/10/16.
//  Copyright © 2016 Yaniv. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ROConfigurationManager : NSObject

-(instancetype)initWithEndPoint:(NSString *)endPoint;

-(id)ro_valueForKey:(NSString *)key;
-(void)refetchResponseFromServer;

@end
