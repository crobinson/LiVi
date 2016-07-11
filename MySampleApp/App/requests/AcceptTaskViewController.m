//
//  AcceptTaskViewController.m
//  Livi
//
//  Created by Carlos Robinson on 6/13/16.
//  Copyright © 2016 livi. All rights reserved.
//

#import "AcceptTaskViewController.h"
#import "UIImage+Resize.h"
#import "ChatViewController.h"


@interface AcceptTaskViewController (){
    UIImage *croppedImage;
}

@end

@implementation AcceptTaskViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [Parse setApplicationId:@"BsIBfZnR1xUg1ZY9AwGcd3iKtqrMPu2zUTjP49ta" clientKey:@"E2od7oEslPMj6C2yG9GnWXvC9qDicnTNgcDgN9xm"];
    _acceptButton.layer.masksToBounds = YES;
    [_acceptButton.layer setCornerRadius:6.0f];
    _canceButton.layer.masksToBounds = YES;
    [_canceButton.layer setCornerRadius:6.0f];
    _orangeView.layer.masksToBounds = YES;
    [_orangeView.layer setCornerRadius:10.0f];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"h:mm a"];
    _taskHour.text = [formatter stringFromDate:_obj[@"alert"]];
    
    [formatter setDateFormat:@"EEEE / MMMM d"];
    _taskDate.text = [formatter stringFromDate:_obj[@"alert"]];
    
    _taskTitle.text = _obj[@"title"];
    _taskDescription.text = _obj[@"description"];
    
    PFQuery *query = [PFQuery queryWithClassName:@"TaskImages"];
    NSLog(@"%@", _obj);
    NSString *objId = [NSString stringWithFormat:@"%@", _obj.objectId];
    [query whereKey:@"taskId" equalTo:objId];
    [query orderByDescending:@"createdAt"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (PFObject *imgObject in objects){
                PFFile *image = (PFFile *)[imgObject objectForKey:@"image"];
                UIImage *scaledImage = [[UIImage imageWithData:image.getData] resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:CGSizeMake(78, 78) interpolationQuality:kCGInterpolationHigh];
                // Crop the image to a square (yikes, fancy!)
                croppedImage = [scaledImage croppedImage:CGRectMake((scaledImage.size.width -78)/2, (scaledImage.size.height -78)/2, 78, 78)];
                
            }
            
            if(objects.count<1){
                croppedImage = [UIImage imageNamed:@"avatar.PNG"];
            }
            
            _taskImage.image = croppedImage;
            _taskImage.layer.masksToBounds = YES;
            [_taskImage.layer setCornerRadius:68.0f];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)gotochat:(id)sender {
    [self performSegueWithIdentifier:@"gotoChat" sender:self];
}

-(IBAction)accept:(id)sender {
    PFQuery *query = [PFQuery queryWithClassName:@"Requests"];
    [query whereKey:@"objectId" equalTo:_obj.objectId];
    [query orderByDescending:@"createdAt"];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            object[@"responsable"] = [PFUser currentUser].objectId;
            [object save];
            
            //notification
            
            PFObject *notificationObject = [PFObject objectWithClassName:@"Notifications"];
            notificationObject[@"alert"] = [NSString stringWithFormat:@"Your request %@ was accepted by %@", object[@"title"], [PFUser currentUser][@"nickname"]];
            notificationObject[@"title"] = [PFUser currentUser][@"nickname"];
            notificationObject[@"type"] = @"streaming";
            notificationObject[@"from"] = [PFUser currentUser].objectId;
            notificationObject[@"to"] = object[@"userId"];
            [notificationObject save];
            
            /////
            
            //push
            
            PFQuery *userquery = [PFUser query];
            [userquery getObjectWithId:object[@"userId"]];

            PFQuery *pushQuery = [PFInstallation query];
            [pushQuery whereKey:@"user" matchesQuery: userquery];
            NSDictionary *data = @{
                                   @"alert" : [NSString stringWithFormat:@"Request accepted by by %@", [PFUser currentUser][@"nickname"]],
                                   @"badge" : @"Increment",
                                   @"sounds": @"cheering.caf",
                                   @"title" : [PFUser currentUser].objectId
                                   };
            PFPush *push = [[PFPush alloc] init];
            [push setQuery:pushQuery]; // Set our Installation query
            [push setData:data];
            [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if(succeeded){
                    NSLog(@"%@", push);
                }else if (error.code == kPFErrorPushMisconfigured) {
                    NSLog(@"Could not send push. Push is misconfigured: %@", error.description);
                } else {
                    NSLog(@"Error sending push: %@", error.description);
                }
            }];

            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Task was assigned to you" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            
            [alertView show];
        }
    }];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"gotoChat"]) {
        UIImage *croppedImg = nil;
        PFQuery *query = [PFUser query];
        [query whereKey:@"objectId" equalTo:_obj[@"userId"]];
        PFUser *chatmateUser = [query getFirstObject];
        PFQuery *queryimg = [PFQuery queryWithClassName:@"UserImage"];
        [queryimg whereKey:@"user" equalTo:chatmateUser[@"username"]];
        [queryimg orderByDescending:@"createdAt"];
        NSArray *objects = [queryimg findObjects];
        for (PFObject *imgObject in objects){
            PFFile *image = (PFFile *)[imgObject objectForKey:@"image"];
            UIImage *scaledImage = [[UIImage imageWithData:image.getData] resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:CGSizeMake(75, 55) interpolationQuality:kCGInterpolationHigh];
            croppedImg = [scaledImage croppedImage:CGRectMake((scaledImage.size.width - 75)/2, (scaledImage.size.height - 66)/2, 75, 66)];
        }
        
        if(croppedImg)
            NSLog(@"%@", croppedImg);
        else{
            croppedImg = [UIImage imageNamed:@"avatarm.PNG"];
        }
        
        NSLog(@"%@", croppedImg);
        NSLog(@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"myImage"]);
        
        ChatViewController *ct = segue.destinationViewController;
        ct.myUserId = [PFUser currentUser].objectId;
        //Si entro por este segue es porque le hablaré al creador. Para entrar por Notificaciones
        //debe validarse por la tabla TaskMessage de Parse
        ct.chatMateId = _obj[@"userId"];
        //ct.myUserFoto = [[NSUserDefaults standardUserDefaults] objectForKey:@"myImage"];
        ct.chatMateFoto = croppedImg;
        ct.taskId = _obj.objectId;
    }
}


@end
