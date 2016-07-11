//
//  CreditCardViewController.m
//  Fluie
//
//  Created by Carlos Robinson on 12/12/15.
//  Copyright © 2015 Carlos Robinson. All rights reserved.
//

#import "CreditCardViewController.h"

@interface CreditCardViewController ()
@property (weak, nonatomic) IBOutlet UIButton *btn1;
@property (weak, nonatomic) IBOutlet UITextField *numero;
@property (weak, nonatomic) IBOutlet UITextField *codigo;
@property (weak, nonatomic) IBOutlet UITextField *mes;
@property (weak, nonatomic) IBOutlet UITextField *ano;

@end

@implementation CreditCardViewController

-(void) viewWillAppear:(BOOL)animated {
    NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
    if([language rangeOfString:@"es"].location == NSNotFound) {
        _numero.placeholder = @"Card number";
        _codigo.placeholder = @"Security code";
        _mes.placeholder = @"Month";
        _ano.placeholder = @"Year";
        [_btn1 setTitle:@"SAVE" forState:UIControlStateNormal];
        
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
