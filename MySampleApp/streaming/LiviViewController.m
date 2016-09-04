//
//  LiviViewController.m
//  Livi
//
//  Created by Carlos Robinson on 4/21/16.
//  Copyright © 2016 livi. All rights reserved.
//

#import "LiviViewController.h"
#import <Parse/Parse.h>
@interface LiviViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *mywebview;

@end

@implementation LiviViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    PFObject *gameScore = [PFObject objectWithClassName:@"Views"];
    gameScore[@"userId"] = [PFUser currentUser].objectId;
    gameScore[@"ownerId"] = _objectId;
    [gameScore saveInBackground];

    NSLog(@"%@", _urlString);
    [_mywebview setBackgroundColor:[UIColor whiteColor]];
    [_mywebview setOpaque:NO];
    //NSString *htmlString = [NSString stringWithFormat:@"<video src=\"http://54.164.51.55:1935/live/myStream/playlist.m3u8\">This browser does not support HTML5 video.</video>"];
    [_mywebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_urlString]]];
    //[_mywebview loadHTMLString:htmlString baseURL:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
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
