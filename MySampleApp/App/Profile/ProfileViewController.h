//
//  ProfileViewController.h
//  Livi
//
//  Created by Carlos Robinson on 3/31/16.
//  Copyright © 2016 Amazon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileViewController : UIViewController<UITextViewDelegate, UIActionSheetDelegate, UIPickerViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *tooltip;


@end
