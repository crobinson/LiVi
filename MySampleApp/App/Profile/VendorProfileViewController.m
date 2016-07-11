//
//  VendorProfileViewController.m
//  Livi
//
//  Created by Carlos Robinson on 6/30/16.
//  Copyright © 2016 livi. All rights reserved.
//

#import "VendorProfileViewController.h"
#import "AWSIdentityManager.h"
#import <AWSCognito/AWSCognitoSyncService.h>
#import "AWSConfiguration.h"
#import "AWSIdentityManager.h"
#import "AWSTask+CheckExceptions.h"
#import <AWSCore/AWSCore.h>
#import "MBProgressHUD.h"
#import <Parse/Parse.h>
#import "UIImage+Resize.h"
#import "EditProfileViewController.h"

@interface VendorProfileViewController () {
    BOOL isPhotoSelected;
    NSData *pictureData;
    MBProgressHUD *hud;
}

@property (weak, nonatomic) IBOutlet UIImageView *profilePic;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTxt;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;
@property (weak, nonatomic) IBOutlet UILabel *nameLbl;
@property (weak, nonatomic) IBOutlet UILabel *mailLbl;
@property (weak, nonatomic) UITextView *usrTextView;
@property (weak, nonatomic) IBOutlet UIScrollView *myscroll;
@property (strong, nonatomic) MBProgressHUD *progressHUD;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLcl;
@property (weak, nonatomic) IBOutlet UIImageView *profilePic2;
@property (weak, nonatomic) IBOutlet UITableView *mytableView;
@property (weak, nonatomic) IBOutlet UILabel *adress;
@property (weak, nonatomic) IBOutlet UILabel *phone;
@property (weak, nonatomic) IBOutlet UILabel *hours;


@end

@implementation VendorProfileViewController

@synthesize currentUser;

