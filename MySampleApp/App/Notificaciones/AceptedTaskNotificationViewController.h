//
//  AceptedTaskNotificationViewController.h
//  Livi
//
//  Created by Carlos Robinson on 4/26/16.
//  Copyright © 2016 livi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AceptedTaskNotificationViewController : UIViewController

@property (weak, nonatomic) NSString *userId;
@property (weak, nonatomic) IBOutlet UIImageView *profilePic;
@property (weak, nonatomic) IBOutlet UILabel *descriptionTxt;
@property (weak, nonatomic) IBOutlet UILabel *nameLbl;

@end
