//
//  MapViewController.m
//  Livi
//
//  Created by Carlos Robinson on 3/31/16.
//  Copyright © 2016 Amazon. All rights reserved.
//

#import "MapViewController.h"
#import "AWSIdentityManager.h"
#import <AWSCognito/AWSCognitoSyncService.h>
#import "AWSConfiguration.h"
#import "AWSTask+CheckExceptions.h"
#import <AWSCore/AWSCore.h>
#import "UIImageView+WebCache.h"
#import <Parse/Parse.h>
#import "UIImage+Resize.h"
#import "MyAnnotation.h"
#import "MyAnnotationView.h"
#import "callOutView.h"
#import "LiviViewController.h"
#import "RTMPPlayerViewController.h"
//#import "ELStreamingViewController.h"
#import "MBProgressHUD.h"
#import "QuartzCore/QuartzCore.h"
#import "addRqstViewController.h"
#import "BasicViewController.h"
#import "VendorProfileViewController.h"
#import "BraintreeUI.h"
#import "BraintreePayPal.h"
#import "ComprarViewController.h"


@interface MapViewController ()
{
    UIImage *croppedImage;
    UIImage *croppedImg;
    CLLocationManager *locationManager;
    CLLocation *location;
    MKPointAnnotation *origen;
    NSMutableArray *dataSource;
    NSMutableArray *aroundDataSource;
    NSArray *pvObjects;
    MyAnnotation *anotationSelected;
    callOutView *calloutview;
    bool bandera;
    BOOL banderamap;
    bool opened;
    MKPointAnnotation *newannot;
    NSMutableArray *filteredCandyArray;
    NSString *amount;
    NSString *_streamStrig;
}

@property(nonatomic, strong) UITableView *table;
@property(nonatomic, strong) UIButton *btnSender;
@property(nonatomic, retain) NSArray *list;
@property(nonatomic, retain) NSArray *imageList;
@property (nonatomic, retain) NSString *animationDirection;
@property (nonatomic, retain) NSString *taskId;

@property (strong, nonatomic) MBProgressHUD *progressHUD;

//Pagos variables
@property (nonatomic, strong) BTAPIClient *braintreeClient;
@property (nonatomic, strong) BTPayPalDriver *payPalDriver;

@end

@implementation MapViewController
@synthesize table;
@synthesize btnSender;
@synthesize list;
@synthesize imageList;
@synthesize animationDirection;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //[Parse setApplicationId:@"BsIBfZnR1xUg1ZY9AwGcd3iKtqrMPu2zUTjP49ta" clientKey:@"E2od7oEslPMj6C2yG9GnWXvC9qDicnTNgcDgN9xm"];

    _searchview.layer.masksToBounds = YES;
    [_searchview.layer setCornerRadius:3.0f];
    [_searchview.layer setBorderColor:[UIColor colorWithRed:54.0/255 green:121.0/255 blue:189.0/255 alpha:1].CGColor];
    [_searchview.layer setBorderWidth:2.5f];
    [_searchview.layer setShadowColor:[UIColor blackColor].CGColor];
    [_searchview.layer setShadowOpacity:0.8];
    [_searchview.layer setShadowRadius:3.0];
    [_searchview.layer setShadowOffset:CGSizeMake(2.0, 2.0)];

    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 0.5; //user needs to press for 2 seconds
    [self.mvMap addGestureRecognizer:lpgr];
    
    
    //Inicio los datasources
    
    dataSource          = [[NSMutableArray alloc] init];
    
    
    //Inicio el select de vendors
    NSArray * arr = [[NSArray alloc] init];
    arr = [NSArray arrayWithObjects:@"Dining", @"Real State", @"Night Life", @"Online Enterprices", @"Travel", @"Veterans",nil];
    
    animationDirection = @"down";
    self.table = (UITableView *)[super init];
    CGRect btn = _selectButton.frame;
    self.list = [NSArray arrayWithArray:arr];
    _selectbox.frame                = CGRectMake(btn.origin.x, btn.origin.y+btn.size.height, btn.size.width, 0);
    _selectbox.layer.shadowOffset   = CGSizeMake(-5, 5);
    _selectbox.layer.masksToBounds  = NO;
    _selectbox.layer.cornerRadius   = 8;
    _selectbox.layer.shadowRadius   = 10;
    _selectbox.layer.shadowOpacity  = 0.5;
    
    table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, btn.size.width, 0)];
    table.delegate = self;
    table.dataSource = self;
    table.layer.cornerRadius = 10;
    table.backgroundColor = [UIColor colorWithRed:0.239 green:0.239 blue:0.239 alpha:1];
    table.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    table.separatorColor = [UIColor whiteColor];
    //_selectbox.hidden = NO;
    table.delegate = self;
    
    [_selectbox addSubview:table];

    
    _mvMap.delegate = self;
    //_mvMap.showsUserLocation = YES;
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 &&
        [CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse)
        [locationManager requestWhenInUseAuthorization];
    else
        [locationManager startUpdatingLocation];
    
    
    
}

