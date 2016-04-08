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


@interface ProfileViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *profilePic;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTxt;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;
@property (weak, nonatomic) IBOutlet UILabel *nameLbl;
@property (weak, nonatomic) IBOutlet UILabel *mailLbl;
@property (weak, nonatomic) UITextView *usrTextView;
@property (weak, nonatomic) IBOutlet UIScrollView *myscroll;
@property (strong, nonatomic) MBProgressHUD *progressHUD;

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
    self.nextBtn.layer.cornerRadius = 10;
    // Do any additional setup after loading the view.
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}

-(void)dismissKeyboard {
    if(_usrTextView!=nil)
        [_usrTextView resignFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    AWSIdentityManager *identityManager = [AWSIdentityManager sharedInstance];
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
        self.profilePic.image = [UIImage imageNamed:@"UserIcon"];
    }
    
    self.profilePic.layer.masksToBounds = YES;
    // border radius
    [self.profilePic.layer setCornerRadius:68.0f];
    
    AWSCognito *syncClient = [AWSCognito defaultCognito];
    AWSCognitoDataset *userSettings = [syncClient openOrCreateDataset:@"user_settings"];
    
    if([userSettings stringForKey:@"Description"]){
        _tooltip.text = @"";
        _descriptionTxt.text = [userSettings stringForKey:@"Description"];
    }
    
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
        assert(false);
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
    if (_progressHUD == nil)
    {
        _progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    
    AWSCognito *syncClient = [AWSCognito defaultCognito];
    AWSCognitoDataset *userSettings = [syncClient openOrCreateDataset:@"user_settings"];
    
    
    [userSettings setString:[NSString stringWithFormat:@"%@", _descriptionTxt.text]
                     forKey:@"Description"];
    [[userSettings synchronize] continueWithExceptionCheckingBlock:^(id result, NSError *error) {
        if (!result) {
            AWSLogError(@"saveSettings AWS task error: %@", [error localizedDescription]);
        }
        
        [self hideProgressHUD];
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
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

@end
