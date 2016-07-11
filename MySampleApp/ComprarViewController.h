//
//  ComprarViewController.h
//  Fluie
//
//  Created by Carlos Robinson on 12/12/15.
//  Copyright © 2015 Carlos Robinson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PayPalMobile.h"

@interface ComprarViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, PayPalPaymentDelegate>

@property (strong, nonatomic) NSDictionary *item;

@end
