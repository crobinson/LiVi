//
//  ComprarViewController.m
//  Fluie
//
//  Created by Carlos Robinson on 12/12/15.
//  Copyright © 2015 Carlos Robinson. All rights reserved.
//

#import "ComprarViewController.h"
#import "MBProgressHUD.h"
#import <Parse/Parse.h>


@interface ComprarViewController () {
    IBOutlet UIWebView *mywebview;
    NSMutableData *responseData;
}

@end

@implementation ComprarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // TODO: Switch this URL to your own authenticated API
    NSURL *clientTokenURL = [NSURL URLWithString:@"http://liviapp.co/checkout.php?client_token=Zkdjs"];
    NSMutableURLRequest *clientTokenRequest = [NSMutableURLRequest requestWithURL:clientTokenURL];
    //[clientTokenRequest setValue:@"text/plain" forHTTPHeaderField:@"Accept"];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:clientTokenRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // TODO: Handle errors
        
        NSString *responsestring = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding];
        NSLog(@"response %@",responsestring);
        
        NSDictionary *arrayresponse = [[NSJSONSerialization JSONObjectWithData:data options:0 error: NULL] mutableCopy];
        
        NSString *clientToken = arrayresponse[@"client_token"];
        NSLog(@"client token %@", clientToken);
        //self.braintreeClient = [[BTAPIClient alloc] initWithAuthorization:clientToken];
        // As an example, you may wish to present our Drop-in UI at this point.
        // Continue to the next section to learn more...
        
        
        self.braintreeClient = [[BTAPIClient alloc] initWithAuthorization:clientToken];
        //[self tappedMyPayButton];
        /*BTPaymentButton *button = [[BTPaymentButton alloc] initWithAPIClient:self.braintreeClient
                                                                  completion:^(BTPaymentMethodNonce *paymentMethodNonce, NSError *error) {
                                                                      //[self hideLoadingUI:nil];
                                                                      [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification
                                                                                                                    object:nil];
                                                                      
                                                                      if (paymentMethodNonce) {
                                                                          // Send the nonce to your server for processing.
                                                                          NSLog(@"Got a nonce: %@", paymentMethodNonce.nonce);
                                                                      } else if (error) {
                                                                          // Tokenization failed; check `error` for the cause of the failure.
                                                                          NSLog(@"Error: %@", error);
                                                                      } else {
                                                                          // User canceled.
                                                                      }
                                                                  }];
        // Example: Customize frame, or use Auto Layout.
        button.frame = CGRectMake(10, 100, 300, 44);
        button.viewControllerPresentingDelegate = self;
        button.appSwitchDelegate = self; // Optional
        [self.view addSubview:button];*/
        
    }] resume];
    
    /*NSURL *url = [NSURL URLWithString:@"http://liviapp.co/mobilestream.php"];
    responseData = [NSMutableData data];
    NSURLRequest *request1 = [NSURLRequest requestWithURL:url];
    [mywebview loadRequest:request1];*/
    
}

-(void)viewDidAppear:(BOOL)animated{

    PFUser *currentUser = [PFUser currentUser];
    NSLog(@"%@", currentUser);
    if(currentUser[@"authorized"]){
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)cancelar:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)tappedMyPayButton:(id)sender{

    
    // If you haven't already, create and retain a `BTAPIClient` instance with a tokenization
    // key or a client token from your server.
    // Typically, you only need to do this once per session.
    //self.braintreeClient = [[BTAPIClient alloc] initWithAuthorization:CLIENT_AUTHORIZATION];
    
    // Create a BTDropInViewController
    BTDropInViewController *dropInViewController = [[BTDropInViewController alloc]
                                                    initWithAPIClient:self.braintreeClient];
    dropInViewController.delegate = self;
    
    // This is where you might want to customize your view controller (see below)
    
    // The way you present your BTDropInViewController instance is up to you.
    // In this example, we wrap it in a new, modally-presented navigation controller:
    UIBarButtonItem *item = [[UIBarButtonItem alloc]
                             initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                             target:self
                             action:@selector(userDidCancelPayment)];
    dropInViewController.navigationItem.leftBarButtonItem = item;
    UINavigationController *navigationController = [[UINavigationController alloc]
                                                    initWithRootViewController:dropInViewController];
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)userDidCancelPayment {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// Implement BTDropInViewControllerDelegate ...

- (void)dropInViewController:(BTDropInViewController *)viewController
  didSucceedWithTokenization:(BTPaymentMethodNonce *)paymentMethodNonce {
    // Send payment method nonce to your server for processing
    [self postNonceToServer:paymentMethodNonce.nonce];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dropInViewControllerDidCancel:(__unused BTDropInViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)postNonceToServer:(NSString *)paymentMethodNonce {
    // Update URL with your server
    NSURL *paymentURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://liviapp.co/checkout.php?mobile=true&amount=subscription&client=%@", [PFUser currentUser].objectId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:paymentURL];
    request.HTTPBody = [[NSString stringWithFormat:@"payment_method_nonce=%@", paymentMethodNonce] dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPMethod = @"POST";
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // TODO: Handle success and failure
        NSString *responsestring = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding];
        NSLog(@"response %@",responsestring);
        
        NSDictionary *arrayresponse = [[NSJSONSerialization JSONObjectWithData:data options:0 error: NULL] mutableCopy];
        
        if(![arrayresponse[@"status"] isEqualToString:@"failed"]){
            PFUser *currentUser = [PFUser currentUser];
            currentUser[@"authorized"] = @"SI";
            [currentUser saveInBackground];
            [[PFUser currentUser] fetch]; //synchronous
            [self dismissViewControllerAnimated:YES completion:nil];
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Livi"
                                                            message: @"Your payment was declined"
                                                           delegate: self
                                                  cancelButtonTitle: @"OK"
                                                  otherButtonTitles: nil];
            [alert show];
        }
        
    }] resume];
}
@end