- (void) hideProgressHUD
{
    if (_progressHUD)
    {
        [_progressHUD hide:YES];
        [_progressHUD removeFromSuperview];
        _progressHUD = nil;
    }
}


- (void)viewDidAppear:(BOOL)animated{
    banderamap = FALSE;
    [self presentProfileViewController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)presentProfileViewController {
    if ([AWSIdentityManager sharedInstance].isLoggedIn) {
        AWSCognito *syncClient = [AWSCognito defaultCognito];
        AWSCognitoDataset *userSettings = [syncClient openOrCreateDataset:@"user_settings"];
        
        if(![userSettings stringForKey:@"Description"] || [[userSettings stringForKey:@"Description"] isEqualToString:@""]){
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Profile" bundle:nil];
            UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"Profile"];
            [self presentViewController:viewController
                               animated:YES
                             completion:nil];
        }

        
    }else{
        if([PFUser currentUser])
            [[PFUser currentUser] fetch]; //synchronous
        
        PFUser *currentUser = [PFUser currentUser];
        if (currentUser) {
            
            NSLog(@"%@", currentUser[@"authorized"]);
            if([currentUser[@"authorized"] isEqualToString:@"SI" ] || !currentUser[@"vendor"] || [currentUser[@"vendor"] isEqualToString:@"NO"]){
                [self getDataSource];
            }else{
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MoneyStoryboard" bundle:nil];
                UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"comprar"];
                [self presentViewController:viewController
                                   animated:YES
                                 completion:nil];
            }
            
            [self getUserImage];
            NSLog(@"%@", currentUser[@"description"]);
            
            if(!currentUser[@"description"] || [currentUser[@"description"] isEqualToString:@""]){
                NSLog(@"%@", currentUser[@"description"]);
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Profile" bundle:nil];
                UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"ProfileCustom"];
                [self presentViewController:viewController
                                   animated:YES
                                 completion:nil];
            }
            
            //[self getPV];
            
        } else {
            // show the signup or login screen
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SignIn" bundle:nil];
            UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"SignIn"];
            [self presentViewController:viewController
                               animated:YES
                             completion:nil];
        }
        
        

    }
    
}



-(void)getPV {
    bandera = YES; // Para no seguirlos llamando cuando no sea necesario
    PFQuery *query = [PFUser query];
    [query whereKeyExists:@"vendor"];
    [query whereKey:@"vendor" notEqualTo:@"NO"];
    [query orderByDescending:@"createdAt"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            
            NSMutableArray *datasourcetemporal = [NSMutableArray arrayWithObjects:nil];
            //Everything was correct, put the new objects and load the wall
            for (PFObject *userObj in objects){
                NSLog(@"%@", userObj);
                
                
                PFQuery *queryimg = [PFQuery queryWithClassName:@"UserImage"];
                [queryimg whereKey:@"user" equalTo:userObj[@"username"]];
                [queryimg orderByDescending:@"createdAt"];
                
                NSArray *objects = [queryimg findObjects];
                NSString *myimage = nil;
                for (PFObject *imgObject in objects){
                    PFFile *image = (PFFile *)[imgObject objectForKey:@"image"];
                    NSLog(@"%@", image.url);
                    myimage = image.url;
                    /*UIImage *scaledImage = [[UIImage imageWithData:image.getData] resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:CGSizeMake(103, 103) interpolationQuality:kCGInterpolationHigh];
                    croppedImg = [scaledImage croppedImage:CGRectMake((scaledImage.size.width -103)/2, (scaledImage.size.height -103)/2, 103, 103)];*/
                }
                
                PFGeoPoint *geopoint = (PFGeoPoint *)[userObj objectForKey:@"location"];
                CLLocationCoordinate2D coordinate;
                coordinate.latitude = geopoint.latitude;
                coordinate.longitude = geopoint.longitude;
                //destino.coordinate = coordinate;
                MyAnnotation *destino = [[MyAnnotation alloc]
                                         initWithTitle:userObj[@"username"]
                                         andSubtitle:userObj[@"description"]
                                         andImage:myimage
                                         andUrlIos:userObj.objectId
                                         andUrlOther:userObj[@"nickname"]
                                         andUrlStream:userObj[@"urlStream"]
                                         andCoordinate:coordinate
                                         andPV:userObj[@"vendor"]];
            
                NSDictionary *datoTemporal=@{
                                             @"nickname" : userObj[@"nickname"],
                                             @"latitude" : [NSString stringWithFormat:@"%f", coordinate.latitude],
                                             @"longitude" : [NSString stringWithFormat:@"%f", coordinate.longitude],
                                             };
                [datasourcetemporal addObject:datoTemporal];
                
                [_mvMap addAnnotation:destino];
            }
            pvObjects = datasourcetemporal;
            [self hideProgressHUD];
        }else {
            [self hideProgressHUD];
           
        }
    }];
    
}

- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer
{
    NSLog(@"entro");
    
    //[self performSegueWithIdentifier:@"addpopover" sender:self];
    
    /*CGPoint touchPoint = [gestureRecognizer locationInView:_mvMap];
    CLLocationCoordinate2D touchMapCoordinate =
    [self.mvMap convertPoint:touchPoint toCoordinateFromView:self.mvMap];
    
    MKPointAnnotation *annot = [[MKPointAnnotation alloc] init];
    annot.coordinate = touchMapCoordinate;
    newannot = [[MKPointAnnotation alloc] init];
    newannot = annot;
    //[self.mvMap addAnnotation:annot];
    
    [self performSegueWithIdentifier:@"addpopover" sender:self];*/
    
    /*addrequestViewController *ctl = [[addrequestViewController alloc] initWithAnnot:annot.coordinate.latitude andLong:annot.coordinate.latitude];
    */
    
    /*pOver = [[UIPopoverController alloc] initWithContentViewController:ctl];
     pOver.popoverContentSize = CGSizeMake(251, 204);
     [pOver presentPopoverFromRect:_btnStatus.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];*/
    //ctl.preferredContentSize = CGSizeMake(251, 204);
    //ctl.modalPresentationStyle = UIModalPresentationPopover;
    //ctl.popoverPresentationController.sourceView = _btnStatus;
    //[self presentViewController:ctl animated:YES completion:nil];
}


