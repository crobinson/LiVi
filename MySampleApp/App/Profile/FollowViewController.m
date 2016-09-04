//
//  FollowViewController.m
//  Livi
//
//  Created by Carlos Robinson on 6/30/16.
//  Copyright © 2016 livi. All rights reserved.
//

#import "FollowViewController.h"
#import <Parse/Parse.h>
#import "UIImage+Resize.h"
#import "RequestNotificationViewController.h"
#import "ChatViewController.h"
#import "MBProgressHUD.h"

@interface FollowViewController (){
    NSMutableArray *dataSource;
    NSMutableArray *dataSource2;
    UIImage *croppedImg;
    NSDictionary *obj;
}

@property (strong, nonatomic) MBProgressHUD *progressHUD;

@end

@implementation FollowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    dataSource = [[NSMutableArray alloc] init];
    dataSource2 = [[NSMutableArray alloc] init];
    if (_progressHUD == nil)
    {
        _progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    
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
    [self getDataSource];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getDataSource {
    //PFQuery *queryuser = [PFUser query];
    //[queryuser getObjectWithId:[PFUser currentUser].objectId];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Followers"];
    [query whereKey:@"userId" equalTo:[PFUser currentUser].objectId];
    [query orderByDescending:@"createdAt"];
    //NSArray *notifications = [query findObjects];
    [query findObjectsInBackgroundWithBlock:^(NSArray *notifications, NSError *error) {
        if (!error) {
            for (PFObject *userObj in notifications) {
                
                //Traigo el user q envía
                PFQuery *userquery = [PFUser query];
                [userquery whereKey:@"objectId" equalTo:userObj[@"following"]];
                NSArray *userobjects = [userquery findObjects];
                for (PFObject *user in userobjects){
                    //Traigo la imagen
                    
                    PFQuery *queryimg = [PFQuery queryWithClassName:@"UserImage"];
                    [queryimg whereKey:@"user" equalTo:user[@"username"]];
                    [queryimg orderByDescending:@"createdAt"];
                    NSArray *objects = [queryimg findObjects];
                    for (PFObject *imgObject in objects){
                        PFFile *image = (PFFile *)[imgObject objectForKey:@"image"];
                        UIImage *scaledImage = [[UIImage imageWithData:image.getData] resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:CGSizeMake(75, 55) interpolationQuality:kCGInterpolationHigh];
                        croppedImg = [scaledImage croppedImage:CGRectMake((scaledImage.size.width - 75)/2, (scaledImage.size.height - 66)/2, 75, 66)];
                    }
                    
                    NSLog(@"%@", userObj);
                    NSLog(@"%@", croppedImg);
                    
                    NSDictionary *dataDictionary = @{
                                                     @"nickname": user[@"nickname"],
                                                     @"description"   : user[@"description"],
                                                     @"image"   : croppedImg,
                                                     };
                    
                    
                    [dataSource addObject:dataDictionary];
                }
            }
            [_myTableView reloadData];
            [self hideProgressHUD];
        }
    }];
    
    PFQuery *query2 = [PFQuery queryWithClassName:@"Followers"];
    [query2 whereKey:@"following" equalTo:[PFUser currentUser].objectId];
    [query2 orderByDescending:@"createdAt"];
    //NSArray *followings = [query2 findObjects];
    [query2 findObjectsInBackgroundWithBlock:^(NSArray *followings, NSError *error) {
        if (!error) {
            for (PFObject *userObj in followings) {
                
                //Traigo el user q envía
                PFQuery *userquery = [PFUser query];
                [userquery whereKey:@"objectId" equalTo:userObj[@"userId"]];
                NSArray *userobjects = [userquery findObjects];
                for (PFObject *user in userobjects){
                    //Traigo la imagen
                    
                    PFQuery *queryimg = [PFQuery queryWithClassName:@"UserImage"];
                    [queryimg whereKey:@"user" equalTo:user[@"username"]];
                    [queryimg orderByDescending:@"createdAt"];
                    NSArray *objects = [queryimg findObjects];
                    croppedImg = nil;
                    for (PFObject *imgObject in objects){
                        PFFile *image = (PFFile *)[imgObject objectForKey:@"image"];
                        UIImage *scaledImage = [[UIImage imageWithData:image.getData] resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:CGSizeMake(75, 55) interpolationQuality:kCGInterpolationHigh];
                        croppedImg = [scaledImage croppedImage:CGRectMake((scaledImage.size.width - 75)/2, (scaledImage.size.height - 66)/2, 75, 66)];
                    }
                    
                    NSLog(@"%@", userObj);
                    NSLog(@"%@", croppedImg);
                    
                    NSDictionary *dataDictionary = @{
                                                     @"nickname": user[@"nickname"],
                                                     @"description"   : user[@"description"],
                                                     @"image"   : croppedImg,
                                                     };
                    
                    
                    [dataSource2 addObject:dataDictionary];
                }
            }
            [_myTableView2 reloadData];
        }
    }];
    
    
    
    
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView==_myTableView)
        return dataSource.count;
    
    return dataSource2.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return 66;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //tableView = _mytableview;
    static NSString * CellIdentifier = @"notificacion";
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    if ( cell == nil ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    // Configure the cell...
    
    
    if(tableView==_myTableView2)
        obj = [dataSource2 objectAtIndex:indexPath.row];
    
    if(tableView==_myTableView)
        obj = [dataSource objectAtIndex:indexPath.row];
    
    NSLog(@"%@", obj);
    
    UIImageView *_fromimageView = (UIImageView *)[cell viewWithTag:101];
    UILabel *nombre = (UILabel *)[cell viewWithTag:102];
    UILabel *descripcion = (UILabel *)[cell viewWithTag:103];
    
    _fromimageView.image = obj[@"image"];
    nombre.text = obj[@"nickname"];
    descripcion.text = obj[@"description"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *obj = [dataSource objectAtIndex:indexPath.row];
    NSLog(@"%@", obj);
    if([obj[@"alert"] isEqualToString:@"Live Stream Request"]){
        
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Notificaciones" bundle:nil];
        RequestNotificationViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"RequestNotification"];
        viewController.userId = obj[@"objectId"];
        [self.navigationController pushViewController:viewController
                                             animated:YES];
        
        
    } else if([obj[@"alert"] isEqualToString:@"Live Stream / Task Acepted"]){
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Notificaciones" bundle:nil];
        RequestNotificationViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"TaskAceptedNotification"];
        viewController.userId = obj[@"objectId"];
        [self.navigationController pushViewController:viewController
                                             animated:YES];
        /*UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Notificaciones" bundle:nil];
         RequestNotificationViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"TaskAceptedNotification"];
         viewController.userId = userInfo[@"title"];
         UINavigationController *navigationController = (UINavigationController*)self.window.rootViewController;
         [navigationController pushViewController:viewController animated:YES];
         
         if ([userInfo objectForKey:@"badge"]) {
         [application setApplicationIconBadgeNumber:0];
         }*/
    } else if([obj[@"alert"] isEqualToString:@"Sorry the estblishment you want to see is not available"]){
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Notificaciones" bundle:nil];
        RequestNotificationViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"SorryNotification"];
        viewController.userId = obj[@"objectId"];
        [self.navigationController pushViewController:viewController
                                             animated:YES];
    } else if([obj[@"alert"] isEqualToString:@"Message Received"]){
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"InstantRequest" bundle:nil];
        ChatViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"chat"];
        viewController.myUserId = [PFUser currentUser].objectId;
        NSLog(@"%@", obj);
        viewController.chatMateId = obj[@"from"];
        viewController.taskId = obj[@"taskId"];
        [self.navigationController pushViewController:viewController
                                             animated:YES];
    }
}
-(IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
