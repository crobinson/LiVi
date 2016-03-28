//
//  DemoFeature.h
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
#import <Foundation/Foundation.h>

@interface DemoFeature : NSObject

@property (nonatomic, copy) NSString *displayName;
@property (nonatomic, copy) NSString *detailText;
@property (nonatomic, copy) NSString *icon;
@property (nonatomic, copy) NSString *storyboard;

- (instancetype)initWithName:(NSString *)name
                      detail:(NSString *)detail
                        icon:(NSString *)icon
                  storyboard:(NSString *)storyboard;

@end