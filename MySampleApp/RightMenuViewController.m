//
//  RightMenuViewController.m
//  SlideMenu
//
//  Created by Aryan Gh on 4/26/14.
//  Copyright (c) 2014 Aryan Ghassemi. All rights reserved.
//

#import "RightMenuViewController.h"
#import "UIImageView+WebCache.h"
#import <Parse/Parse.h>
#import "UIImage+Resize.h"
#import "VendorProfileViewController.h"


@implementation RightMenuViewController


#pragma mark - UIViewController Methods -

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.tableView.separatorColor = [UIColor lightGrayColor];
    aroundDataSource    = [[NSMutableArray alloc] init];
    self.selectButton.layer.cornerRadius = 10;
    [self getAroundPV:nil];
	
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

-(void)getAroundPV:(NSString *)vendor {
   
    if (_progressHUD == nil)
    {
        _progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }

    
    [aroundDataSource removeAllObjects];
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
        croppedImg = nil;
        for (PFObject *imgObject in imgobjects){
            PFFile *image = (PFFile *)[imgObject objectForKey:@"image"];
            UIImage *scaledImage = [[UIImage imageWithData:image.getData] resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:CGSizeMake(103, 103) interpolationQuality:kCGInterpolationHigh];
            croppedImg = [scaledImage croppedImage:CGRectMake((scaledImage.size.width -103)/2, (scaledImage.size.height -103)/2, 103, 103)];
        }
        
        if(!croppedImg)
            croppedImg = [UIImage imageNamed:@"avatarm.PNG"];
        
        NSMutableDictionary *aroundDic=[[NSMutableDictionary alloc] initWithCapacity:3];
        [aroundDic setValue:userObj forKey:@"UserData"];
        [aroundDic setValue:userObj.objectId forKey:@"objectId"];
        [aroundDic setValue:croppedImg forKey:@"UserImage"];
        
        [aroundDataSource addObject:aroundDic];
        
    }
    [self hideProgressHUD];
    [self.tableView reloadData];
   
}

#pragma mark - UITableView Delegate & Datasrouce -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return aroundDataSource.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
	return 111;
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


@end
