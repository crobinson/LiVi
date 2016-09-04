//
//  BasicViewController.h
//  Example
//
//  Created by Jonathan Tribouharet.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <JTCalendar/JTCalendar.h>
#import "SlideNavigationController.h"

@interface BasicViewController : UIViewController<JTCalendarDelegate, SlideNavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet JTCalendarMenuView *calendarMenuView;
@property (weak, nonatomic) IBOutlet JTHorizontalCalendarView *calendarContentView;

@property (strong, nonatomic) JTCalendarManager *calendarManager;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *calendarContentViewHeight;

@end
