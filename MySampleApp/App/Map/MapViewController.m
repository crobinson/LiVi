//
//  MapViewController.m
//  Livi
//
//  Created by Carlos Robinson on 3/31/16.
//  Copyright © 2016 Amazon. All rights reserved.
//

#import "MapViewController.h"
#import "AWSIdentityManager.h"
#import <AWSCognito/AWSCognitoSyncService.h>
#import "AWSConfiguration.h"
#import "AWSTask+CheckExceptions.h"
#import <AWSCore/AWSCore.h>

@interface MapViewController ()

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated{
    [self presentProfileViewController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)presentProfileViewController {
    if ([AWSIdentityManager sharedInstance].isLoggedIn) {
        AWSCognito *syncClient = [AWSCognito defaultCognito];
        AWSCognitoDataset *userSettings = [syncClient openOrCreateDataset:@"user_settings"];
        
        if(![userSettings stringForKey:@"Description"] || [[userSettings stringForKey:@"Description"] isEqualToString:@""]){
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Profile" bundle:nil];
            UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"Profile"];
            [self presentViewController:viewController
                               animated:YES
                             completion:nil];
        }

        
    }else{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SignIn" bundle:nil];
        UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"SignIn"];
        [self presentViewController:viewController
                           animated:YES
                         completion:nil];

    }
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //return dataSource.count;
    return 9;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if(indexPath.row==0){
        return 138;
    }
    return 69;
    
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //tableView = _mytableview;
    static NSString *CellIdentifier = @"menu";
    NSLog(@"%ld",(long)indexPath.row);
    if(indexPath.row==0){
         CellIdentifier = @"header";
    }else{
        CellIdentifier = @"menu";
    }
        
    
    UITableViewCell *cell = [_menuTableView dequeueReusableCellWithIdentifier:CellIdentifier];
  
    
    if ( cell == nil ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
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
