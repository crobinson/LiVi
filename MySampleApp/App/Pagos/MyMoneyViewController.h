//
//  MyMoneyViewController.h
//  Livi
//
//  Created by Carlos Robinson on 7/5/16.
//  Copyright © 2016 livi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideNavigationController.h"

@interface MyMoneyViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *myTableView;

@end