-(void)getDataSource {
    if (_progressHUD == nil)
    {
        _progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    
    [dataSource removeAllObjects];
    [_happeningTableView reloadData];
    PFQuery *query = [PFUser query];
    [query whereKeyExists:@"urlStreamIos"];
    [query whereKey:@"urlStreamIos" notEqualTo:@""];
    //[query orderByDescending:@"createdAt"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            //Everything was correct, put the new objects and load the wall
            for (PFObject *userObj in objects){
                //Traigo la imagen
                PFQuery *queryimg = [PFQuery queryWithClassName:@"UserImage"];
                [queryimg whereKey:@"user" equalTo:userObj[@"username"]];
                [queryimg orderByDescending:@"createdAt"];
                NSArray *userImage = [queryimg findObjects];
                NSString *myimage = nil;
                for (PFObject *imgObject in userImage){
                    PFFile *image = (PFFile *)[imgObject objectForKey:@"image"];
                    myimage = image.url;
                    /*UIImage *scaledImage = [[UIImage imageWithData:image.getData] resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:CGSizeMake(103, 103) interpolationQuality:kCGInterpolationHigh];
                    croppedImg = [scaledImage croppedImage:CGRectMake((scaledImage.size.width -103)/2, (scaledImage.size.height -103)/2, 103, 103)];*/
                }
                
                
                NSMutableDictionary *happening = [[NSMutableDictionary alloc] initWithDictionary: @{
                                                                                                   @"UserData" : userObj,
                                                                                                   @"objectId" : userObj.objectId,
                                                                                                   @"Likes" : @"",
                                                                                                   }];
                if(myimage)
                    happening = [[NSMutableDictionary alloc] initWithDictionary: @{
                                                                                                        @"UserData" : userObj,
                                                                                                        @"objectId" : userObj.objectId,
                                                                                                        @"UserImage" : myimage,
                                                                                                        @"Likes" : @"",
                                                                                                        }];
                
                
                
                
                [dataSource addObject:happening];
            }
            
            [_happeningTableView reloadData];
        }else {
            if(error.code==kPFErrorInvalidSessionToken){
                
                NSString *errorString = [NSString stringWithFormat:@"Session is no longer valid, please log in again."
                                         ];
                UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Invalid Session" message:errorString delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [errorAlertView show];
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SignIn" bundle:nil];
                UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"SignIn"];
                [self presentViewController:viewController
                                   animated:YES
                                 completion:nil];
            
            }else{
                NSString *errorString = [[error userInfo] objectForKey:@"error"];
                UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [errorAlertView show];
            }
            
            
        }
        //[self getAroundPV:nil];
        if(!bandera)
            [self getPV];
        else
            [self hideProgressHUD];
    }];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {

    static NSString *identifier = @"MyAnnotation";
    MyAnnotationView * pinView = (MyAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    MyAnnotation *anot = annotation;
    // If it's the user location, just return nil.
    if([anot.title isEqualToString:@"Me"] || [anot.title isEqualToString:@"Current Location"])
        return pinView;
    
    if (!pinView)
    {
        // If an existing pin view was not available, create one.
       pinView = [[MyAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        NSLog(@"%@", anot.title);
        
        
        if([anot.pv isEqualToString:@"Online Enterprices"]){
            pinView.image = [UIImage imageNamed:@"pinrojo.png"];
        }else if([anot.pv isEqualToString:@"Night Live"]){
            pinView.image = [UIImage imageNamed:@"pinazul.png"];
        }else if([anot.pv isEqualToString:@"Dinning"]){
            pinView.image = [UIImage imageNamed:@"pinverde.png"];
        }else{
            pinView.image = [UIImage imageNamed:@"pinvioleta.png"];
        }
        
        pinView.calloutOffset = CGPointMake(0, 32);
        
        
    } else {
        pinView.annotation = annotation;
    }

    
    return pinView;
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    if(calloutview){
        [calloutview removeFromSuperview];
    }
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    
    
    
    calloutview = (callOutView *)[view viewWithTag:999];
    CGRect viewframe = _mvMap.frame;
    viewframe.origin = CGPointMake(0, 0);
    _mvMap.frame = viewframe;
    
    if(!calloutview){
        
        calloutview = (callOutView *)[[[NSBundle mainBundle] loadNibNamed:@"callOutView" owner:self options:nil] objectAtIndex:0];
        MyAnnotation *anot = (MyAnnotation *)view.annotation;
        anotationSelected = (MyAnnotation *)view.annotation;
        UILabel *titulo = (UILabel *)[calloutview viewWithTag:101];
        titulo.text = anot.urlStream;

        UIImageView *vpImgView = (UIImageView *)[calloutview viewWithTag:100];
        if (vpImgView.image != nil && vpImgView.image != nil)
            [vpImgView sd_setImageWithURL:[NSURL URLWithString:anot.proImage] placeholderImage:[UIImage imageNamed:@"avatar.PNG"]];
        
        vpImgView.layer.masksToBounds = YES;
        [vpImgView.layer setCornerRadius:51.0f];
        
        UIButton *viewRequest = (UIButton *)[calloutview viewWithTag:102];
        //viewRequest.hidden = YES;
        UIButton *addRequest = (UIButton *)[calloutview viewWithTag:103];
        UIButton *viewProfile = (UIButton *)[calloutview viewWithTag:104];
        viewProfile.accessibilityValue = anot.urlStreamIos;
        [viewRequest addTarget:self action:@selector(viewAction:) forControlEvents:UIControlEventTouchUpInside];
        [addRequest addTarget:self action:@selector(requestAction:) forControlEvents:UIControlEventTouchUpInside];
        [viewProfile addTarget:self action:@selector(viewProfileAction:) forControlEvents:UIControlEventTouchUpInside];
        
        if(anot.rtmpStream && ![anot.rtmpStream isEqualToString:@""]){
            viewRequest.hidden = NO;
            addRequest.hidden = YES;
        }else{
            addRequest.hidden = NO;
            viewRequest.hidden = YES;
        }

        calloutview.tag = 999;
        
        
        CGRect calloutViewFrame = calloutview.frame;
        calloutViewFrame.origin = CGPointMake(-calloutViewFrame.size.width/2 + 15, -calloutViewFrame.size.height);
        calloutview.frame = calloutViewFrame;
        
        calloutview.frame = CGRectMake(-150, -100, 257, 264);
        [view addSubview:calloutview];
    }else{
        [calloutview removeFromSuperview];
    }
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    
    CGPoint annotationCenter=CGPointMake(control.frame.origin.x+(control.frame.size.width/2),control.frame.origin.y+(control.frame.size.height/2));
    
    CLLocationCoordinate2D newCenter=[mapView convertPoint:annotationCenter toCoordinateFromView:control.superview];
    [mapView setCenterCoordinate:newCenter animated:YES];
    
}

-(void)DeleteButtonTapped:(id)sender{
    NSLog(@"Delete Button Tapped");
}


-(IBAction)showhapening:(id)sender
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.50];
    [UIView setAnimationDelegate:self];
    
    if(_happeningView.frame.origin.y != 111){
        _happeningView.frame = CGRectMake(0, 111, _happeningView.frame.size.width, self.view.frame.size.height - 111);
    }else{
        _happeningView.frame = CGRectMake(0, self.view.frame.size.height - 82, _happeningView.frame.size.width, _happeningView.frame.size.height);
    }
    [UIView commitAnimations];
}

-(IBAction)showaround:(id)sender
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.50];
    [UIView setAnimationDelegate:self];
    
    if(_aroundYou.frame.origin.x == self.view.frame.size.width - _aroundYou.frame.size.width){
        _aroundYou.frame = CGRectMake(self.view.frame.size.width - _aroundButton.frame.size.width+5, 0, _aroundYou.frame.size.width, _aroundYou.frame.size.height);
        
    }else{
        _aroundYou.frame = CGRectMake(self.view.frame.size.width - _aroundYou.frame.size.width, 0, _aroundYou.frame.size.width, _aroundYou.frame.size.height);
        
    }
    [UIView commitAnimations];
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //return dataSource.count;
    
    if(tableView==_happeningTableView)
        return dataSource.count;
    
    if (tableView==_aroundTableView){
        NSLog(@"%i", aroundDataSource.count);
        return aroundDataSource.count;
    }
    
    return 9;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if(tableView==_happeningTableView || tableView==_aroundTableView)
        return 111;
    
    if(indexPath.row==0 && tableView==_menuTableView){
        return 138;
    }
    
    if(tableView == table){
        return 40;
    }
    
    
    
    return 69;
    
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //tableView = _mytableview;
    static NSString *CellIdentifier = @"menu";
    NSLog(@"%ld",(long)indexPath.row);
    
    if(tableView==_happeningTableView || tableView==_aroundTableView){
            CellIdentifier = @"happen";
    }
    if(tableView==table)
        CellIdentifier = @"Cell";
    
        
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  
    
    if ( cell == nil ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        if(tableView==table){
            cell.backgroundColor = [UIColor colorWithRed:54.0/255 green:121.0/255 blue:189.0/255 alpha:1];
            cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:17.0f];
            cell.textLabel.font = [UIFont systemFontOfSize:20];
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.textLabel.textAlignment = UITextAlignmentCenter;
        }
    }
    
    // Configure the cell...
    
    
    if(tableView==_happeningTableView){
        // Configure the _happeningTableView cell...
        NSMutableDictionary *source = [dataSource[indexPath.row] mutableCopy];
        UIImageView *_miimageView = (UIImageView *)[cell viewWithTag:200];
        UILabel *nombre = (UILabel *)[cell viewWithTag:201];
        UILabel *descripcion = (UILabel *)[cell viewWithTag:202];
        PFUser *sourceUser = source[@"UserData"];
        NSLog(@"%@", sourceUser);
        //_miimageView.image = source[@"UserImage"];
        [_miimageView sd_setImageWithURL:[NSURL URLWithString:source[@"UserImage"]] placeholderImage:[UIImage imageNamed:@"avatar.PNG"]];
        nombre.text = sourceUser[@"businessname"];
        descripcion.text = sourceUser[@"description"];
        return cell;
    }else if(tableView==table){
        cell.textLabel.text =[list objectAtIndex:indexPath.row];
    }else if(tableView==_aroundTableView){
        NSMutableDictionary *source = [aroundDataSource[indexPath.row] mutableCopy];
        UIImageView *_miimageView = (UIImageView *)[cell viewWithTag:200];
        UILabel *nombre = (UILabel *)[cell viewWithTag:201];
        UILabel *descripcion = (UILabel *)[cell viewWithTag:202];
        PFUser *sourceUser = source[@"UserData"];
        NSLog(@"%@", sourceUser);
        [_miimageView sd_setImageWithURL:[NSURL URLWithString:source[@"UserImage"]] placeholderImage:[UIImage imageNamed:@"avatar.PNG"]];
        nombre.text = sourceUser[@"businessname"];
        descripcion.text = sourceUser[@"description"];
        return cell;

    }
    

    
    return cell;
}

