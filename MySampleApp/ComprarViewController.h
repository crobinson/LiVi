//
//  ComprarViewController.h
//  Fluie
//
//  Created by Carlos Robinson on 12/12/15.
//  Copyright © 2015 Carlos Robinson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BraintreeUI.h"
#import "BraintreePayPal.h"


@interface ComprarViewController : UIViewController<BTDropInViewControllerDelegate, UIWebViewDelegate, BTAppSwitchDelegate, BTViewControllerPresentingDelegate>

@property (nonatomic, strong) BTAPIClient *braintreeClient;
@property (nonatomic, strong) BTPayPalDriver *payPalDriver;

@end
