//
//  FollowViewController.h
//  Livi
//
//  Created by Carlos Robinson on 6/30/16.
//  Copyright © 2016 livi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FollowViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (weak, nonatomic) IBOutlet UITableView *myTableView2;

@end
