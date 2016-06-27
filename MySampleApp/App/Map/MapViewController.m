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
}

@property(nonatomic, strong) UITableView *table;
@property(nonatomic, strong) UIButton *btnSender;
@property(nonatomic, retain) NSArray *list;
@property(nonatomic, retain) NSArray *imageList;
@property (nonatomic, retain) NSString *animationDirection;

@property (strong, nonatomic) MBProgressHUD *progressHUD;


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
    [Parse setApplicationId:@"BsIBfZnR1xUg1ZY9AwGcd3iKtqrMPu2zUTjP49ta" clientKey:@"E2od7oEslPMj6C2yG9GnWXvC9qDicnTNgcDgN9xm"];
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
    
    
    UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(closemenus)];
    leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    
    //Inicio los datasources
    
    dataSource          = [[NSMutableArray alloc] init];
    aroundDataSource    = [[NSMutableArray alloc] init];
    
    
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

        [_menuTableView addGestureRecognizer:leftSwipe];
    
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
    _menuTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _menuTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
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
        
        [self getDataSource];

        
    }else{
        
        PFUser *currentUser = [PFUser currentUser];
        if (currentUser) {
            // Buscamos descripcion en parse
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
            [self getDataSource];
            
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

-(void)getAroundPV:(NSString *)vendor {
    if (_progressHUD == nil)
    {
        _progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }

    [aroundDataSource removeAllObjects];
    [_aroundTableView reloadData];
    PFQuery *query = [PFUser query];
    if(!vendor)
        [query whereKey:@"vendor" notEqualTo:@"NO"];
    else
        [query whereKey:@"vendor" equalTo:vendor];
    
    [query orderByDescending:@"createdAt"];
    //[query orderByDescending:@"createdAt"];
    NSArray *objects = [query findObjects];
    for (PFObject *userObj in objects){
        PFQuery *queryimg = [PFQuery queryWithClassName:@"UserImage"];
        [queryimg whereKey:@"user" equalTo:userObj[@"username"]];
        [queryimg orderByDescending:@"createdAt"];
        NSArray *imgobjects = [queryimg findObjects];
        for (PFObject *imgObject in imgobjects){
            PFFile *image = (PFFile *)[imgObject objectForKey:@"image"];
            UIImage *scaledImage = [[UIImage imageWithData:image.getData] resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:CGSizeMake(103, 103) interpolationQuality:kCGInterpolationHigh];
            croppedImg = [scaledImage croppedImage:CGRectMake((scaledImage.size.width -103)/2, (scaledImage.size.height -103)/2, 103, 103)];
        }
        
        NSMutableDictionary *aroundDic=[[NSMutableDictionary alloc] initWithCapacity:3];
        [aroundDic setValue:userObj forKey:@"UserData"];
        [aroundDic setValue:userObj.objectId forKey:@"objectId"];
        [aroundDic setValue:croppedImg forKey:@"UserImage"];
        
        [aroundDataSource addObject:aroundDic];

    }
    NSLog(@"%@", aroundDataSource);
    [_aroundTableView reloadData];
    if(!bandera)
        [self getPV];
    else
        [self hideProgressHUD];
}

-(void)getPV {
    bandera = YES; // Para no seguirlos llamando cuando no sea necesario
    PFQuery *query = [PFUser query];
    [query whereKey:@"vendor" notEqualTo:@"NO"];
    [query orderByDescending:@"createdAt"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            
            NSMutableArray *datasourcetemporal = [NSMutableArray arrayWithObjects:nil];
            //Everything was correct, put the new objects and load the wall
            for (PFObject *userObj in objects){
                NSLog(@"%@", userObj);
                
                //Traigo la imagen
                
                PFQuery *queryimg = [PFQuery queryWithClassName:@"UserImage"];
                [queryimg whereKey:@"user" equalTo:userObj[@"username"]];
                [queryimg orderByDescending:@"createdAt"];
                /*[queryimg findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    if (!error) {
                        //Everything was correct, put the new objects and load the wall
                        
                    }
                }];*/
                NSArray *objects = [queryimg findObjects];
                for (PFObject *imgObject in objects){
                    PFFile *image = (PFFile *)[imgObject objectForKey:@"image"];
                    UIImage *scaledImage = [[UIImage imageWithData:image.getData] resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:CGSizeMake(103, 103) interpolationQuality:kCGInterpolationHigh];
                    croppedImg = [scaledImage croppedImage:CGRectMake((scaledImage.size.width -103)/2, (scaledImage.size.height -103)/2, 103, 103)];
                    NSLog(@"%@", croppedImg);
                    
                }
                
                NSLog(@"%@", croppedImg);
                
                PFGeoPoint *geopoint = (PFGeoPoint *)[userObj objectForKey:@"location"];
                CLLocationCoordinate2D coordinate;
                coordinate.latitude = geopoint.latitude;
                coordinate.longitude = geopoint.longitude;
                //destino.coordinate = coordinate;

                MyAnnotation *destino = [[MyAnnotation alloc]
                                         initWithTitle:userObj[@"username"]
                                         andSubtitle:userObj[@"description"]
                                         andImage:croppedImg
                                         andUrlIos:userObj.objectId
                                         andUrlOther:userObj[@"nickname"]
                                         andCoordinate:coordinate];
            
                NSDictionary *datoTemporal=@{
                                             @"nickname" : userObj[@"nickname"],
                                             @"latitude" : [NSString stringWithFormat:@"%f", coordinate.latitude],
                                             @"longitude" : [NSString stringWithFormat:@"%f", coordinate.longitude],
                                             };
                [datasourcetemporal addObject:datoTemporal];
                //destino.title = userObj[@"firstname"];
                //destino.accessibilityHint = userObj[@"vendor"];
                //destino.accessibilityHint = userObj[@"username"];
                
                [_mvMap addAnnotation:destino];
            }
            pvObjects = datasourcetemporal;
            [self hideProgressHUD];
        }else {
            [self hideProgressHUD];
            NSString *errorString = [[error userInfo] objectForKey:@"error"];
            UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [errorAlertView show];
        }
    }];
    
}

- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer
{
    NSLog(@"entro");
    
    //[self performSegueWithIdentifier:@"addpopover" sender:self];
    
    CGPoint touchPoint = [gestureRecognizer locationInView:_mvMap];
    CLLocationCoordinate2D touchMapCoordinate =
    [self.mvMap convertPoint:touchPoint toCoordinateFromView:self.mvMap];
    
    MKPointAnnotation *annot = [[MKPointAnnotation alloc] init];
    annot.coordinate = touchMapCoordinate;
    newannot = [[MKPointAnnotation alloc] init];
    newannot = annot;
    //[self.mvMap addAnnotation:annot];
    
    [self performSegueWithIdentifier:@"addpopover" sender:self];
    
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
                NSLog(@"%@", userObj);
                
                //Traigo la imagen
                
                PFQuery *queryimg = [PFQuery queryWithClassName:@"UserImage"];
                [queryimg whereKey:@"user" equalTo:userObj[@"username"]];
                [queryimg orderByDescending:@"createdAt"];
                NSArray *userImage = [queryimg findObjects];
                NSLog(@"%@", userImage);
                for (PFObject *imgObject in userImage){
                    PFFile *image = (PFFile *)[imgObject objectForKey:@"image"];
                    UIImage *scaledImage = [[UIImage imageWithData:image.getData] resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:CGSizeMake(103, 103) interpolationQuality:kCGInterpolationHigh];
                    croppedImg = [scaledImage croppedImage:CGRectMake((scaledImage.size.width -103)/2, (scaledImage.size.height -103)/2, 103, 103)];
                }
                if(croppedImg)
                    NSLog(@"%@", croppedImg);
                else{
                    croppedImg = [UIImage imageNamed:@"avatarm.PNG"];
                }
                
                NSMutableDictionary *happening = [[NSMutableDictionary alloc] initWithDictionary: @{
                                                                                                   @"UserData" : userObj,
                                                                                                   @"objectId" : userObj.objectId,
                                                                                                   @"UserImage" : croppedImg,
                                                                                                   @"Likes" : @"",
                                                                                                   }];
                
                
                
                [dataSource addObject:happening];
            }
            
            [_happeningTableView reloadData];
        }else {
            NSString *errorString = [[error userInfo] objectForKey:@"error"];
            UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [errorAlertView show];
        }
        [self getAroundPV:nil];
    }];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    
    //if (![annotation isKindOfClass:[MyAnnotationView class]])
        //return nil;
    
    static NSString *identifier = @"MyAnnotation";
    MyAnnotationView * pinView = (MyAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    MyAnnotation *anot = annotation;
    // If it's the user location, just return nil.
    
    if (!pinView)
    {
        // If an existing pin view was not available, create one.
       pinView = [[MyAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        NSLog(@"%@", anot.title);
        PFQuery *query = [PFUser query];
        [query whereKey:@"username" equalTo:anot.title];
        [query orderByDescending:@"createdAt"];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                //Everything was correct, put the new objects and load the wall
                for (PFObject *userObj in objects){
                    NSLog(@"%@", userObj);
                    if([userObj[@"vendor"] isEqualToString:@"Online Enterprices"]){
                        pinView.image = [UIImage imageNamed:@"pinrojo.png"];
                    }else if([userObj[@"vendor"] isEqualToString:@"Night Live"]){
                        pinView.image = [UIImage imageNamed:@"pinazul.png"];
                    }else if([userObj[@"vendor"] isEqualToString:@"Dinning"]){
                        pinView.image = [UIImage imageNamed:@"pinverde.png"];
                    }else{
                        pinView.image = [UIImage imageNamed:@"pinvioleta.png"];
                    }
                    
                    pinView.calloutOffset = CGPointMake(0, 32);

                }
            }
        }];
        
        
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
            vpImgView.image = anot.proImage;
        
        vpImgView.layer.masksToBounds = YES;
        [vpImgView.layer setCornerRadius:51.0f];
        
        UIButton *viewRequest = (UIButton *)[calloutview viewWithTag:102];
        //viewRequest.hidden = YES;
        UIButton *addRequest = (UIButton *)[calloutview viewWithTag:103];
        [viewRequest addTarget:self action:@selector(viewAction:) forControlEvents:UIControlEventTouchUpInside];
        [addRequest addTarget:self action:@selector(requestAction:) forControlEvents:UIControlEventTouchUpInside];
        /*if(anot.urlStream && ![anot.urlStream isEqualToString:@""]){
            viewRequest.hidden = NO;
            
            addRequest.hidden = YES;
        }else{
            addRequest.hidden = NO;
            
        }*/

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

-(IBAction)showmenu:(id)sender
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.50];
    [UIView setAnimationDelegate:self];
    
    if(_menuTableView.frame.origin.x != 0){
        _menuTableView.frame = CGRectMake(0, _menuTableView.frame.origin.y, _menuTableView.frame.size.width, _menuTableView.frame.size.height);
    }else{
        _menuTableView.frame = CGRectMake(0 - _menuTableView.frame.size.width, _menuTableView.frame.origin.y, _menuTableView.frame.size.width, _menuTableView.frame.size.height);
    }
    [UIView commitAnimations];
    
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

