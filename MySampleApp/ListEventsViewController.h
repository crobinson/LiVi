//
//  ListEventsViewController.h
//  Livi
//
//  Created by Carlos Robinson on 6/25/16.
//  Copyright © 2016 livi. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <JTCalendar/JTCalendar.h>

@interface ListEventsViewController : UIViewController<JTCalendarDelegate>

@property (weak, nonatomic) IBOutlet JTCalendarMenuView *calendarMenuView;
@property (weak, nonatomic) IBOutlet JTHorizontalCalendarView *calendarContentView;

@property (strong, nonatomic) JTCalendarManager *calendarManager;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *calendarContentViewHeight;
@property (weak, nonatomic) IBOutlet UILabel *titulo;
@property (weak, nonatomic) NSArray *eventsSelected;
@property (weak, nonatomic) NSString *daySelected;
@property (weak, nonatomic) NSDate *dateSelected;


@end
