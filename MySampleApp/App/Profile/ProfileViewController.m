//
//  ProfileViewController.m
//  Livi
//
//  Created by Carlos Robinson on 3/31/16.
//  Copyright © 2016 Amazon. All rights reserved.
//

#import "ProfileViewController.h"
#import "AWSIdentityManager.h"
#import <AWSCognito/AWSCognitoSyncService.h>
#import "AWSConfiguration.h"
#import "AWSIdentityManager.h"
#import "AWSTask+CheckExceptions.h"
#import <AWSCore/AWSCore.h>
#import "MBProgressHUD.h"
#import <Parse/Parse.h>
#import "UIImage+Resize.h"


@interface ProfileViewController ()
{
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

@end

@implementation ProfileViewController

- (void) hideProgressHUD
{
    if (_progressHUD)
    {
        [_progressHUD hide:YES];
        [_progressHUD removeFromSuperview];
        _progressHUD = nil;
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

-(void)dismissKeyboard {
    if(_usrTextView!=nil)
        [_usrTextView resignFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    AWSIdentityManager *identityManager = [AWSIdentityManager sharedInstance];
    if ([AWSIdentityManager sharedInstance].isLoggedIn) {
        NSLog(@"%@",identityManager);
        if (identityManager.userName) {
            self.nameLbl.text = identityManager.userName;
        } else {
            self.nameLbl.text = NSLocalizedString(@"GUEST USER", @"Placeholder text for the guest user.");
        }
        self.mailLbl.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"email"];
        //self.userID.text = identityManager.identityId;
        NSURL *imageUrl = identityManager.imageURL;
        
        NSData *imageData = [NSData dataWithContentsOfURL:imageUrl];
        UIImage *profileImage = [UIImage imageWithData:imageData];
        if (profileImage) {
            self.profilePic.image = profileImage;
        } else {
            self.profilePic.image = [UIImage imageNamed:@"avatarm.PNG"];
        }
        AWSCognito *syncClient = [AWSCognito defaultCognito];
        AWSCognitoDataset *userSettings = [syncClient openOrCreateDataset:@"user_settings"];
        
        if([userSettings stringForKey:@"Description"]){
            _tooltip.text = @"";
            _descriptionTxt.text = [userSettings stringForKey:@"Description"];
        }


    }else{
        
        if(pictureData){
              UIImage *profileImage = [UIImage imageWithData:pictureData];
              self.profilePic.image = profileImage;
        }else{
            self.profilePic.image = [UIImage imageNamed:@"avatarm.PNG"];
        }
        
        PFUser *currentUser = [PFUser currentUser];
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
            
        } else {
            // show the signup or login screen
        }

    }
    
    
    //if(!isPhotoSelected)
    
    
    
    
    self.profilePic.layer.masksToBounds = YES;
    // border radius
    [self.profilePic.layer setCornerRadius:68.0f];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)Logout:(id)sender {
    [self handleLogout];
}

- (void)handleLogout {
    if ([[AWSIdentityManager sharedInstance] isLoggedIn]) {
        [[AWSIdentityManager sharedInstance] logoutWithCompletionHandler:^(id result, NSError *error) {
            [self.navigationController popToRootViewControllerAnimated:NO];
            [self presentSignInViewController];
        }];

    } else {
        [PFUser logOut];
        [self.navigationController popViewControllerAnimated:NO];
        //assert(false);
    }
}

- (void)presentSignInViewController {
    if (![AWSIdentityManager sharedInstance].isLoggedIn) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SignIn" bundle:nil];
        UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"SignIn"];
        [self presentViewController:viewController
                           animated:YES
                         completion:nil];
    }
}

#pragma mark UITextView

- (void)textViewDidBeginEditing:(UITextView *)textView{
    _tooltip.text = @"";
    [self.myscroll setContentSize:CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height+253)];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.50];
    [UIView setAnimationDelegate:self];
    
    [self.myscroll setContentOffset:CGPointMake(0, textView.frame.origin.y - 150) animated:YES];
    
    [UIView commitAnimations];

  _usrTextView = textView;
    
}
-(void)textViewDidEndEditing:(UITextView *)textView{
    if ([textView.text isEqualToString:@""]) {
        _tooltip.text = @"Add description";
    }
    _usrTextView = nil;
    [self.myscroll setContentSize:CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height-153)];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.50];
    [UIView setAnimationDelegate:self];
    
    [self.myscroll setContentOffset:CGPointMake(0, 0) animated:YES];
    
    [UIView commitAnimations];
}