-(IBAction)viewProfileAction:(id)sender {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"VendorProfile" bundle:nil];
    VendorProfileViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"VendorProfile"];
    viewController.userId = anotationSelected.title;
    [self.navigationController pushViewController:viewController
                                         animated:YES];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    _menuTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _menuTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    if(tableView==_aroundTableView){
        //Alguna
        NSMutableDictionary *source = [aroundDataSource[indexPath.row] mutableCopy];
        PFUser *sourceUser = source[@"UserData"];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"VendorProfile" bundle:nil];
        VendorProfileViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"VendorProfile"];
        viewController.currentUser = sourceUser;
        [self.navigationController pushViewController:viewController
                                             animated:YES];
    }else if(tableView==table){
        UITableViewCell *c = [tableView cellForRowAtIndexPath:indexPath];
        NSString *str = [NSString stringWithFormat:@"%@", c.textLabel.text];
        [_selectButton setTitle:str forState:UIControlStateNormal];
        //[self getAroundPV:c.textLabel.text];
    }
}

-(void)viewAction:(UIButton *)sender{
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Livi" bundle:nil];
    
    // EN ESTE PUNTO YA HAY UN REQUEST EN PROCESO
    
    //LiviViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"liviView"];
    RTMPPlayerViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"playerView"];
    //viewController.urlString = [NSString stringWithFormat:@"http://54.164.51.55:1935/live/%@/playlist.m3u8", anotationSelected.urlStreamIos];
    viewController.hostString = @"rtmp://54.164.51.55:1935/live/";
    viewController.streamStrig = anotationSelected.urlStreamIos;
    viewController.objectId = anotationSelected.urlStreamIos;
    [self.navigationController pushViewController:viewController
                                         animated:YES];
    /*ELStreamingViewController *streamingViewController = [[ELStreamingViewController alloc] init];
    //rtsp://54.164.51.55:1935/live/EUtpQYOshi
    NSString *urlString = [NSString stringWithFormat:@"rtmp://54.164.51.55:1935/live/%@", anotationSelected.urlStreamIos];
    streamingViewController.videoUrl = urlString;
    [self.navigationController pushViewController:streamingViewController
                                         animated:YES];*/
    
    //[self presentModalViewController: streamingViewController animated: YES];
}

