//
//  MobileAnalyticsViewController.h
//  MySampleApp
//
//
// Copyright 2016 Amazon.com, Inc. or its affiliates (Amazon). All Rights Reserved.
//
// Code generated by AWS Mobile Hub. Amazon gives unlimited permission to 
// copy, distribute and modify it.
//
// Source code generated from template: aws-my-sample-app-ios-objc v0.6
//
#import <UIKit/UIKit.h>

@interface MobileAnalyticsViewController : UIViewController

- (IBAction)clickedCustomEvent:(id)sender;
- (IBAction)clickedMonetizationEvent:(id)sender;
+ (NSString*)prettyPrintEvent:(id<AWSMobileAnalyticsEvent>)event;

@end