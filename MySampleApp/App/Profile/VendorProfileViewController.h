//
//  VendorProfileViewController.h
//  Livi
//
//  Created by Carlos Robinson on 6/30/16.
//  Copyright © 2016 livi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface VendorProfileViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *tooltip;
@property (weak, nonatomic) PFUser *currentUser;

@end
