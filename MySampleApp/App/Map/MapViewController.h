//
//  MapViewController.h
//  Livi
//
//  Created by Carlos Robinson on 3/31/16.
//  Copyright © 2016 Amazon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "NIDropDown.h"
#import "SlideNavigationController.h"
//@import MapKit;

@interface MapViewController : UIViewController<UITableViewDelegate, UITableViewDataSource,CLLocationManagerDelegate,MKMapViewDelegate, SlideNavigationControllerDelegate, NIDropDownDelegate> {
    NIDropDown *dropDown;
    NSString *tipoSelected;
}
@property (weak, nonatomic) IBOutlet UIView *happeningView;
@property (weak, nonatomic) IBOutlet UIButton *selectButton;
@property (weak, nonatomic) IBOutlet UITableView *menuTableView;
@property (weak, nonatomic) IBOutlet UITableView *happeningTableView;
@property (weak, nonatomic) IBOutlet MKMapView *mvMap;
@property (weak, nonatomic) IBOutlet UIButton *happeningButton;
@property (weak, nonatomic) IBOutlet UIButton *aroundButton;
@property (weak, nonatomic) IBOutlet UIView *searchview;
@property (weak, nonatomic) IBOutlet UIView *aroundYou;
@property (weak, nonatomic) IBOutlet UITableView *aroundTableView;
@property (weak, nonatomic) IBOutlet UIView *selectbox;

@end
