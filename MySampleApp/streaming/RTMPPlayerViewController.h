//
//  RTMPPlayerViewController.h
//  Livi
//
//  Created by Carlos Robinson on 5/15/16.
//  Copyright © 2016 livi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MNCChatMessageCell.h"
#import <Parse/Parse.h>
#import "BraintreeUI.h"
#import "BraintreePayPal.h"

@interface RTMPPlayerViewController : UIViewController <UITextFieldDelegate,BTDropInViewControllerDelegate, BTAppSwitchDelegate, BTViewControllerPresentingDelegate> {
    IBOutlet UIImageView     *previewView;
    IBOutlet UIView          *loadingView;
    IBOutlet UIView          *subloadingView;
    IBOutlet UIBarButtonItem *btnConnect;
    IBOutlet UIBarButtonItem *btnPlay;
    IBOutlet UILabel         *memoryLabel;
    IBOutlet UITextField     *hostTextField;
    IBOutlet UITextField     *streamTextField;
}
@property (nonatomic, copy) NSString *objectId;
@property (nonatomic, copy) NSString *hostString;
@property (nonatomic, copy) NSString *streamStrig;

//Chat variables
@property (strong, nonatomic) NSString *chatMateId;
@property (strong, nonatomic) NSMutableArray* messageArray;
@property (strong, nonatomic) NSString *myUserId;
@property (strong, nonatomic) UIImage *myUserFoto;
@property (strong, nonatomic) UIImage *chatMateFoto;
@property (strong, nonatomic) NSString *taskId;
@property (strong, nonatomic) NSString *myfotoUrl;
@property (strong, nonatomic) UITextField *activeTextField;
@property (strong, nonatomic) PFObject *chatMessage;
@property (strong, nonatomic) PFObject *notification;

//Pagos variables
@property (nonatomic, strong) BTAPIClient *braintreeClient;
@property (nonatomic, strong) BTPayPalDriver *payPalDriver;

-(IBAction)connectControl:(id)sender;
-(IBAction)playControl:(id)sender;
-(IBAction)chat:(id)sender;

@end