-(void)closemenus {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.50];
    [UIView setAnimationDelegate:self];
    _menuTableView.frame = CGRectMake(0 - _menuTableView.frame.size.width, _menuTableView.frame.origin.y, _menuTableView.frame.size.width, _menuTableView.frame.size.height);
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
    }else{
        if(indexPath.row==0){
            CellIdentifier = @"header";
        }else{
            CellIdentifier = @"menu";
        }
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
        _miimageView.image = source[@"UserImage"];
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
        _miimageView.image = source[@"UserImage"];
        nombre.text = sourceUser[@"businessname"];
        descripcion.text = sourceUser[@"description"];
        return cell;

    }else{
        AWSIdentityManager *identityManager = [AWSIdentityManager sharedInstance];
        NSURL *imageUrl = identityManager.imageURL;
        
        if(indexPath.row==0){
            UIImageView *_miimageView = (UIImageView *)[cell viewWithTag:101];
            UILabel *nombre = (UILabel *)[cell viewWithTag:102];
            UILabel *email = (UILabel *)[cell viewWithTag:103];
            _miimageView.layer.masksToBounds = YES;
            [_miimageView.layer setCornerRadius:39.0f];
            
            if ([AWSIdentityManager sharedInstance].isLoggedIn) {
                
                [_miimageView sd_setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:@"avatarm.PNG"]];
                if (identityManager.userName) {
                    nombre.text = identityManager.userName;
                } else {
                    nombre.text = NSLocalizedString(@"GUEST USER", @"Placeholder text for the guest user.");
                }
                [[NSUserDefaults standardUserDefaults] setObject:identityManager.identityId forKey:@"objectId"];
                email.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"email"];
            }else{
                PFUser *currentUser = [PFUser currentUser];
                if (currentUser) {
                    _miimageView.image = croppedImage;
                    email.text = currentUser.username;
                    [[NSUserDefaults standardUserDefaults] setObject:currentUser.objectId forKey:@"objectId"];
                    nombre.text = [NSString stringWithFormat:@"%@ %@", currentUser[@"firstname"], currentUser[@"lastname"]];
                    
                }
            }
            
        }else{
            UIImageView *_miimageView = (UIImageView *)[cell viewWithTag:101];
            UILabel *texto = (UILabel *)[cell viewWithTag:102];
            if(indexPath.row==1){
                _miimageView.image = [UIImage imageNamed:@"browse.png"];
                texto.text = @"Browse";
            }
            else if(indexPath.row==2){
                _miimageView.image = [UIImage imageNamed:@"calendar.png"];
                texto.text = @"My Schedule";
            }
            if(indexPath.row==3){
                _miimageView.image = [UIImage imageNamed:@"notifications.png"];
                texto.text = @"Notifications";
            }
            else if(indexPath.row==4){
                _miimageView.image = [UIImage imageNamed:@"task.png"];
                texto.text = @"Task/Request";
            }
            else if(indexPath.row==5){
                _miimageView.image = [UIImage imageNamed:@"profile.png"];
                texto.text = @"Profile";
            }
            else if(indexPath.row==6){
                _miimageView.image = [UIImage imageNamed:@"play.png"];
                texto.text = @"Start Stream";
            }
            else if(indexPath.row==7){
                _miimageView.image = [UIImage imageNamed:@"cupons.png"];
                texto.text = @"Coupons";
            }
            else if(indexPath.row==8){
                _miimageView.image = [UIImage imageNamed:@"money.png"];
                texto.text = @"My Money";
            }
        }
    }
    

    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    _menuTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _menuTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    if(tableView==_aroundTableView){
        //Alguna
    }else if(tableView==table){
        UITableViewCell *c = [tableView cellForRowAtIndexPath:indexPath];
        NSString *str = [NSString stringWithFormat:@"%@", c.textLabel.text];
        [_selectButton setTitle:str forState:UIControlStateNormal];
        //[self getAroundPV:c.textLabel.text];
    }else{
        if(indexPath.row == 5){
            PFUser *currentUser = [PFUser currentUser];
            if (currentUser) {
                /*if(![currentUser[@"vendor"] isEqualToString:@"NO"]){
                 NSLog(@"%@", currentUser[@"description"]);
                 UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"VendorProfile" bundle:nil];
                 UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"VendorProfile"];
                 [self.navigationController pushViewController:viewController
                 animated:YES];
                 }else if([currentUser[@"vendor"] isEqualToString:@"NO"]){*/
                NSLog(@"%@", currentUser[@"description"]);
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"UserProfile" bundle:nil];
                UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"UserProfile"];
                [self.navigationController pushViewController:viewController
                                                     animated:YES];
                //}
            }else{
                NSLog(@"%@", currentUser[@"description"]);
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"UserProfile" bundle:nil];
                UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"UserProfile"];
                [self.navigationController pushViewController:viewController
                                                     animated:YES];
            }
        }else if (indexPath.row==4){
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"InstantRequest" bundle:nil];
            UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"Tasksrequests"];
            [self.navigationController pushViewController:viewController
                                                 animated:YES];
        }else if (indexPath.row==6){
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Stream" bundle:nil];
            UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"streamView"];
            [self.navigationController pushViewController:viewController
                                                 animated:YES];
        }else if (indexPath.row==7){
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Coupons" bundle:nil];
            UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"myCoupons"];
            [self.navigationController pushViewController:viewController
                                                 animated:YES];
        }else if (indexPath.row==3){
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Notificaciones" bundle:nil];
            UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"Notificaciones"];
            [self.navigationController pushViewController:viewController
                                                 animated:YES];
        }else if (indexPath.row==2){
            [self.navigationController pushViewController:[[BasicViewController alloc] initWithNibName:@"BasicViewController" bundle:nil]
                                                 animated:YES];
        }
        
    }
    
    

}

