//
//  StreamViewController.h
//  Livi
//
//  Created by Carlos Robinson on 4/21/16.
//  Copyright © 2016 livi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "MNCChatMessageCell.h"
#import <Parse/Parse.h>

@interface StreamViewController : UIViewController<UITextFieldDelegate, UIAlertViewDelegate>

@property (retain, nonatomic) IBOutlet UIView *previewView;
@property (retain, nonatomic) IBOutlet UIButton *btnConnect;

//Chat variables
@property (strong, nonatomic) NSString *chatMateId;     /* add this line */
@property (strong, nonatomic) NSMutableArray* messageArray;
@property (strong, nonatomic) NSString *myUserId;
@property (strong, nonatomic) NSString *myfotoUrl;
@property (strong, nonatomic) UIImage *myUserFoto;
@property (strong, nonatomic) UIImage *chatMateFoto;
@property (strong, nonatomic) NSString *taskId;
@property (strong, nonatomic) UITextField *activeTextField;
@property (strong, nonatomic) PFObject *chatMessage;
@property (strong, nonatomic) PFObject *notification;


- (IBAction)btnConnectTouch:(id)sender;
- (IBAction)btnFilterTouch:(id)sender;

@end
