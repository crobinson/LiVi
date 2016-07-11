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


@interface TasksViewController (){
    NSMutableArray *dataSource;
    UIImage *croppedImg;
    PFObject *taskObj;
}

@end

@implementation TasksViewController

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
    PFQuery *query = [PFQuery queryWithClassName:@"Requests"];
    float latitudtemp = [[PFUser currentUser][@"latitudTemporal"] floatValue];
    float longitudTemp= [[PFUser currentUser][@"longitudTemporal"] floatValue];
    
    PFGeoPoint *userGeoPoint = [PFGeoPoint geoPointWithLatitude:latitudtemp longitude:longitudTemp];
    [query whereKey:@"location" nearGeoPoint:userGeoPoint withinKilometers: 100.0];
    
    NSArray *tasks = [query findObjects];
    NSLog(@"%i", tasks.count);
    for (PFObject *userObj in tasks) {
        //traigo la imagen
        NSLog(@"%@", userObj.objectId);
        if(!userObj[@"pv"]){
            croppedImg = nil;
            PFQuery *queryimg = [PFQuery queryWithClassName:@"TaskImages"];
            [queryimg whereKey:@"taskId" equalTo:userObj.objectId];
            [queryimg orderByDescending:@"createdAt"];
            NSArray *objects = [queryimg findObjects];
            for (PFObject *imgObject in objects){
                PFFile *image = (PFFile *)[imgObject objectForKey:@"image"];
                UIImage *scaledImage = [[UIImage imageWithData:image.getData] resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:CGSizeMake(75, 55) interpolationQuality:kCGInterpolationHigh];
                croppedImg = [scaledImage croppedImage:CGRectMake((scaledImage.size.width - 75)/2, (scaledImage.size.height - 66)/2, 75, 66)];
            }
            
            
            if(croppedImg)
                NSLog(@"%@", croppedImg);
            else{
                croppedImg = [UIImage imageNamed:@"avatarm.PNG"];
            }
            
                
                NSDictionary *dataDictionary = @{
                                                 @"title"   : userObj[@"title"],
                                                 @"alert"   : userObj[@"date"],
                                                 @"image"   : croppedImg,
                                                 @"object"  : userObj,
                                                 };
                
                [dataSource addObject:dataDictionary];
        }
        
    }
    [_myTableView reloadData];
}


 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
     if ([segue.identifier isEqualToString:@"gotoTask"]) {
         AcceptTaskViewController *ct = segue.destinationViewController;
         NSLog(@"%@", taskObj);
         ct.obj = taskObj;
     }
 }


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
    
    //UIImageView *_miimageView = (UIImageView *)[cell viewWithTag:100];
    UIImageView *_fromimageView = (UIImageView *)[cell viewWithTag:101];
    UILabel *nombre = (UILabel *)[cell viewWithTag:102];
    UILabel *descripcion = (UILabel *)[cell viewWithTag:103];
    
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
    NSDictionary *obj = [dataSource objectAtIndex:indexPath.row];
    taskObj = obj[@"object"];
    [self performSegueWithIdentifier:@"gotoTask" sender:self];
    
}
-(IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
