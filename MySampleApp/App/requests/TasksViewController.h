//
//  TasksViewController.h
//  Livi
//
//  Created by Carlos Robinson on 6/10/16.
//  Copyright © 2016 livi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TasksViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *myTableView;


@end
