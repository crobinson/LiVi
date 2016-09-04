//
//  BasicViewController.m
//  Example
//
//  Created by Jonathan Tribouharet.
//

#import "BasicViewController.h"
#import "ListEventsViewController.h"


@interface BasicViewController (){
    NSMutableDictionary *_eventsByDate;
    NSArray *_eventsSelected;
    NSString *_daySelected;
    
    NSDate *_todayDate;
    NSDate *_minDate;
    NSDate *_maxDate;
    
    NSDate *_dateSelected;
}

@end

@implementation BasicViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(!self){
        return nil;
    }
    
    self.title = @"Basic";
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    _calendarManager = [JTCalendarManager new];
    _calendarManager.delegate = self;
    
    // Generate random events sort by date using a dateformatter for the demonstration
    [self createRandomEvents];
     _calendarManager.settings.weekDayFormat = JTCalendarWeekDayFormatSingle;
    
    // Create a min and max date for limit the calendar, optional
    [self createMinAndMaxDate];
    
    [_calendarManager setMenuView:_calendarMenuView];
    [_calendarManager setContentView:_calendarContentView];
    [_calendarManager setDate:_todayDate];
}

#pragma mark - Buttons callback

- (IBAction)didGoTodayTouch
{
    [_calendarManager setDate:_todayDate];
}

- (IBAction)didChangeModeTouch
{
    _calendarManager.settings.weekModeEnabled = !_calendarManager.settings.weekModeEnabled;
    [_calendarManager reload];
    
    CGFloat newHeight = 300;
    if(_calendarManager.settings.weekModeEnabled){
        newHeight = 85.;
    }
    
    self.calendarContentViewHeight.constant = newHeight;
    [self.view layoutIfNeeded];
}

#pragma mark - CalendarManager delegate

// Exemple of implementation of prepareDayView method
// Used to customize the appearance of dayView
- (void)calendar:(JTCalendarManager *)calendar prepareDayView:(JTCalendarDayView *)dayView
{
    // Today
    if([_calendarManager.dateHelper date:[NSDate date] isTheSameDayThan:dayView.date]){
        dayView.circleView.hidden = NO;
        //dayView.circleView.backgroundColor = [UIColor blueColor];
        dayView.dotView.backgroundColor = [UIColor whiteColor];
        dayView.textLabel.textColor = [UIColor whiteColor];
    }
    // Selected date
    else if(_dateSelected && [_calendarManager.dateHelper date:_dateSelected isTheSameDayThan:dayView.date]){
        dayView.circleView.hidden = NO;
        dayView.circleView.backgroundColor = [UIColor colorWithRed:234.0/255 green:89.0/255 blue:45.0/255 alpha:1];
        dayView.dotView.backgroundColor = [UIColor whiteColor];
        dayView.textLabel.textColor = [UIColor whiteColor];
    }
    // Other month
    else if(![_calendarManager.dateHelper date:_calendarContentView.date isTheSameMonthThan:dayView.date]){
        dayView.circleView.hidden = YES;
        dayView.dotView.backgroundColor = [UIColor colorWithRed:234.0/255 green:89.0/255 blue:45.0/255 alpha:1];
        dayView.textLabel.textColor = [UIColor lightGrayColor];
    }
    // Another day of the current month
    else{
        dayView.circleView.hidden = YES;
        dayView.dotView.backgroundColor = [UIColor colorWithRed:234.0/255 green:89.0/255 blue:45.0/255 alpha:1];
        dayView.textLabel.textColor = [UIColor whiteColor];
    }
    
    if([self haveEventForDay:dayView.date]){
        dayView.dotView.hidden = NO;
    }
    else{
        dayView.dotView.hidden = YES;
    }
}

