//
//  RequestNotificationViewController.m
//  Livi
//
//  Created by Carlos Robinson on 4/26/16.
//  Copyright © 2016 livi. All rights reserved.
//

#import "RequestNotificationViewController.h"
#import <Parse/Parse.h>

@interface RequestNotificationViewController ()

@end

@implementation RequestNotificationViewController

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

-(IBAction)imhere:(id)sender {
    PFQuery *query = [PFUser query];
    [query getObjectWithId:_userId];
    //NSArray *userArray = [query findObjects];
    
    PFQuery *pushQuery = [PFInstallation query];
    //[pushQuery whereKey:@"user" equalTo:userAgain];
    [pushQuery whereKey:@"user" matchesQuery: query];
    
    PFObject *notificationObject = [PFObject objectWithClassName:@"Notifications"];
    notificationObject[@"alert"] = @"Live Stream / Task Acepted";
    notificationObject[@"type"] = @"streaming";
    //for (PFObject *userObj in userArray){
    notificationObject[@"title"] = [PFUser currentUser][@"nickname"];
    //}
    notificationObject[@"from"] = [PFUser currentUser].objectId;
    notificationObject[@"to"] = _userId;
    [notificationObject save];
    
    // Send push notification to query
    NSDictionary *data = @{
                           @"alert" : [NSString stringWithFormat:@"%@ Live Stream / Task Acepted", [PFUser currentUser][@"nickname"]],
                           @"badge" : @"Increment",
                           @"sounds": @"cheering.caf",
                           @"title" : [PFUser currentUser].objectId
                           };
    
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:pushQuery]; // Set our Installation query
    //[push setMessage:@"Live Stream Requested"];
    [push setData:data];
    //[push setChannel:[PFUser currentUser].objectId];
    [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(succeeded){
            NSLog(@"%@", push);
        }else if (error.code == kPFErrorPushMisconfigured) {
            NSLog(@"Could not send push. Push is misconfigured: %@", error.description);
        } else {
            NSLog(@"Error sending push: %@", error.description);
        }
    }];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Stream" bundle:nil];
    UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"streamView"];
    [self presentViewController:viewController animated:YES completion:nil];
}

-(IBAction)sorry:(id)sender {
    PFQuery *query = [PFUser query];
    [query getObjectWithId:_userId];
    NSArray *userArray = [query findObjects];
    
    PFQuery *pushQuery = [PFInstallation query];
    [pushQuery whereKey:@"user" matchesQuery: query];
    
    PFObject *notificationObject = [PFObject objectWithClassName:@"Notifications"];
    notificationObject[@"alert"] = @"Sorry the estblishment you want to see is not available";
    for (PFObject *userObj in userArray){
        notificationObject[@"title"] = userObj[@"nickname"];
    }
    notificationObject[@"type"] = @"streaming";
    notificationObject[@"from"] = [PFUser currentUser].objectId;
    notificationObject[@"to"] = _userId;
    [notificationObject save];
    
    // Send push notification to query
    NSDictionary *data = @{
                           @"alert" : @"Sorry the estblishment you want to see is not available",
                           @"badge" : @"Increment",
                           @"sounds": @"cheering.caf",
                           @"title" : [PFUser currentUser].objectId
                           };
    
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:pushQuery]; // Set our Installation query
    //[push setMessage:@"Live Stream Requested"];
    [push setData:data];
    //[push setChannel:[PFUser currentUser].objectId];
    [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(succeeded){
            NSLog(@"%@", push);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Task / Request"
                                                            message: @"You action was notificated"
                                                           delegate: self
                                                  cancelButtonTitle: @"OK"
                                                  otherButtonTitles: nil];
            [alert show];
        }else if (error.code == kPFErrorPushMisconfigured) {
            NSLog(@"Could not send push. Push is misconfigured: %@", error.description);
        } else {
            NSLog(@"Error sending push: %@", error.description);
        }
    }];
}

-(IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    //[self dismissViewControllerAnimated:YES completion:nil];
}

@end
