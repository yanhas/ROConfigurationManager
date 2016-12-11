//
//  ViewController.m
//  TestingAppRO
//
//  Created by Yaniv on 12/8/16.
//  Copyright © 2016 Yaniv. All rights reserved.
//

#import "ViewController.h"
#import "ROConfigurationManager.h"

@implementation UIColor (UIColorFromString)

static NSDictionary *map = nil;

+(UIColor *)colorFromString:(NSString *)strColor {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        map  = @{
                 @"red" : [UIColor redColor],
                 @"blue" : [UIColor blueColor],
                 @"green" : [UIColor greenColor],
                 };
    });
    
    if (!map[strColor]) {
        return [UIColor clearColor];
    }
    
    return map[strColor];
}

@end

@interface ViewController ()

@property (strong, nonatomic) IBOutlet UIButton *button;
@property (strong, nonatomic) IBOutlet UIButton *changeText;
@property (strong, nonatomic) IBOutlet UIButton *refetchButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[ROConfigurationManager configurationManager] setEndpoint:@"http://localhost:3004/people"];

    [self.button addTarget:self action:@selector(buttonClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [self.changeText addTarget:self action:@selector(buttonClickedChangeText) forControlEvents:UIControlEventTouchUpInside];
    
    [self.refetchButton addTarget:self action:@selector(buttonClickedRefetch) forControlEvents:UIControlEventTouchUpInside];
}

-(void)buttonClicked {
    NSString *color = [[ROConfigurationManager configurationManager] ro_valueForKey:@"color"];
    UIColor *uiColor = [UIColor colorFromString:color];
    [self.button setBackgroundColor:uiColor];
}

-(void)buttonClickedChangeText {
    NSString *text = [[ROConfigurationManager configurationManager] ro_valueForKey:@"text"];
    [self.changeText setTitle:text forState:0];
}

-(void)buttonClickedRefetch {
    [[ROConfigurationManager configurationManager] ro_refetchResponseFromServer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