- (void)calendar:(JTCalendarManager *)calendar didTouchDayView:(JTCalendarDayView *)dayView
{
    _dateSelected = dayView.date;
    
    
    // Animation for the circleView
    dayView.circleView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.1, 0.1);
    [UIView transitionWithView:dayView
                      duration:.3
                       options:0
                    animations:^{
                        dayView.circleView.transform = CGAffineTransformIdentity;
                        [_calendarManager reload];
                    } completion:nil];
    
    
    // Load the previous or next page if touch a day from another month
    
    if(![_calendarManager.dateHelper date:_calendarContentView.date isTheSameMonthThan:dayView.date]){
        if([_calendarContentView.date compare:dayView.date] == NSOrderedAscending){
            [_calendarContentView loadNextPageWithAnimation];
        }
        else if([_calendarContentView.date compare:dayView.date]==NSOrderedDescending){
            [_calendarContentView loadPreviousPageWithAnimation];
        }
    }else{
        //ListEventsViewController *vc = [[ListEventsViewController alloc] initWithNibName:@"ListEventsViewController" bundle:nil];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ListEvents" bundle:nil];
        ListEventsViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ListEvents"];
        if([self haveEventForDay:_dateSelected]){
            NSString *key = [[self dateFormatter] stringFromDate:_dateSelected];
            
            if(_eventsByDate[key] && [_eventsByDate[key] count] > 0){
                NSLog(@"%@", _eventsByDate[key]);
                _eventsSelected = _eventsByDate[key];
                NSDateFormatter *df = [[NSDateFormatter alloc] init];
                [df setDateFormat:@"EEEE MMM d/yy"];
                _daySelected = [df stringFromDate:_dateSelected];
                
                vc.daySelected = _daySelected;
                vc.eventsSelected = _eventsSelected;
                vc.dateSelected = _dateSelected;
            }
        }
        
        [self presentViewController:vc animated:YES completion:nil];
         
    }
}

#pragma mark - CalendarManager delegate - Page mangement

// Used to limit the date for the calendar, optional
- (BOOL)calendar:(JTCalendarManager *)calendar canDisplayPageWithDate:(NSDate *)date
{
    return [_calendarManager.dateHelper date:date isEqualOrAfter:_minDate andEqualOrBefore:_maxDate];
}

- (void)calendarDidLoadNextPage:(JTCalendarManager *)calendar
{
    //    NSLog(@"Next page loaded");
}

- (void)calendarDidLoadPreviousPage:(JTCalendarManager *)calendar
{
    //    NSLog(@"Previous page loaded");
}

#pragma mark - Fake data

- (void)createMinAndMaxDate
{
    _todayDate = [NSDate date];
    
    // Min date will be 2 month before today
    _minDate = [_calendarManager.dateHelper addToDate:_todayDate months:-92];
    
    // Max date will be 2 month after today
    _maxDate = [_calendarManager.dateHelper addToDate:_todayDate months:92];
}

// Used only to have a key for _eventsByDate
- (NSDateFormatter *)dateFormatter
{
    static NSDateFormatter *dateFormatter;
    if(!dateFormatter){
        dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"dd-MM-yyyy";
    }
    
    return dateFormatter;
}

- (BOOL)haveEventForDay:(NSDate *)date
{
    NSString *key = [[self dateFormatter] stringFromDate:date];
    
    if(_eventsByDate[key] && [_eventsByDate[key] count] > 0){
        return YES;
    }
    
    return NO;
    
}

- (void)createRandomEvents
{
    
    _eventsByDate = [NSMutableDictionary new];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"userId = '%@' OR responsable = '%@'", [PFUser currentUser].objectId, [PFUser currentUser].objectId]];
    NSLog(@"%@", [PFUser currentUser].objectId);
    PFQuery *query = [PFQuery queryWithClassName:@"Requests" predicate:predicate];
    NSArray *objects = [query findObjects];
    
    for (PFObject *requestObj in objects){
        if(requestObj[@"date"]){
            NSLog(@"%@", requestObj);
           // NSDate *date = [[self dateFormatter] dateFromString:requestObj[@"date"]];
            NSString *key = [[self dateFormatter] stringFromDate:requestObj[@"date"]];
            
            if(!_eventsByDate[key]){
                _eventsByDate[key] = [NSMutableArray new];
            }
            
            [_eventsByDate[key] addObject:requestObj];
        }
        
    }
    
    

}

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return YES;
}

-(IBAction)back:(id)sender {
    //[self.navigationController popViewControllerAnimated:YES];
    [[SlideNavigationController sharedInstance] leftMenuSelected:self];
}

@end
