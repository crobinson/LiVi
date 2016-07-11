//
//  ComprarViewController.m
//  Fluie
//
//  Created by Carlos Robinson on 12/12/15.
//  Copyright © 2015 Carlos Robinson. All rights reserved.
//

#import "ComprarViewController.h"
#import "MBProgressHUD.h"
#import "CreditCardViewController.h"

@interface ComprarViewController ()
{
    NSArray *dataSource;
    NSArray *espacioArray;
    NSArray *userArray;
    NSMutableDictionary *beneficiario;
    NSDictionary *diccionarioSelected;
    NSString *language_id;
}
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (strong, nonatomic) MBProgressHUD *progressHUD;
@property (nonatomic, strong, readwrite) PayPalConfiguration *payPalConfiguration;
@property (weak, nonatomic) IBOutlet UIButton *cancel;

@end

@implementation ComprarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    language_id = @"1";
    _myTableView.backgroundColor = [UIColor clearColor];
    _myTableView.separatorColor = [UIColor clearColor];
    _myTableView.delegate = self;
    _myTableView.dataSource = self;
    self.myTableView.separatorColor = [UIColor clearColor];
    
    _payPalConfiguration = [[PayPalConfiguration alloc] init];
    
    // See PayPalConfiguration.h for details and default values.
    // Should you wish to change any of the values, you can do so here.
    // For example, if you wish to accept PayPal but not payment card payments, then add:
    _payPalConfiguration.acceptCreditCards = YES;
    // Or if you wish to have the user choose a Shipping Address from those already
    // associated with the user's PayPal account, then add:
    _payPalConfiguration.payPalShippingAddressOption = PayPalShippingAddressOptionPayPal;
    
    _payPalConfiguration.merchantName = @"Awesome Shirts, Inc.";
    _payPalConfiguration.merchantPrivacyPolicyURL = [NSURL URLWithString:@"https://www.paypal.com/webapps/mpp/ua/privacy-full"];
    _payPalConfiguration.merchantUserAgreementURL = [NSURL URLWithString:@"https://www.paypal.com/webapps/mpp/ua/useragreement-full"];
    _payPalConfiguration.languageOrLocale = [NSLocale preferredLanguages][0];
    _payPalConfiguration.payPalShippingAddressOption = PayPalShippingAddressOptionPayPal;
    
    NSLog(@"PayPal iOS SDK version: %@", [PayPalMobile libraryVersion]);

    [self getdataSource];
    
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
    language_id = @"1";
    if([language rangeOfString:@"es"].location == NSNotFound) {
        language_id = @"2";
        [_cancel setTitle:@"Cancel" forState:UIControlStateNormal];
    }
    // Start out working with the test environment! When you are ready, switch to PayPalEnvironmentProduction.
    [PayPalMobile preconnectWithEnvironment:PayPalEnvironmentNoNetwork];
}

-(void)getdataSource {
    
    if (_progressHUD == nil)
    {
        _progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
    }
    
    
}


- (void) hideProgressHUD
{
    if (_progressHUD)
    {
        [_progressHUD hide:YES];
        [_progressHUD removeFromSuperview];
        _progressHUD = nil;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)cancelar:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 56;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if ( cell == nil ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    
    NSMutableDictionary *diccionario = [dataSource[indexPath.row] mutableCopy];
    
    UILabel *nombre = (UILabel *)[cell viewWithTag:101];
    nombre.text = diccionario[@"name"];
    
    UILabel *espacio = (UILabel *)[cell viewWithTag:102];
    espacio.text = diccionario[@"space_name"];
    
    UILabel *precio = (UILabel *)[cell viewWithTag:103];
    precio.text = [NSString stringWithFormat:@"$ %@",diccionario[@"price"]];
    
    UILabel *texto = (UILabel *)[cell viewWithTag:104];
    NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
    if([language rangeOfString:@"es"].location == NSNotFound) {
        texto.text = @"Buy space";
    }
    
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[self performSegueWithIdentifier:@"creditcard" sender:nil];
    diccionarioSelected = dataSource[indexPath.row];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self payWithDictionary:diccionarioSelected];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)payWithDictionary:(NSDictionary *)diccionario  {
    
    // Create a PayPalPayment
    PayPalPayment *payment = [[PayPalPayment alloc] init];
    
    // Amount, currency, and description
    payment.amount = [[NSDecimalNumber alloc] initWithString:[NSString stringWithFormat:@"%@", diccionario[@"price"]]];
    //payment.amount = [[NSDecimalNumber alloc] initWithString:[NSString stringWithFormat:@"0.1"]];
    payment.currencyCode = @"USD";
    payment.shortDescription = diccionario[@"name"];
    
    
    
    // Use the intent property to indicate that this is a "sale" payment,
    // meaning combined Authorization + Capture.
    // To perform Authorization only, and defer Capture to your server,
    // use PayPalPaymentIntentAuthorize.
    // To place an Order, and defer both Authorization and Capture to
    // your server, use PayPalPaymentIntentOrder.
    // (PayPalPaymentIntentOrder is valid only for PayPal payments, not credit card payments.)
    payment.intent = PayPalPaymentIntentSale;
    
    // If your app collects Shipping Address information from the customer,
    // or already stores that information on your server, you may provide it here.
    //payment.shippingAddress = @"blabla"; // a previously-created PayPalShippingAddress object
    
    // Several other optional fields that you can set here are documented in PayPalPayment.h,
    // including paymentDetails, items, invoiceNumber, custom, softDescriptor, etc.
    
    // Check whether payment is processable.
    /*if (!payment.processable) {
        // If, for example, the amount was negative or the shortDescription was empty, then
        // this payment would not be processable. You would want to handle that here.
    }*/
    
    PayPalPaymentViewController *paymentViewController;
    paymentViewController = [[PayPalPaymentViewController alloc] initWithPayment:payment
                                                                   configuration:self.payPalConfiguration
                                                                        delegate:self];
    
    // Present the PayPalPaymentViewController.
    [self presentViewController:paymentViewController animated:YES completion:nil];
}