-(IBAction)onNext:(id)sender {
    /*if (_progressHUD == nil)
    {
        _progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }*/
    
    AWSIdentityManager *identityManager = [AWSIdentityManager sharedInstance];
    if ([AWSIdentityManager sharedInstance].isLoggedIn) {
    
        AWSCognito *syncClient = [AWSCognito defaultCognito];
        AWSCognitoDataset *userSettings = [syncClient openOrCreateDataset:@"user_settings"];
        
        
        [userSettings setString:[NSString stringWithFormat:@"%@", _descriptionTxt.text]
                         forKey:@"Description"];
        [[userSettings synchronize] continueWithExceptionCheckingBlock:^(id result, NSError *error) {
            if (!result) {
                AWSLogError(@"saveSettings AWS task error: %@", [error localizedDescription]);
            }
            //[self hideProgressHUD];
            
            [self dismissViewControllerAnimated:YES completion:nil];
            
        }];
    }
    
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        //[currentUser addObject:_descriptionTxt.text forKey:@"description"];
        currentUser[@"description"] = _descriptionTxt.text;
        [[PFUser currentUser] save];
        NSData *picData = UIImageJPEGRepresentation(self.profilePic.image, 0.5);
        PFFile *file = [PFFile fileWithName:@"img" data:picData];
        
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"Uploading Image";
        
        [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            if (succeeded){
                
                //2
                //Add the image to the object, and add the comment and the user
                PFObject *imageObject = [PFObject objectWithClassName:@"UserImage"];
                [imageObject setObject:file forKey:@"image"];
                [imageObject setObject:[PFUser currentUser].username forKey:@"user"];
                
                //3
                [imageObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    //4
                    if (succeeded){
                        //Go back to the wall
                        
                    }
                    else{
                        NSString *errorString = [[error userInfo] objectForKey:@"error"];
                        UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                        [errorAlertView show];
                    }
                }];
            }
            else{
                //5
                NSString *errorString = [[error userInfo] objectForKey:@"error"];
                UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [errorAlertView show];
            }        
        } progressBlock:^(int percentDone) {
            NSLog(@"Uploaded: %d %%", percentDone);
            if(percentDone==100){
                [hud hide:YES];
                [hud removeFromSuperview];
                hud = nil;
                [self dismissViewControllerAnimated:YES completion:nil];
            }else{
                //hud.progress = percentDone;
                hud.labelText = [NSString stringWithFormat:@"Uploaded: %d %%", percentDone];
            }
        }];
        
        [self hideProgressHUD];
    }
}

- (IBAction)onBtnTakePhoto:(id)sender {
    [self dismissKeyboard];
    UIActionSheet *actionSheetView = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Take picture" otherButtonTitles:@"Camera Roll", nil];
    
    [actionSheetView showInView:[self view]];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    }];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0: {
            [self takePhoto];
            break;
        }
        case 1: {
            [self selectPhoto];
            break;
        }
        default:
            break;
    }
}

-(void)selectPhoto {
    
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.delegate = self;
    [pickerController setAllowsEditing:NO];
    [pickerController setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    
    [self presentViewController:pickerController animated:YES completion:^{}];
    //}
    
}

-(void)takePhoto {
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.delegate = self;
    [pickerController setAllowsEditing:NO];
    [pickerController setSourceType:UIImagePickerControllerSourceTypeCamera];
    
    [self presentViewController:pickerController animated:YES completion:NULL];
    
}

/*- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    UIImage *selectedImage = info[UIImagePickerControllerOriginalImage];
    self.profilePic.image = selectedImage;
    [picker dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    }];
}*/

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)img editingInfo:(NSDictionary *)editInfo
{
    isPhotoSelected = YES;
    [picker dismissModalViewControllerAnimated:YES];
    //Place the image in the imageview
    
    UIImage *scaledImage = [img resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:self.profilePic.bounds.size interpolationQuality:kCGInterpolationHigh];
    // Crop the image to a square (yikes, fancy!)
    UIImage *croppedImage = [scaledImage croppedImage:CGRectMake((scaledImage.size.width -self.profilePic.frame.size.width)/2, (scaledImage.size.height -self.profilePic.frame.size.height)/2, self.profilePic.frame.size.width, self.profilePic.frame.size.height)];
    
    self.profilePic.image = croppedImage;
    
    pictureData = UIImagePNGRepresentation(img);
    NSString* imagePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"/saved_example_image.png"];
    [pictureData writeToFile:imagePath atomically:YES];
}

-(void)getUserImage
{
    //Prepare the query to get all the images in descending order
    AWSIdentityManager *identityManager = [AWSIdentityManager sharedInstance];
    if ([AWSIdentityManager sharedInstance].isLoggedIn) {
        //custom
    }else{
        PFQuery *query = [PFQuery queryWithClassName:@"UserImage"];
        PFUser *currentUser = [PFUser currentUser];
        [query whereKey:@"user" equalTo:currentUser.username];
        [query orderByDescending:@"createdAt"];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                //Everything was correct, put the new objects and load the wall
                for (PFObject *imgObject in objects){
                    PFFile *image = (PFFile *)[imgObject objectForKey:@"image"];
                    UIImageView *userImage = [[UIImageView alloc] initWithImage:[UIImage imageWithData:image.getData]];
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
    //return dataSource.count;
    return 6;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return 69;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"botonprofile";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    if ( cell == nil ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    UILabel *nombre = (UILabel *)[cell viewWithTag:100];
    nombre.text = @"titulo";
    
    return cell;
}



@end
