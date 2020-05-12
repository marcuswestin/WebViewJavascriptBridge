//
//  FirstViewController.m
//  ExampleApp-iOS
//
//  Created by 侯森魁 on 2020/4/19.
//  Copyright © 2020 Marcus Westin. All rights reserved.
//

#import "FirstViewController.h"
#import "ExampleWKWebViewController.h"
@interface FirstViewController ()

@end

@implementation FirstViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"first page";
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"click me" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(jump) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(100, 200, 100, 40);
    button.center = self.view.center;
    self.view.backgroundColor = [UIColor redColor];
    [self.view addSubview:button];
    // Do any additional setup after loading the view.
}
- (void)jump{
//    UITabBarController *tabBarController = [[UITabBarController alloc] init];

    ExampleWKWebViewController* WKWebViewExampleController = [[ExampleWKWebViewController alloc] init];
//    WKWebViewExampleController.tabBarItem.title            = @"WKWebView";
//    [tabBarController addChildViewController:WKWebViewExampleController];
//    [self presentViewController:WKWebViewExampleController animated:YES completion:nil];
    [self.navigationController pushViewController:WKWebViewExampleController animated:YES];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
