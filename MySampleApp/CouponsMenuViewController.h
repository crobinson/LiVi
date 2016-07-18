//
//  CouponsMenuViewController.h
//  Livi
//
//  Created by Carlos Robinson on 7/12/16.
//  Copyright © 2016 livi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideNavigationContorllerAnimator.h"
#import "SlideNavigationContorllerAnimatorFade.h"
#import "SlideNavigationContorllerAnimatorSlide.h"
#import "SlideNavigationContorllerAnimatorScale.h"
#import "SlideNavigationContorllerAnimatorScaleAndFade.h"
#import "SlideNavigationContorllerAnimatorSlideAndFade.h"
#import "NIDropDown.h"
#import <CoreLocation/CoreLocation.h>

@interface CouponsMenuViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, NIDropDownDelegate> {
    NSMutableArray *aroundDataSource;
    UIImage *croppedImg;
    NIDropDown *dropDown;
}
@property (weak, nonatomic) IBOutlet UIButton *selectButton;
@property (nonatomic, strong) IBOutlet UITableView *tableView;

@end
