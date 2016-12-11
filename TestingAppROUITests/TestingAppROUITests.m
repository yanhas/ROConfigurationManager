//
//  TestingAppROUITests.m
//  TestingAppROUITests
//
//  Created by Yaniv on 12/8/16.
//  Copyright © 2016 Yaniv. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TestingAppROTestUtils.h"

static TestingAppROTestUtils *tu;
@interface TestingAppROUITests : XCTestCase

@end

@implementation TestingAppROUITests

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    tu = [[TestingAppROTestUtils alloc] initWithEndpoint:@"http:/localhost:3004/people"];
    [tu updateServerBlocking:@{@"color" : @"green", @"text" : @"start"}];
    self.continueAfterFailure = NO;
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    [[[XCUIApplication alloc] init] launch];
    
    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testValueDoesNotChangeAfterSet {
    [[[XCUIApplication alloc] init].buttons[@"ChangeBackground"] tap];
    wait(100);
    
    [tu updateServerBlocking:@{@"color" : @"blue",  @"text" : @"a"}];
    //Will stay green, because we already set it before
    [[[XCUIApplication alloc] init].buttons[@"ChangeBackground"] tap];
}

- (void)testValueDoesNotChangeAfterSetServerMutatesButCacheNot {
    //Green in setup
    [[[XCUIApplication alloc] init].buttons[@"ChangeBackground"] tap];
    wait(100);
    
    [tu updateServerBlocking:@{@"color" : @"blue",  @"text" : @"a"}];
    [[[XCUIApplication alloc] init].buttons[@"ChangeBackground"] tap];
    //Will remain green
    [[[XCUIApplication alloc] init].buttons[@"changeText"] tap];
    //Will change the text to "start", because we take the cached version and not the current
    wait(1000);
    //Will change text to a and not b
}

- (void)testValueDoesNotChangeAfterSetServerMutatesRefetchAndValueChanges {
    [tu updateServerBlocking:@{@"color" : @"blue", @"text" : @"b"}];
    //We are using cached value, meaning we will get what was set in setUp
    //The color will be green
    [[[XCUIApplication alloc] init].buttons[@"ChangeBackground"] tap];
    
    wait(1000);
    
    [tu updateServerBlocking:@{@"color" : @"blue", @"text" : @"c"}];
    [[[XCUIApplication alloc] init].buttons[@"Refetch"] tap];
    wait(1000);
    //Now that we refetched, the text will change to "c" and not "b"
    [[[XCUIApplication alloc] init].buttons[@"changeText"] tap];
    //Will change text to b and not start because of refetch
    wait(1000);
    [[[XCUIApplication alloc] init].buttons[@"ChangeBackground"] tap];
    //Color will stay green
    wait(1000);
    
}
@end
