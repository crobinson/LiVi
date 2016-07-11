//
//  EditProfileViewController.h
//  Livi
//
//  Created by Carlos Robinson on 6/27/16.
//  Copyright © 2016 livi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditProfileViewController : UIViewController<UITextFieldDelegate,UIImagePickerControllerDelegate,UIPickerViewDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) UIImage *croppedImage;
@property (weak, nonatomic) NSString *nameString;
@property (weak, nonatomic) NSString *emailString;
@property (weak, nonatomic) NSString *descString;
@end
