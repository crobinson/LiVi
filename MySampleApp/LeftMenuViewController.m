//
//  MenuViewController.m
//  SlideMenu
//
//  Created by Aryan Gh on 4/24/13.
//  Copyright (c) 2013 Aryan Ghassemi. All rights reserved.
//

#import "LeftMenuViewController.h"
#import "SlideNavigationContorllerAnimatorFade.h"
#import "SlideNavigationContorllerAnimatorSlide.h"
#import "SlideNavigationContorllerAnimatorScale.h"
#import "SlideNavigationContorllerAnimatorScaleAndFade.h"
#import "SlideNavigationContorllerAnimatorSlideAndFade.h"
#import <Parse/Parse.h>
#import "BasicViewController.h"

@implementation LeftMenuViewController

#pragma mark - UIViewController Methods -

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self.slideOutAnimationEnabled = YES;
	
	return [super initWithCoder:aDecoder];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	self.tableView.separatorColor = [UIColor lightGrayColor];
    [Parse setApplicationId:@"BsIBfZnR1xUg1ZY9AwGcd3iKtqrMPu2zUTjP49ta" clientKey:@"E2od7oEslPMj6C2yG9GnWXvC9qDicnTNgcDgN9xm"];

}

#pragma mark - UITableView Delegate & Datasrouce -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 9;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if(indexPath.row==0 && tableView==self.tableView){
        return 138;
    }
	return 69;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"menu";
    if(indexPath.row==0){
        CellIdentifier = @"header";
    }else{
        CellIdentifier = @"menu";
    }
    
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
    UIImageView *_miimageView = (UIImageView *)[cell viewWithTag:101];
    UILabel *nombre = (UILabel *)[cell viewWithTag:102];
    UILabel *email = (UILabel *)[cell viewWithTag:103];

    
    UILabel *texto = (UILabel *)[cell viewWithTag:102];
    if(indexPath.row==0){
        _miimageView.layer.masksToBounds = YES;
        [_miimageView.layer setCornerRadius:39.0f];
        PFUser *currentUser = [PFUser currentUser];
        if (currentUser) {
            //_miimageView.image = [[NSUserDefaults standardUserDefaults] objectForKey:@"myImage"];
            email.text = currentUser.username;
            [[NSUserDefaults standardUserDefaults] setObject:currentUser.objectId forKey:@"objectId"];
            nombre.text = [NSString stringWithFormat:@"%@ %@", currentUser[@"firstname"], currentUser[@"lastname"]];
            
        }
    }else if(indexPath.row==1){
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
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	UIViewController *vc ;
    UIStoryboard *storyboard ;
    PFUser *currentUser = [PFUser currentUser];
	
	switch (indexPath.row)
	{
		case 0:
            vc = nil;
			break;
			
		case 1:
            storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            vc = [storyboard instantiateViewControllerWithIdentifier: @"Map"];
			
		case 2:
            vc = [[BasicViewController alloc] initWithNibName:@"BasicViewController" bundle:nil];
			break;
        
        case 3:
            storyboard = [UIStoryboard storyboardWithName:@"Notificaciones" bundle:nil];
            vc = [storyboard instantiateViewControllerWithIdentifier: @"Notificaciones"];
            break;
            
        case 4:
            storyboard = [UIStoryboard storyboardWithName:@"InstantRequest" bundle:nil];
            vc = [storyboard instantiateViewControllerWithIdentifier: @"Tasksrequests"];
            break;
            
        case 5:
            storyboard = [UIStoryboard storyboardWithName:@"UserProfile" bundle:nil];
            vc = [storyboard instantiateViewControllerWithIdentifier: @"UserProfile"];
            break;
			
		/*case 3:
			[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
			[[SlideNavigationController sharedInstance] popToRootViewControllerAnimated:YES];
			return;
			break;*/
	}
	
	[[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:vc
															 withSlideOutAnimation:self.slideOutAnimationEnabled
																	 andCompletion:nil];
}

@end