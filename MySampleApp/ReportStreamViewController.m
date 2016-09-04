//
//  ReportStreamViewController.m
//  Livi
//
//  Created by Carlos Robinson on 8/17/16.
//  Copyright © 2016 livi. All rights reserved.
//

#import "ReportStreamViewController.h"

@interface ReportStreamViewController ()

@end

@implementation ReportStreamViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)back:(id)sender {
    [self dismiss];
}

-(void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
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