-(void)requestAction:(UIButton *)sender{
    PFObject *requestObject = [PFObject objectWithClassName:@"Requests"];
    
    PFQuery *query = [PFUser query];
    [query whereKey:@"username" equalTo:anotationSelected.title];
    [query orderByDescending:@"createdAt"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            //Everything was correct, put the new objects and load the wall
            for (PFObject *userObj in objects){
                NSLog(@"%@", userObj);
                requestObject[@"pv"] = userObj;
                requestObject[@"responsable"] = userObj;
                requestObject[@"location"] = userObj[@"location"];
                requestObject[@"creator"] = [PFUser currentUser];
                [requestObject setObject:[PFUser currentUser].objectId forKey:@"userId"];
                [requestObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded){
                        // Create our Installation query
                        
                        UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Requested Sent" message:@"Live Stream Requested" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                        [errorAlertView show];

                        PFObject *notificationObject = [PFObject objectWithClassName:@"Notifications"];
                        notificationObject[@"alert"] = @"Live Stream Request";
                        notificationObject[@"type"] = @"streaming";
                        notificationObject[@"title"] = [PFUser currentUser][@"nickname"];
                        notificationObject[@"from"] = [PFUser currentUser].objectId;
                        notificationObject[@"to"] = anotationSelected.urlStreamIos;
                        [notificationObject saveInBackground];
                        
                        PFQuery *userquery = [PFUser query];
                        [userquery getObjectWithId:anotationSelected.urlStreamIos];
                        
                        PFQuery *pushQuery = [PFInstallation query];
                        //[pushQuery whereKey:@"user" equalTo:userAgain];
                        [pushQuery whereKey:@"user" matchesQuery: userquery];
                        
                        // Send push notification to query
                        NSDictionary *data = @{
                                               @"alert" : [NSString stringWithFormat:@"Live Stream Requested by %@", [PFUser currentUser][@"nickname"]],
                                               @"badge" : @"Increment",
                                               @"sounds": @"cheering.caf",
                                               @"title" : [PFUser currentUser].objectId
                                               };
                        
                        PFPush *push = [[PFPush alloc] init];
                        [push setQuery:pushQuery]; // Set our Installation query
                        //[push setMessage:@"Live Stream Requested"];
                        [push setData:data];
                        //[push setChannel:[PFUser currentUser].objectId];
                        [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            if(succeeded){
                                NSLog(@"%@", push);
                                /*PFObject *pushObject = [PFObject objectWithClassName:@"PushRequest"];
                                requestObject[@"push"] = push;
                                requestObject[@"pusherId"] = [PFUser currentUser];*/
                            }else if (error.code == kPFErrorPushMisconfigured) {
                                NSLog(@"Could not send push. Push is misconfigured: %@", error.description);
                            } else {
                                NSLog(@"Error sending push: %@", error.description);
                            }
                        }];
                        
                        
                        
                    }else{
                        NSString *errorString = [[error userInfo] objectForKey:@"error"];
                        UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Alert" message:errorString delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                        [errorAlertView show];
                    }
                }];
            }
        }
    }];
    
}


