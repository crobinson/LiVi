//
//  MyMoneyViewController.m
//  Livi
//
//  Created by Carlos Robinson on 7/5/16.
//  Copyright © 2016 livi. All rights reserved.
//

#import "MyMoneyViewController.h"
#import <Parse/Parse.h>

@interface MyMoneyViewController (){
    NSMutableArray *dataSource;
    UIImage *croppedImg;
}

@end

@implementation MyMoneyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    dataSource = [[NSMutableArray alloc] init];
    
    NSDictionary *dataDictionary = @{
                                     @"title"   : @"Earnings",
                                     @"image"   : @"coins.png",
                                     };
    
    [dataSource addObject:dataDictionary];
    
    NSDictionary *dataDictionary2 = @{
                                     @"title"   : @"Redeem",
                                     @"image"   : @"redeem.png",
                                     };
    
    [dataSource addObject:dataDictionary2];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    UIImageView *_miiconView = (UIImageView *)[cell viewWithTag:100];
    
    if(indexPath.row==0)
        _miiconView.frame = CGRectMake(_miiconView.frame.origin.x, _miiconView.frame.origin.y, 35, 37);
    else
        _miiconView.frame = CGRectMake(_miiconView.frame.origin.x, _miiconView.frame.origin.y, 49, 33);
    
    UILabel *nombre = (UILabel *)[cell viewWithTag:102];
    
    _miiconView.image = [UIImage imageNamed:obj[@"image"]];
    nombre.text = obj[@"title"];
    
    return cell;
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

@end
