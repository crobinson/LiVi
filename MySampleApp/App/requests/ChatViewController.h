//
//  ChatViewController.h
//  Livi
//
//  Created by Carlos Robinson on 6/16/16.
//  Copyright © 2016 livi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MNCChatMessageCell.h"
#import <Parse/Parse.h>

@interface ChatViewController : UIViewController<UITableViewDataSource, UITextFieldDelegate>
@property (strong, nonatomic) NSString *chatMateId;     /* add this line */
@property (strong, nonatomic) NSMutableArray* messageArray;
@property (strong, nonatomic) NSString *myUserId;
@property (strong, nonatomic) UIImage *myUserFoto;
@property (strong, nonatomic) UIImage *chatMateFoto;
@property (strong, nonatomic) NSString *taskId;
@property (strong, nonatomic) UITextField *activeTextField;
@property (strong, nonatomic) PFObject *chatMessage;
@property (strong, nonatomic) PFObject *notification;

- (IBAction)sendMessage:(id)sender;
@end