-(void)getUserImage
{
    //Prepare the query to get all the images in descending order
    PFQuery *query = [PFQuery queryWithClassName:@"UserImage"];
    PFUser *currentUser = [PFUser currentUser];
    
    //Verifico pago pendiente
    
    if(currentUser[@"pendingPayment"])
        if(![currentUser[@"pendingPayment"] isEqualToString:@""]){
            self.taskId = currentUser[@"pendingPayment"];
            [self cobropaypal];
        }
    
    [query whereKey:@"user" equalTo:currentUser.username];
    [query orderByDescending:@"createdAt"];
    query.limit = 1; // limit to at most 10 results
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            //Everything was correct, put the new objects and load the wall
            for (PFObject *imgObject in objects){
                PFFile *image = (PFFile *)[imgObject objectForKey:@"image"];
                
                [[NSUserDefaults standardUserDefaults] setObject:image.url forKey:@"myImageUrl"];
                
                //UIImageView *userImage = [[UIImageView alloc] initWithImage:[UIImage imageWithData:image.getData]];
                //NSLog(@"%@", image.getData);
                UIImage *scaledImage = [[UIImage imageWithData:image.getData] resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:CGSizeMake(78, 78) interpolationQuality:kCGInterpolationHigh];
                // Crop the image to a square (yikes, fancy!)
                croppedImage = [scaledImage croppedImage:CGRectMake((scaledImage.size.width -78)/2, (scaledImage.size.height -78)/2, 78, 78)];
                
            }
            
            if(objects.count<1){
                croppedImage = [UIImage imageNamed:@"avatar.PNG"];
            }
            
            
            [[NSUserDefaults standardUserDefaults] setObject:UIImagePNGRepresentation(croppedImage) forKey:@"myImage"];
            
            [_menuTableView reloadData];
        } else {
            /*NSString *errorString = [[error userInfo] objectForKey:@"error"];
            UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [errorAlertView show];*/
        }
    }];
    
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"addpopover"]) {
        NSLog(@"addpopover");
        NSLog(@"%f", newannot.coordinate.latitude);
        NSLog(@"%f", newannot.coordinate.longitude);
        addRqstViewController *ct = segue.destinationViewController;
        ct.latitude = newannot.coordinate.latitude;
        ct.longitude = newannot.coordinate.longitude;
    }
    //newannot
}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    location = [locations lastObject];
    
    if(origen == nil) {
        origen = [[MKPointAnnotation alloc] init];
        origen.title = @"Me";
        [_mvMap addAnnotation:origen];
    }
    
    _mvMap.showsUserLocation = YES;
    
    location = [locations lastObject];
    MKCoordinateSpan span;
    span.latitudeDelta = .111;
    span.longitudeDelta = .111;
    //the .001 here represents the actual height and width delta
    MKCoordinateRegion region;
    region.center = location.coordinate;
    region.span = span;
    if(!banderamap){
        PFUser *currentUser = [PFUser currentUser];
        currentUser[@"latitudTemporal"] = [NSString stringWithFormat:@"%f", location.coordinate.latitude];
        currentUser[@"longitudTemporal"] = [NSString stringWithFormat:@"%f", location.coordinate.longitude];
        
        
        PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
        if([currentUser[@"vendor"] isEqualToString:@"NO"]){
            currentUser[@"location"] = point;
        }
        [[PFUser currentUser] saveInBackground];
        [_mvMap setRegion:region animated:TRUE];
    }
    banderamap = TRUE;
    
    if(origen == nil) {
        origen = [[MKPointAnnotation alloc] init];
        origen.title = @"Me";
        [_mvMap addAnnotation:origen];
    }
    
    _mvMap.showsUserLocation = YES;
    
    
    for (CLLocation *newLocation in locations) {
        if (newLocation.horizontalAccuracy < 30) {
            // Actualizo las latitudes longitudes
            PFUser *currentUser = [PFUser currentUser];
            currentUser[@"latitudTemporal"] = [NSString stringWithFormat:@"%f", location.coordinate.latitude];
            currentUser[@"longitudTemporal"] = [NSString stringWithFormat:@"%f", location.coordinate.longitude];
            PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
            if([currentUser[@"vendor"] isEqualToString:@"NO"]){
                currentUser[@"location"] = point;
            }
            [[PFUser currentUser] saveInBackground];
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


#pragma mark UITextField

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    //Cierro todos los menúes en caso de algúno de ellos estar abierto
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.50];
    [UIView setAnimationDelegate:self];
    _aroundYou.frame = CGRectMake(self.view.frame.size.width - 272, 0, _aroundYou.frame.size.width, _aroundYou.frame.size.height);
    _menuTableView.frame = CGRectMake(0 - _menuTableView.frame.size.width, _menuTableView.frame.origin.y, _menuTableView.frame.size.width, _menuTableView.frame.size.height);
    _happeningView.frame = CGRectMake(0, 111, _happeningView.frame.size.width, self.view.frame.size.height - 111);
    [UIView commitAnimations];
    
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    /* if (textField == _Username_TextField) {
     [_Username_TextField resignFirstResponder];
     [_password_TextField becomeFirstResponder];
     } else if (textField == _password_TextField) {*/
    
    //Buscamos un pv con ese nickname
    NSLog(@"%@", pvObjects);
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"nickname CONTAINS[c] %@", textField.text ];
    
    filteredCandyArray = [NSMutableArray arrayWithArray:[pvObjects filteredArrayUsingPredicate:predicate]];
    NSLog(@"filteredCandyArray %@", filteredCandyArray);
    
    if(filteredCandyArray.count){
        MKCoordinateRegion region = [_mvMap regionThatFits:MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake([[filteredCandyArray objectAtIndex:0][@"latitude"] floatValue], [[filteredCandyArray objectAtIndex:0][@"longitude"] floatValue]), 200, 200)];
        [_mvMap setRegion:region animated:YES];
    }
    
    [textField resignFirstResponder];
    // }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
}

#pragma mark NIDropDown

- (IBAction)selectClicked:(id)sender {
    CGRect btn = _selectButton.frame;
    
    if(!opened){
        _selectbox.frame = CGRectMake(btn.origin.x, btn.origin.y+btn.size.height, btn.size.width, 240);
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        //
        table.frame = CGRectMake(0, 0, btn.size.width, 240);
        [UIView commitAnimations];
    }else{
        _selectbox.frame = CGRectMake(btn.origin.x, btn.origin.y+btn.size.height, btn.size.width, 0);
        //_selectbox.hidden = YES;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        //
        table.frame = CGRectMake(0, 0, btn.size.width, 0);
        [UIView commitAnimations];
    }
    opened = !opened;
    
}

- (void) niDropDownDelegateMethod: (NIDropDown *) sender
{
    [self rel];
}