#pragma mark - PayPalPaymentDelegate methods

- (void)payPalPaymentViewController:(PayPalPaymentViewController *)paymentViewController
                 didCompletePayment:(PayPalPayment *)completedPayment {
    // Payment was processed successfully; send to server for verification and fulfillment.
    [self verifyCompletedPayment:completedPayment];
    
    // Dismiss the PayPalPaymentViewController.
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)payPalPaymentDidCancel:(PayPalPaymentViewController *)paymentViewController {
    // The payment was canceled; dismiss the PayPalPaymentViewController.
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)verifyCompletedPayment:(PayPalPayment *)completedPayment {
    if (_progressHUD == nil)
    {
        _progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
    }
    // Send the entire confirmation dictionary
    NSData *confirmation = [NSJSONSerialization dataWithJSONObject:completedPayment.confirmation
                                                           options:0
                                                             error:nil];
    
     NSDictionary *arrayresponsePayPal = [[NSJSONSerialization JSONObjectWithData:confirmation options:0 error: NULL] mutableCopy];
    
    NSLog(@"%@", arrayresponsePayPal);
    NSLog(@"%@", diccionarioSelected);
    
    /*
     Payment state. Must be set to one of the one of the following: created; approved; failed; canceled; expired; pending. 
     */
    
    NSString *statestring = arrayresponsePayPal[@"response"][@"state"];
    NSString *confirm_buy = @"";
    
    if([statestring isEqualToString:@"created"]) {
        confirm_buy = @"2";
    }else if([statestring isEqualToString:@"approved"]) {
        confirm_buy = @"1";
    }else if([statestring isEqualToString:@"failed"]) {
        confirm_buy = @"3";
    }else
        confirm_buy = @"0";
    
    /*
     [2/1/16, 2:02:52 PM] Dayron Garzón: user_id
     [2/1/16, 2:02:54 PM] Dayron Garzón: space_id
     [2/1/16, 2:03:00 PM] Dayron Garzón: reference
     [2/1/16, 2:03:08 PM] Dayron Garzón: payments_platform_id
     */
    
    NSLog(@"%@", confirm_buy);
    
    NSString *urlFreeSpaceString = [NSString stringWithFormat:@"http://mentesweb.com/fluie/programacion/user/buy/"];
    NSMutableURLRequest *requestFS = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString: urlFreeSpaceString]];
    //[_params setObject:statestring forKey:@"log"];
    NSString *myRequestString = [NSString stringWithFormat:@"user_id=%@&payments_platform_id=2&confirm_buy=%@&space_id=%@&reference=%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"idUser"], confirm_buy, [NSString stringWithFormat:@"%@", diccionarioSelected[@"idspace"]], arrayresponsePayPal[@"response"][@"id"]];
    NSLog(@"requeststring: %@", myRequestString);
    NSData *myRequestData = [NSData dataWithBytes: [myRequestString UTF8String] length: [myRequestString length]];
    [requestFS setHTTPMethod: @"POST"];
    [requestFS addValue:@"Basic YWRtaW46YWRtaW4=" forHTTPHeaderField:@"Authorization"];
    [requestFS setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [requestFS setHTTPBody: myRequestData];
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    
    
    // Send confirmation to your server; your server should verify the proof of payment
    // and give the user their goods or services. If the server is not reachable, save
    // the confirmation and try again later.
}

@end