-(void)viewAction:(UIButton *)sender{
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Livi" bundle:nil];
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
                        notificationObject[@"title"] = [PFUser currentUser][@"nickname"];
                        notificationObject[@"from"] = [PFUser currentUser].objectId;
                        notificationObject[@"to"] = anotationSelected.urlStreamIos;
                        [notificationObject save];
                        
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
    [query whereKey:@"user" equalTo:currentUser.username];
    [query orderByDescending:@"createdAt"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            //Everything was correct, put the new objects and load the wall
            for (PFObject *imgObject in objects){
                PFFile *image = (PFFile *)[imgObject objectForKey:@"image"];
                //UIImageView *userImage = [[UIImageView alloc] initWithImage:[UIImage imageWithData:image.getData]];
                //NSLog(@"%@", image.getData);
                UIImage *scaledImage = [[UIImage imageWithData:image.getData] resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:CGSizeMake(78, 78) interpolationQuality:kCGInterpolationHigh];
                // Crop the image to a square (yikes, fancy!)
                croppedImage = [scaledImage croppedImage:CGRectMake((scaledImage.size.width -78)/2, (scaledImage.size.height -78)/2, 78, 78)];
                
            }
            
            if(objects.count<1){
                croppedImage = [UIImage imageNamed:@"avatar.PNG"];
            }
            
            [_menuTableView reloadData];
        } else {
            NSString *errorString = [[error userInfo] objectForKey:@"error"];
            UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [errorAlertView show];
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
        origen.title = @"Yo";
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
        [[PFUser currentUser] save];
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
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"nickname CONTAINS %@", textField.text ];
    
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


@end
