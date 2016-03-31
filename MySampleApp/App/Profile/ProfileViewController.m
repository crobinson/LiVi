//
//  ProfileViewController.m
//  Livi
//
//  Created by Carlos Robinson on 3/31/16.
//  Copyright © 2016 Amazon. All rights reserved.
//

#import "ProfileViewController.h"
#import "AWSIdentityManager.h"

@interface ProfileViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *profilePic;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTxt;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;
@property (weak, nonatomic) IBOutlet UILabel *nameLbl;
@property (weak, nonatomic) IBOutlet UILabel *mailLbl;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.nextBtn.layer.cornerRadius = 10;
    // Do any additional setup after loading the view.
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
