//
//  TasksViewController.m
//  Livi
//
//  Created by Carlos Robinson on 6/10/16.
//  Copyright © 2016 livi. All rights reserved.
//

#import "TasksViewController.h"
#import <Parse/Parse.h>
#import "UIImage+Resize.h"
#import "AcceptTaskViewController.h"
#import "RequestNotificationViewController.h"


@interface TasksViewController (){
    NSMutableDictionary *dataSource;
    UIImage *croppedImg;
    PFObject *taskObj;
}

@end

@implementation TasksViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    dataSource = [[NSMutableDictionary alloc] init];
    dataSource[@"My Tasks"] = [[NSMutableArray alloc] init];
    dataSource[@"Around me"] = [[NSMutableArray alloc] init];
}

-(void)viewDidAppear:(BOOL)animated{
    [dataSource[@"My Tasks"] removeAllObjects];
    [dataSource[@"Around me"] removeAllObjects];
    [self getDataSource];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getDataSource {
    PFQuery *query = [PFQuery queryWithClassName:@"Requests"];
    
    PFGeoPoint *userGeoPoint = (PFGeoPoint *)[PFUser currentUser][@"location"];
    [query whereKey:@"location" nearGeoPoint:userGeoPoint withinKilometers: 100.0];
    //[query whereKeyDoesNotExist:@"responsable"];
    [query whereKeyDoesNotExist:@"pv"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *tasks, NSError *error) {
        if (!error) {
            
            for (PFObject *userObj in tasks) {
                //traigo la imagen
                croppedImg = nil;
                PFQuery *queryimg = [PFQuery queryWithClassName:@"TaskImages"];
                [queryimg whereKey:@"taskId" equalTo:userObj.objectId];
                [queryimg orderByDescending:@"createdAt"];
                NSArray *objects = [queryimg findObjects];
                croppedImg = [UIImage imageNamed:@"avatarm.PNG"];
                UIImage *scaledImage = [croppedImg resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:CGSizeMake(75, 55) interpolationQuality:kCGInterpolationHigh];
                croppedImg = [scaledImage croppedImage:CGRectMake((scaledImage.size.width - 75)/2, (scaledImage.size.height - 66)/2, 75, 66)];
                for (PFObject *imgObject in objects){
                    PFFile *image = (PFFile *)[imgObject objectForKey:@"image"];
                    UIImage *scaledImage = [[UIImage imageWithData:image.getData] resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:CGSizeMake(75, 55) interpolationQuality:kCGInterpolationHigh];
                    croppedImg = [scaledImage croppedImage:CGRectMake((scaledImage.size.width - 75)/2, (scaledImage.size.height - 66)/2, 75, 66)];
                }
                
                NSDictionary *dataDictionary = @{
                                                 @"objectId": userObj[@"userId"],
                                                 @"title"   : userObj[@"title"],
                                                 @"alert"   : userObj[@"date"],
                                                 @"image"   : croppedImg,
                                                 @"object"  : userObj,
                                                 };
                
                if(!userObj[@"responsable"] || [userObj[@"responsable"] isEqualToString:@""])
                    [dataSource[@"Around me"] addObject:dataDictionary];
                
                if([userObj[@"responsable"] isEqualToString:[PFUser currentUser].objectId])
                    [dataSource[@"My Tasks"] addObject:dataDictionary];
                
                if(userObj[@"creator"]==[PFUser currentUser])
                    [dataSource[@"My Tasks"] addObject:dataDictionary];
                
                
            }
            [_myTableView reloadData];
        }
    }];
    
}


 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
     if ([segue.identifier isEqualToString:@"gotoTask"]) {
         AcceptTaskViewController *ct = segue.destinationViewController;
         ct.obj = taskObj;
     }
 }


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section==0)
        return @"My Tasks";
    
    return @"Around me";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSMutableArray *myacepted = [dataSource[@"My Tasks"] mutableCopy];
    NSMutableArray *aroundme = [dataSource[@"Around me"] mutableCopy];
    if(section==0)
        return myacepted.count;
    
    return aroundme.count;
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
    NSMutableArray *myacepted = [dataSource[@"My Tasks"] mutableCopy];
    NSMutableArray *aroundme = [dataSource[@"Around me"] mutableCopy];
    NSDictionary *obj = [[NSDictionary alloc] init];
    if(indexPath.section==0)
        obj = [myacepted objectAtIndex:indexPath.row];

    if(indexPath.section==1)
        obj = [aroundme objectAtIndex:indexPath.row];
    
    
    //UIImageView *_miimageView = (UIImageView *)[cell viewWithTag:100];
    UIImageView *_fromimageView = (UIImageView *)[cell viewWithTag:101];
    UILabel *nombre = (UILabel *)[cell viewWithTag:102];
    UILabel *descripcion = (UILabel *)[cell viewWithTag:103];
    UILabel *reference = (UILabel *)[cell viewWithTag:104];
    
    reference.text = @"";
    
    if([obj[@"object"][@"responsable"] isEqualToString:[PFUser currentUser].objectId])
        reference.text = @"Accepted Task";
    
    if(obj[@"creator"]==[PFUser currentUser])
        reference.text = @"Requested Task";
    
    _fromimageView.image = obj[@"image"];
    nombre.text = obj[@"title"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"h:mm a EEE, MMM d, yyyy"];
    //cell.dateLabel.text = [formatter stringFromDate:obj[@"alert"]];
    
    descripcion.text = [formatter stringFromDate:obj[@"alert"]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *myacepted = [dataSource[@"My Tasks"] mutableCopy];
    NSMutableArray *aroundme = [dataSource[@"Around me"] mutableCopy];
    NSDictionary *obj = [[NSDictionary alloc] init];
    
    if(indexPath.section==0){
        obj = [myacepted objectAtIndex:indexPath.row];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Notificaciones" bundle:nil];
        RequestNotificationViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"RequestNotification"];
        viewController.userId = obj[@"objectId"];
        [self.navigationController pushViewController:viewController
                                             animated:YES];
        
    }
    
    if(indexPath.section==1){
        obj = [aroundme objectAtIndex:indexPath.row];
        taskObj = obj[@"object"];
        [self performSegueWithIdentifier:@"gotoTask" sender:self];
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
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
