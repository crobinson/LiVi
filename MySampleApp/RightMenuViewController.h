//
//  RightMenuViewController.h
//  SlideMenu
//
//  Created by Aryan Gh on 4/26/14.
//  Copyright (c) 2014 Aryan Ghassemi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideNavigationContorllerAnimator.h"
#import "SlideNavigationContorllerAnimatorFade.h"
#import "SlideNavigationContorllerAnimatorSlide.h"
#import "SlideNavigationContorllerAnimatorScale.h"
#import "SlideNavigationContorllerAnimatorScaleAndFade.h"
#import "SlideNavigationContorllerAnimatorSlideAndFade.h"
#import "NIDropDown.h"

@interface RightMenuViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, NIDropDownDelegate> {
    NSMutableArray *aroundDataSource;
    UIImage *croppedImg;
    NIDropDown *dropDown;
}
@property (weak, nonatomic) IBOutlet UIButton *selectButton;
@property (nonatomic, strong) IBOutlet UITableView *tableView;

@end
