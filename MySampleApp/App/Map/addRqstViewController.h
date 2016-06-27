//
//  addRqstViewController.h
//  Livi
//
//  Created by Carlos Robinson on 6/9/16.
//  Copyright © 2016 livi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface addRqstViewController : UIViewController<UITextViewDelegate, UIActionSheetDelegate, UIPickerViewDelegate>


@property (weak, nonatomic) IBOutlet UIImageView *taskImageView;
//@property (weak, nonatomic) IBOutlet UITextField *date;
@property (weak, nonatomic) IBOutlet UITextField *time;
@property (weak, nonatomic) IBOutlet UITextField *money;
@property (weak, nonatomic) IBOutlet UITextField *tasktitle;
@property (weak, nonatomic) IBOutlet UITextField *dateTxt;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTxt;
@property (weak, nonatomic) IBOutlet UIView *requestView;
@property (weak, nonatomic) IBOutlet UILabel *tooltip;
@property (weak, nonatomic) IBOutlet UIButton *addPic;
@property (weak, nonatomic) IBOutlet UIButton *close;
@property (weak, nonatomic) IBOutlet UIButton *date;
@property (weak, nonatomic) IBOutlet UIButton *submit;
@property (weak, nonatomic) IBOutlet UIScrollView *myscroll;

@property (weak, nonatomic) UITextView *usrTextView;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (strong, nonatomic) MBProgressHUD *progressHUD;


@end
