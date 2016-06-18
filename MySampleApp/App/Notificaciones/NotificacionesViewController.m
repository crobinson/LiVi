//
//  NotificacionesViewController.m
//  Livi
//
//  Created by Carlos Robinson on 4/22/16.
//  Copyright © 2016 livi. All rights reserved.
//

#import "NotificacionesViewController.h"
#import <Parse/Parse.h>
#import "UIImage+Resize.h"
#import "RequestNotificationViewController.h"

@interface NotificacionesViewController (){
    NSMutableArray *dataSource;
    UIImage *croppedImg;
}

@end

@implementation NotificacionesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    dataSource = [[NSMutableArray alloc] init];
    [self getDataSource];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getDataSource {
    //PFQuery *queryuser = [PFUser query];
    //[queryuser getObjectWithId:[PFUser currentUser].objectId];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Notifications"];
    [query whereKey:@"to" equalTo:[PFUser currentUser].objectId];
    NSArray *notifications = [query findObjects];
    for (PFObject *userObj in notifications) {
        
        //Traigo el user q envía
        NSLog(@"%@", userObj[@"from"]);
        PFQuery *userquery = [PFUser query];
        [userquery whereKey:@"objectId" equalTo:userObj[@"from"]];
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
                                                     @"objectId": userObj[@"from"],
                                                     @"title"   : userObj[@"title"],
                                                     @"alert"   : userObj[@"alert"],
                                                     @"image"   : croppedImg,
                                                     };
                    
                    [dataSource addObject:dataDictionary];
                }
            
        
    }
    [_myTableView reloadData];
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
    return dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return 66;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //tableView = _mytableview;
    static NSString * CellIdentifier = @"notificacion";

    
    UITableViewCell *cell = [_myTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    if ( cell == nil ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    // Configure the cell...
    NSDictionary *obj = [dataSource objectAtIndex:indexPath.row];
    NSLog(@"%@", obj);
    
    UIImageView *_miimageView = (UIImageView *)[cell viewWithTag:100];
    UIImageView *_fromimageView = (UIImageView *)[cell viewWithTag:101];
    UILabel *nombre = (UILabel *)[cell viewWithTag:102];
    UILabel *descripcion = (UILabel *)[cell viewWithTag:103];
    
    _fromimageView.image = obj[@"image"];
    nombre.text = obj[@"title"];
    descripcion.text = obj[@"alert"];
    
    
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
        /*UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Notificaciones" bundle:nil];
         RequestNotificationViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"SorryNotification"];
         viewController.userId = userInfo[@"title"];
         UINavigationController *navigationController = (UINavigationController*)self.window.rootViewController;
         [navigationController pushViewController:viewController animated:YES];
         
         if ([userInfo objectForKey:@"badge"]) {
         [application setApplicationIconBadgeNumber:0];
         }*/
    }
}
-(IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
