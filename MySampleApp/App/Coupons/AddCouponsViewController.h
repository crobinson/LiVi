//
//  AddCouponsViewController.h
//  Livi
//
//  Created by Carlos Robinson on 7/11/16.
//  Copyright © 2016 livi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface AddCouponsViewController : UIViewController<UITextViewDelegate, UIActionSheetDelegate, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *from;
@property (weak, nonatomic) IBOutlet UITextField *to;
@property (weak, nonatomic) IBOutlet UITextField *tasktitle;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTxt;
@property (weak, nonatomic) IBOutlet UIView *requestView;
@property (weak, nonatomic) IBOutlet UILabel *tooltip;
@property (weak, nonatomic) IBOutlet UIButton *addPic;
@property (weak, nonatomic) IBOutlet UIButton *close;
@property (weak, nonatomic) IBOutlet UIButton *submit;
@property (weak, nonatomic) IBOutlet UIScrollView *myscroll;

@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (strong, nonatomic) MBProgressHUD *progressHUD;

@end
