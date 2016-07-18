//
//  CouponsMenuViewController.m
//  Livi
//
//  Created by Carlos Robinson on 7/12/16.
//  Copyright © 2016 livi. All rights reserved.
//

#import "CouponsMenuViewController.h"
#import "UIImageView+WebCache.h"
#import <Parse/Parse.h>
#import "UIImage+Resize.h"
#import "VendorProfileViewController.h"



@interface CouponsMenuViewController (){
    CLLocationManager *locationManager;
    CLLocation *location;
}

@end

@implementation CouponsMenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.separatorColor = [UIColor lightGrayColor];
    aroundDataSource    = [[NSMutableArray alloc] init];
    self.selectButton.layer.cornerRadius = 10;
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 &&
        [CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse)
        [locationManager requestWhenInUseAuthorization];
    else
        [locationManager startUpdatingLocation];
    
    
    [self getAroundPV:nil];
    
}

-(void)getAroundPV:(NSString *)vendor {
    
    [aroundDataSource removeAllObjects];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Coupons"];
    float latitudtemp = [[PFUser currentUser][@"latitudTemporal"] floatValue];
    float longitudTemp= [[PFUser currentUser][@"longitudTemporal"] floatValue];
    
    PFGeoPoint *userGeoPoint = [PFGeoPoint geoPointWithLatitude:latitudtemp longitude:longitudTemp];
    [query whereKey:@"couponLocation" nearGeoPoint:userGeoPoint withinKilometers: 100.0];
    
    if(vendor)
        [query whereKey:@"vendor" equalTo:vendor];
    
    [query orderByDescending:@"createdAt"];
    //[query orderByDescending:@"createdAt"];
    NSArray *objects = [query findObjects];
    for (PFObject *userObj in objects){
        
        PFQuery *queryUser = [PFUser query];
        [queryUser whereKey:@"objectId" equalTo:[userObj objectForKey:@"userId"]];
        NSArray *usuario = [queryUser findObjects];
        
        PFFile *image = (PFFile *)[userObj objectForKey:@"image"];
        UIImage *scaledImage = [[UIImage imageWithData:image.getData] resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:CGSizeMake(103, 103) interpolationQuality:kCGInterpolationHigh];
        croppedImg = [scaledImage croppedImage:CGRectMake((scaledImage.size.width -103)/2, (scaledImage.size.height -103)/2, 103, 103)];
        
        NSMutableDictionary *aroundDic=[[NSMutableDictionary alloc] initWithCapacity:3];
        [aroundDic setValue:[usuario objectAtIndex:0] forKey:@"UserData"];
        [aroundDic setValue:croppedImg forKey:@"UserImage"];
        [aroundDataSource addObject:aroundDic];
        
    }
    [self.tableView reloadData];
    
}

#pragma mark - UITableView Delegate & Datasrouce -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return aroundDataSource.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"happen";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    NSMutableDictionary *source = [aroundDataSource[indexPath.row] mutableCopy];
    UIImageView *_miimageView = (UIImageView *)[cell viewWithTag:200];
    UILabel *nombre = (UILabel *)[cell viewWithTag:201];
    UILabel *descripcion = (UILabel *)[cell viewWithTag:202];
    PFUser *sourceUser = source[@"UserData"];
    NSLog(@"%@", sourceUser);
    _miimageView.image = source[@"UserImage"];
    nombre.text = sourceUser[@"businessname"];
    descripcion.text = sourceUser[@"description"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *source = [aroundDataSource[indexPath.row] mutableCopy];
    PFUser *sourceUser = source[@"UserData"];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"VendorProfile" bundle:nil];
    VendorProfileViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"VendorProfile"];
    viewController.currentUser = sourceUser;
    //[self.navigationController pushViewController:viewController                        animated:YES];
    [[SlideNavigationController sharedInstance] pushViewController:viewController
                                                          animated:YES];
    
}

#pragma mark NIDropDown

- (IBAction)selectClicked:(id)sender {
    NSArray * arr = [[NSArray alloc] init];
    arr = [NSArray arrayWithObjects:@"Dining", @"Real State", @"Night Life", @"Online Enterprices", @"Travel", @"Veterans",nil];
    NSArray * arrImage = [[NSArray alloc] init];
    arrImage = [NSArray arrayWithObjects:[UIImage imageNamed:@"apple.png"], [UIImage imageNamed:@"apple2.png"], [UIImage imageNamed:@"apple.png"], [UIImage imageNamed:@"apple2.png"], [UIImage imageNamed:@"apple.png"], [UIImage imageNamed:@"apple2.png"], [UIImage imageNamed:@"apple.png"], [UIImage imageNamed:@"apple2.png"], [UIImage imageNamed:@"apple.png"], [UIImage imageNamed:@"apple2.png"], nil];
    if(dropDown == nil) {
        CGFloat f = 240;
        dropDown = [[NIDropDown alloc]showDropDown:sender :&f :arr :arrImage :@"down"];
        dropDown.delegate = self;
    }
    else {
        [dropDown hideDropDown:sender];
        [self rel];
    }
}

- (void) niDropDownDelegateMethod: (NIDropDown *) sender
{
    [self rel];
}

- (void) whoissender: (UIButton *) sender andtext:(NSString *)titulo
{
    //tipoSelected = titulo;
    [self getAroundPV:titulo];
}

-(void)rel{
    //    [dropDown release];
    dropDown = nil;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    location = [locations lastObject];
    
    
    for (CLLocation *newLocation in locations) {
        if (newLocation.horizontalAccuracy < 30) {
            // Actualizo las latitudes longitudes
            PFUser *currentUser = [PFUser currentUser];
            currentUser[@"latitudTemporal"] = [NSString stringWithFormat:@"%f", location.coordinate.latitude];
            currentUser[@"longitudTemporal"] = [NSString stringWithFormat:@"%f", location.coordinate.longitude];
            [[PFUser currentUser] save];
        }
    }
    
    
    //[self zoomToFitMapAnnotations];
    
}



- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            [locationManager requestWhenInUseAuthorization];
            break;
        case kCLAuthorizationStatusDenied:{
            
            UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"For a better experience we need your location" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [errorAlertView show];
            
        }break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        case kCLAuthorizationStatusAuthorizedAlways:
            
            [locationManager startUpdatingLocation];
            break;
        default:
            break;
    }
}


@end
