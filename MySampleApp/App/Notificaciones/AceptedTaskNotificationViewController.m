//
//  AceptedTaskNotificationViewController.m
//  Livi
//
//  Created by Carlos Robinson on 4/26/16.
//  Copyright © 2016 livi. All rights reserved.
//

#import "AceptedTaskNotificationViewController.h"
#import "LiviViewController.h"

@interface AceptedTaskNotificationViewController ()

@end

@implementation AceptedTaskNotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    //[self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)viewAction:(id)sender {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Livi" bundle:nil];
    LiviViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"liviView"];
    viewController.urlString = [NSString stringWithFormat:@"http://54.164.51.55:1935/live/%@/playlist.m3u8", _userId];
    viewController.objectId = _userId;
    [self.navigationController pushViewController:viewController
                                         animated:YES];
    
}

@end
