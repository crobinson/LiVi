//
//  CouponsViewController.m
//  Livi
//
//  Created by Carlos Robinson on 4/27/16.
//  Copyright © 2016 livi. All rights reserved.
//

#import "CouponsViewController.h"
#import <Parse/Parse.h>
#import "MBProgressHUD.h"
#import "UIImage+Resize.h"
#import "SlideNavigationController.h"
#import "CouponsMenuViewController.h"

@interface CouponsViewController (){
    __weak IBOutlet UIPageControl *pagecontroll;
    __weak IBOutlet UIScrollView *myscroll;
    NSMutableArray *dataSource;
    BOOL isPhotoSelected;
    NSData *pictureData;
    MBProgressHUD *hud;
    
}

@property (strong, nonatomic) MBProgressHUD *progressHUD;

@end

@implementation CouponsViewController

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
    dataSource = [[NSMutableArray alloc] init];
    
    [SlideNavigationController sharedInstance].portraitSlideOffset = self.view.frame.size.width - 262;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CouponsMenuViewController *rightMenu = [storyboard instantiateViewControllerWithIdentifier:@"CouponsMenuViewController"];
    [SlideNavigationController sharedInstance].rightMenu = rightMenu;
    
    [myscroll setScrollEnabled:YES];
    [myscroll setUserInteractionEnabled:YES];
    [myscroll setDelegate:self];
    [myscroll setPagingEnabled:YES];
    [myscroll setContentSize:CGSizeMake(3372, 290)];

    
}

- (void) viewDidAppear:(BOOL)animated {

    [self getDataSource];
    
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu
{
    return YES;
}

- (IBAction)onRightBtnMenu:(id)sender {
    [[SlideNavigationController sharedInstance] righttMenuSelected:self];
}

- (void)getDataSource {
    
    if (_progressHUD == nil)
    {
        _progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    
    [dataSource removeAllObjects];
    
    PFQuery *querySuscription = [PFQuery queryWithClassName:@"CouponsSubscriptions"];
    [querySuscription whereKey:@"userId" equalTo:[PFUser currentUser].objectId];
    NSArray *CouponsSubscriptions = [querySuscription findObjects];
    
    if(CouponsSubscriptions.count==0){
        UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Coupons" message:@"You dont have subscriptions to any coupons." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [errorAlertView show];
    }else{
        PFQuery *query = [PFQuery queryWithClassName:@"Coupons"];
        [query whereKey:@"objectId" equalTo:[[CouponsSubscriptions objectAtIndex:0] objectForKey:@"couponId"]];
        NSArray *coupons = [query findObjects];
        myscroll.contentSize = CGSizeMake(myscroll.frame.size.width * coupons.count, myscroll.frame.size.height);
        int counter = 0;
        
        
        for (PFObject *userObj in coupons) {
            NSLog(@"%f", myscroll.frame.size.width);
            UIView * contenview =  [[UIView alloc] initWithFrame:CGRectMake(myscroll.frame.size.width *counter, 0, 250, myscroll.frame.size.height)];
            
            UIImageView *subview = [[UIImageView alloc] initWithFrame:CGRectMake(myscroll.frame.size.width *counter, 0, 250, myscroll.frame.size.height)];
            
            PFFile *imagePf = (PFFile *)[userObj objectForKey:@"image"];
            UIImage *image = [UIImage imageWithData:imagePf.getData];
            subview.image = image;
            
            CGSize imageSize = image.size;
            CGSize imageViewSize = subview.frame.size;
            
            float imageRatio = imageSize.width / imageSize.height;
            float viewRatio = imageViewSize.width / imageViewSize.height;
            float scale;
            
            if(imageRatio > viewRatio){
                scale = imageSize.width / imageViewSize.width;
            }else{
                scale = imageSize.height / imageViewSize.height;
            }
            
            CGRect frame = CGRectZero;
            
            frame.size = CGSizeMake(roundf(imageSize.width / scale), roundf(imageSize.height / scale));
            frame.origin = CGPointMake((imageViewSize.width - frame.size.width) / 2.0, (imageViewSize.height - frame.size.height) / 2.0);
            
            [subview setFrame:frame];
            [contenview addSubview:subview];
            [myscroll addSubview:contenview];
            counter = counter + 1;
        }
    }
    
    [self hideProgressHUD];
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

- (IBAction)onBtnTakePhoto:(id)sender {
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
    [pickerController setAllowsEditing:YES];
    [pickerController setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    
    [self presentViewController:pickerController animated:YES completion:^{}];
    //}
    
}

-(void)takePhoto {
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.delegate = self;
    [pickerController setAllowsEditing:YES];
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
    
    pictureData = UIImagePNGRepresentation(img);
    
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        //[currentUser addObject:_descriptionTxt.text forKey:@"description"];
        NSData *picData = pictureData;
        PFFile *file = [PFFile fileWithName:@"img" data:picData];
        
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"Uploading Image";
        
        [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            if (succeeded){
                
                //2
                //Add the image to the object, and add the comment and the user
                PFObject *imageObject = [PFObject objectWithClassName:@"Coupons"];
                [imageObject setObject:file forKey:@"image"];
                [imageObject setObject:[PFUser currentUser].objectId forKey:@"userId"];
                
                //3
                [imageObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    //4
                    if (succeeded){
                        //Go back to the wall
                        UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Coupons" message:@"Coupon uploaded" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                        [errorAlertView show];
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
- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return YES;
}

-(IBAction)back:(id)sender {
    //[self.navigationController popViewControllerAnimated:YES];
    [[SlideNavigationController sharedInstance] leftMenuSelected:self];
}

@end
