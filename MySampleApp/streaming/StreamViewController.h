//
//  StreamViewController.h
//  Livi
//
//  Created by Carlos Robinson on 4/21/16.
//  Copyright © 2016 livi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

@interface StreamViewController : UIViewController

@property (retain, nonatomic) IBOutlet UIView *previewView;
@property (retain, nonatomic) IBOutlet UIButton *btnConnect;

- (IBAction)btnConnectTouch:(id)sender;
- (IBAction)btnFilterTouch:(id)sender;

@end
