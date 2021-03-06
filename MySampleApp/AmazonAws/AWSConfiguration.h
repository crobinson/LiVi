//
// AWSConfiguration.h
//
//
// Copyright 2016 Amazon.com, Inc. or its affiliates (Amazon). All Rights Reserved.
//
// Code generated by AWS Mobile Hub. Amazon gives unlimited permission to 
// copy, distribute and modify it.
//
// Source code generated from template: aws-my-sample-app-ios-objc v0.6
//
#import <AWSCore/AWSCore.h>
#import <AWSCognito/AWSCognito.h>

// AMAZON COGNITO
#define AMAZON_COGNITO_REGION AWSRegionUSEast1
#define AMAZON_COGNITO_IDENTITY_POOL_ID @"us-east-1:7ed3e37f-ae3f-4184-9eb9-f1d690b77f21"
// AMAZON MOBILE ANALYTICS
#define AMAZON_MOBILE_ANALYTICS_APP_ID @"239152c680af46a1a05a8e3db0ab5d4d"
// CONTENT DELIVERY
#define AWS_CONTENT_MANAGER_S3_BUCKET_NAME @"livi-contentdelivery-mobilehub-2026985135"
#define AWS_CONTENT_MANAGER_CLOUD_FRONT_DOMAIN @"dty606ak3ltc7.cloudfront.net"
#define AWS_CONTENT_MANAGER_CLOUD_FRONT_ORIGIN_S3 @"livi-contentdelivery-mobilehub-2026985135"
// PUSH
//#define AWS_SNS_PLATFORM_APPLICATION_ARN @"arn:aws:sns:us-east-1:752818564425:app/APNS/livi_MOBILEHUB_2026985135"
#define AWS_SNS_PLATFORM_APPLICATION_ARN @"arn:aws:sns:us-east-1:752818564425:app/APNS_SANDBOX/livi_MOBILEHUB_2026985135"
#define AWS_SNS_ALL_DEVICE_TOPIC_ARN @"arn:aws:sns:us-east-1:752818564425:livi_alldevices_MOBILEHUB_2026985135"
// USER FILES
#define AWS_USER_FILE_MANAGER_S3_BUCKET_NAME @"livi-userfiles-mobilehub-2026985135"
// USER AGENT
#define AWS_MOBILEHUB_USER_AGENT @"MobileHub 5fff6340-6572-4551-a3b7-64f08c31f938 aws-my-sample-app-ios-objc-v0.6"