- (void) whoissender: (UIButton *) sender andtext:(NSString *)titulo
{
    tipoSelected = titulo;
}

-(void)rel{
    //    [dropDown release];
    dropDown = nil;
}

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return YES;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu
{
    return YES;
}

- (IBAction)onBtnMenu:(id)sender {
    [[SlideNavigationController sharedInstance] leftMenuSelected:self];
    //[[SlideNavigationController sharedInstance] toggleLeftMenu];
}

- (IBAction)onRightBtnMenu:(id)sender {
    [[SlideNavigationController sharedInstance] righttMenuSelected:self];
}


- (IBAction)tappedMyPayButton {
    
    BTDropInViewController *dropInViewController = [[BTDropInViewController alloc]
                                                    initWithAPIClient:self.braintreeClient];
    dropInViewController.delegate = self;
    
    /*UIBarButtonItem *item = [[UIBarButtonItem alloc]
     initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
     target:self
     action:@selector(userDidCancelPayment)];
     dropInViewController.navigationItem.leftBarButtonItem = item;*/
    UINavigationController *navigationController = [[UINavigationController alloc]
                                                    initWithRootViewController:dropInViewController];
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)userDidCancelPayment {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// Implement BTDropInViewControllerDelegate ...

- (void)dropInViewController:(BTDropInViewController *)viewController
  didSucceedWithTokenization:(BTPaymentMethodNonce *)paymentMethodNonce {
    // Send payment method nonce to your server for processing
    [self postNonceToServer:paymentMethodNonce.nonce];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dropInViewControllerDidCancel:(__unused BTDropInViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)postNonceToServer:(NSString *)paymentMethodNonce {
    // Update URL with your server
    NSURL *paymentURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://liviapp.co/checkout.php?mobile=true&amount=%@", amount]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:paymentURL];
    request.HTTPBody = [[NSString stringWithFormat:@"payment_method_nonce=%@", paymentMethodNonce] dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPMethod = @"POST";
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // TODO: Handle success and failure
        NSString *responsestring = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding];
        NSLog(@"response %@",responsestring);
        
        NSDictionary *arrayresponse = [[NSJSONSerialization JSONObjectWithData:data options:0 error: NULL] mutableCopy];
        
        [self hideProgressHUD];
        PFUser *currentUser = [PFUser currentUser];
        currentUser[@"pendingPayment"] = amount;
        if([arrayresponse[@"status"] isEqualToString:@"failed"]){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Livi"
                                                            message: @"Your payment was declined"
                                                           delegate: self
                                                  cancelButtonTitle: @"OK"
                                                  otherButtonTitles: nil];
            [alert show];
            [self tappedMyPayButton];
        }else{
            currentUser[@"pendingPayment"] = @"";
            
            PFObject *transaction = [PFObject objectWithClassName:@"MyMoney"];
            transaction[@"userId"] = currentUser.objectId;
            transaction[@"paypalresponse"] = arrayresponse[@"realstatus"];
            transaction[@"taskId"] = self.taskId;
            transaction[@"value"] = amount;
            transaction[@"redeem"] = @"YES";
            
            [transaction saveInBackground];
            
            
            PFObject *transaction2 = [PFObject objectWithClassName:@"MyMoney"];
            transaction2[@"userId"] = _streamStrig;
            transaction2[@"paypalresponse"] = arrayresponse[@"realstatus"];
            transaction2[@"taskId"] = self.taskId;
            transaction2[@"value"] = amount;
            transaction2[@"earning"] = @"YES";
            
            [transaction2 saveInBackground];
            
        }
        [currentUser saveInBackground];
        
    }] resume];
}

-(void)cobropaypal {
    PFQuery *queryReq = [PFQuery queryWithClassName:@"Requests"];
    [queryReq getObjectInBackgroundWithId:self.taskId block:^(PFObject *request, NSError *error) {
        if(request[@"price"])
            amount = request[@"price"];
        
        _streamStrig = request[@"userId"];
        
                //Muestro paypal
                if (_progressHUD == nil)
                {
                    _progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                }
                NSURL *clientTokenURL = [NSURL URLWithString:@"http://liviapp.co/checkout.php?client_token=Zkdjs"];
                NSMutableURLRequest *clientTokenRequest = [NSMutableURLRequest requestWithURL:clientTokenURL];
                
                [[[NSURLSession sharedSession] dataTaskWithRequest:clientTokenRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                    
                    NSString *responsestring = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding];
                    NSLog(@"response %@",responsestring);
                    
                    NSDictionary *arrayresponse = [[NSJSONSerialization JSONObjectWithData:data options:0 error: NULL] mutableCopy];
                    
                    NSString *clientToken = arrayresponse[@"client_token"];
                    NSLog(@"client token %@", clientToken);
                    
                    self.braintreeClient = [[BTAPIClient alloc] initWithAuthorization:clientToken];
                    [self tappedMyPayButton];
                    
                }] resume];
        
        
    }];
}


@end
