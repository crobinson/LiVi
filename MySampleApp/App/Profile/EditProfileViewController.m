//
//  EditProfileViewController.m
//  Livi
//
//  Created by Carlos Robinson on 6/27/16.
//  Copyright © 2016 livi. All rights reserved.
//

#import "EditProfileViewController.h"
#import <Parse/Parse.h>
#import "MBProgressHUD.h"
#import "UIImage+Resize.h"

@interface EditProfileViewController () {
    BOOL isPhotoSelected;
    NSData *pictureData;
    MBProgressHUD *hud;
    UITextView *_mytextview;
    UITextField *_mytextfield;
    IBOutlet UILabel *_tooltip;
    IBOutlet UIButton *savebutton;
}

@property (weak, nonatomic) IBOutlet UIView *pic;
@property (weak, nonatomic) IBOutlet UIImageView *profilePic2;
@property (weak, nonatomic) IBOutlet UIButton *addphoto;
@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UITextView *profileDesc;
@property (weak, nonatomic) IBOutlet UIButton *save;
@property (weak, nonatomic) IBOutlet UIScrollView *myscroll;
@property (strong, nonatomic) MBProgressHUD *progressHUD;

@end

@implementation EditProfileViewController

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
    // Do any additional setup after loading the view.
    //[Parse setApplicationId:@"BsIBfZnR1xUg1ZY9AwGcd3iKtqrMPu2zUTjP49ta" clientKey:@"E2od7oEslPMj6C2yG9GnWXvC9qDicnTNgcDgN9xm"];
    NSLog(@"%@", _croppedImage);
    self.profilePic2.image = _croppedImage;
    self.name.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.name.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    self.email.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.email.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    self.name.text  = self.nameString;
    self.email.text = self.emailString;
    _tooltip.text = @"";
    self.profileDesc.text = [PFUser currentUser][@"description"];
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
-(void)dismissKeyboard {
    if(_mytextfield!=nil)
        [_mytextfield resignFirstResponder];
    
    if(_mytextview!=nil)
        [_mytextview resignFirstResponder];
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
    [picker dismissViewControllerAnimated:YES completion:nil];
    //Place the image in the imageview
    
    UIImage *scaledImage = [img resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:self.profilePic2.bounds.size interpolationQuality:kCGInterpolationHigh];
    // Crop the image to a square (yikes, fancy!)
    UIImage *croppedImage = [scaledImage croppedImage:CGRectMake((scaledImage.size.width -self.profilePic2.frame.size.width)/2, (scaledImage.size.height -self.profilePic2.frame.size.height)/2, self.profilePic2.frame.size.width, self.profilePic2.frame.size.height)];
    
    self.profilePic2.image = croppedImage;
    
    pictureData = UIImagePNGRepresentation(img);
    NSString* imagePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"/saved_example_image.png"];
    [pictureData writeToFile:imagePath atomically:YES];
}

#pragma mark UITextField

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    _mytextfield = textField;
    [self.myscroll setContentSize:CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height+153)];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.50];
    [UIView setAnimationDelegate:self];
    
    [self.myscroll setContentOffset:CGPointMake(0, textField.frame.origin.y - 150) animated:YES];
    
    
        self.view.frame = CGRectMake(0, 0 - textField.frame.origin.y + 100 , self.view.frame.size.width, self.view.frame.size.height);
    
    
    
    [UIView commitAnimations];
    
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    /* if (textField == _Username_TextField) {
     [_Username_TextField resignFirstResponder];
     [_password_TextField becomeFirstResponder];
     } else if (textField == _password_TextField) {*/
    // here you can define what happens
    // when user presses return on the email field
    [textField resignFirstResponder];
    [self.myscroll setContentSize:CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height-153)];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.50];
    [UIView setAnimationDelegate:self];
    
    [self.myscroll setContentOffset:CGPointMake(0, 0) animated:YES];
    
        self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    
    [UIView commitAnimations];
    
    
    // }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    _mytextfield = nil;
}


- (void)textViewDidBeginEditing:(UITextView *)textView{
    _tooltip.text = @"";
    [self.myscroll setContentSize:CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height+253)];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.50];
    [UIView setAnimationDelegate:self];
    
    [self.myscroll setContentOffset:CGPointMake(0, textView.frame.origin.y - 150) animated:YES];
    
    [UIView commitAnimations];
    
    _mytextview = textView;
    
}
-(void)textViewDidEndEditing:(UITextView *)textView{
    if ([textView.text isEqualToString:@""]) {
        _tooltip.text = @"Add description";
    }
    _mytextview = nil;
    [self.myscroll setContentSize:CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height-153)];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.50];
    [UIView setAnimationDelegate:self];
    
    [self.myscroll setContentOffset:CGPointMake(0, 0) animated:YES];
    
    [UIView commitAnimations];
}

-(IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)onsave:(id)sender {
    if (_progressHUD == nil)
    {
        _progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    PFUser *user = [PFUser currentUser];
    user.email = _email.text;
    user[@"description"] = _profileDesc.text;
    [user saveInBackground];
    [self hideProgressHUD];
    if(isPhotoSelected==YES){
        NSData *picData = UIImageJPEGRepresentation(self.profilePic2.image, 0.5);
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
        
        
    }
    

}
@end
