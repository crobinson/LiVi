//
//  NotificacionesViewController.h
//  Livi
//
//  Created by Carlos Robinson on 4/22/16.
//  Copyright © 2016 livi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotificacionesViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *myTableView;

@end