- (void) hideProgressHUD
{
    if (_progressHUD)
    {
        [_progressHUD hide:YES];
        [_progressHUD removeFromSuperview];
        _progressHUD = nil;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
        if(pictureData){
            UIImage *profileImage = [UIImage imageWithData:pictureData];
            self.profilePic.image = profileImage;
        }else{
            self.profilePic.image = [UIImage imageNamed:@"avatarm.PNG"];
        }
    
        if (currentUser) {
            // do stuff with the user
            NSLog(@"%@", currentUser);
            if (currentUser[@"firstname"]) {
                self.nameLbl.text = [NSString stringWithFormat:@"%@ %@", currentUser[@"firstname"], currentUser[@"lastname"]];
            }
            if(currentUser[@"description"]) {
                self.descriptionLcl.text = currentUser[@"description"];
            }
            self.mailLbl.text = currentUser[@"username"];
            if(currentUser[@"description"]){
                _tooltip.text = @"";
                _descriptionTxt.text = currentUser[@"description"];
            }
            if(currentUser[@"phone"]) {
                self.phone.text = currentUser[@"phone"];
            }
            
            PFGeoPoint *geopoint = (PFGeoPoint *)[currentUser objectForKey:@"location"];
            
            NSString *urlString = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?latlng=%f,%f&amp;sensor=false",geopoint.latitude,geopoint.longitude];
            
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
            
            NSURLResponse *response = nil;
            NSError * error = nil;
            NSError *requestError = nil;
            NSData *responseData = [NSURLConnection sendSynchronousRequest:request
                                                         returningResponse:&response
                                                                     error:&error];
            
            NSString *responseString = [[NSString alloc] initWithData: responseData encoding:NSUTF8StringEncoding];
            NSDictionary *responseJson = [NSJSONSerialization JSONObjectWithData: responseData options: 0 error: &error];
            
            if ([responseJson[@"status"] isEqualToString:@"OK"] ) {
                //NSLog(@"responseString %@  %@",[[responseJson valueForKey:@"results"] objectAtIndex:0]);
                NSArray *resultsArray = [responseJson valueForKey:@"results"];
                NSString *address = nil;
                
                if ([resultsArray count] > 0) {
                    address = [[resultsArray objectAtIndex:0] valueForKey:@"formatted_address"];
                    NSLog(@"adress: %@", address);
                    self.adress.text = [NSString stringWithFormat:@"Address: %@", address];
                }
                
                // use the address variable to access the ADDRESS :)
            } else {
                
            }
            
        } else {
            // show the signup or login screen
        }
        
    
    
    
    //if(!isPhotoSelected)
    
    
    
    
    self.profilePic.layer.masksToBounds = YES;
    // border radius
    [self.profilePic.layer setCornerRadius:68.0f];
    
    
}

- (IBAction)onFollow:(id)sender{
    
    PFQuery *query = [PFUser query];
    [query whereKeyExists:@"Followers"];
    [query whereKey:@"userId" notEqualTo:[PFUser currentUser].objectId];
    NSArray *followarray = [query findObjects];
    
    if(!followarray.count){
        PFObject *followObject = [PFObject objectWithClassName:@"Followers"];
        [followObject setObject:[PFUser currentUser].objectId forKey:@"userId"];
        [followObject setObject:currentUser.objectId forKey:@"following"];
        [followObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            //4
            if (succeeded){
                //Go back to the wall
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Following!!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                
                [alertView show];
                
            }
        }];
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Success" message:@"You are already following this Partner business!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        
        [alertView show];

    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [Parse setApplicationId:@"BsIBfZnR1xUg1ZY9AwGcd3iKtqrMPu2zUTjP49ta" clientKey:@"E2od7oEslPMj6C2yG9GnWXvC9qDicnTNgcDgN9xm"];
    self.nextBtn.layer.cornerRadius = 10;
    [self getUserImage];
    // Do any additional setup after loading the view.
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    float sizeOfContent = 0;
    UIView *lLast = [_myscroll.subviews lastObject];
    NSInteger wd = lLast.frame.origin.y;
    NSInteger ht = lLast.frame.size.height;
    sizeOfContent = wd+ht;
    NSLog(@"%f", sizeOfContent);
    _myscroll.contentSize = CGSizeMake(self.view.frame.size.width, sizeOfContent+_myscroll.frame.origin.y);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)getUserImage
{
    //Prepare the query to get all the images in descending order
    //AWSIdentityManager *identityManager = [AWSIdentityManager sharedInstance];
    if ([AWSIdentityManager sharedInstance].isLoggedIn) {
        //custom
    }else{
        PFQuery *query = [PFQuery queryWithClassName:@"UserImage"];
        [query whereKey:@"user" equalTo:currentUser.username];
        [query orderByDescending:@"createdAt"];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                //Everything was correct, put the new objects and load the wall
                for (PFObject *imgObject in objects){
                    PFFile *image = (PFFile *)[imgObject objectForKey:@"image"];
                    //UIImageView *userImage = [[UIImageView alloc] initWithImage:[UIImage imageWithData:image.getData]];
                    UIImage *scaledImage = [[UIImage imageWithData:image.getData] resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:self.profilePic.bounds.size interpolationQuality:kCGInterpolationHigh];
                    // Crop the image to a square (yikes, fancy!)
                    UIImage *croppedImage = [scaledImage croppedImage:CGRectMake((scaledImage.size.width -self.profilePic.frame.size.width)/2, (scaledImage.size.height -self.profilePic.frame.size.height)/2, self.profilePic.frame.size.width, self.profilePic.frame.size.height)];
                    
                    self.profilePic.image = croppedImage;
                    
                    scaledImage = [[UIImage imageWithData:image.getData] resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:_profilePic2.bounds.size interpolationQuality:kCGInterpolationHigh];
                    // Crop the image to a square (yikes, fancy!)
                    croppedImage = [scaledImage croppedImage:CGRectMake((scaledImage.size.width -_profilePic2.frame.size.width)/2, (scaledImage.size.height -_profilePic2.frame.size.height)/2, _profilePic2.frame.size.width, _profilePic2.frame.size.height)];
                    
                    self.profilePic2.image = croppedImage;
                    
                }
            } else {
                NSString *errorString = [[error userInfo] objectForKey:@"error"];
                UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [errorAlertView show];
            }
        }];
    }
    
}

-(IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
