//
//  AWSIdentityManager.m
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

#import "AWSIdentityManager.h"
#import "AWSSignInProvider.h"
#import "AWSTask+CheckExceptions.h"
#import "AWSConfiguration.h"
#import "AWSFacebookSignInProvider.h"
#import "AWSGoogleSignInProvider.h"

NSString *const AWSIdentityManagerDidSignInNotification = @"com.amazonaws.AWSIdentityManager.AWSIdentityManagerDidSignInNotification";
NSString *const AWSIdentityManagerDidSignOutNotification = @"com.amazonaws.AWSIdentityManager.AWSIdentityManagerDidSignOutNotification";

typedef void (^AWSIdentityManagerCompletionBlock)(id result, NSError *error);

@interface AWSIdentityManager()<AWSIdentityProviderManager>

@property (nonatomic, strong) AWSCognitoCredentialsProvider *credentialsProvider;
@property (atomic, copy) AWSIdentityManagerCompletionBlock completionHandler;

@property (nonatomic, strong) id<AWSSignInProvider> currentSignInProvider;

@end

@implementation AWSIdentityManager

+ (instancetype)sharedInstance {
    static AWSIdentityManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [AWSIdentityManager new];
    });
    return _sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        [AWSLogger defaultLogger].logLevel = AWSLogLevelVerbose;
        [AWSServiceConfiguration addGlobalUserAgentProductToken:AWS_MOBILEHUB_USER_AGENT];

        self.credentialsProvider =[[AWSCognitoCredentialsProvider alloc] initWithRegionType:AMAZON_COGNITO_REGION
                                                                                 identityId:nil
                                                                             identityPoolId:AMAZON_COGNITO_IDENTITY_POOL_ID
                                                                    identityProviderManager:self];

        AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AMAZON_COGNITO_REGION
                                                                             credentialsProvider:self.credentialsProvider];

        [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
    }

    return self;
}

#pragma mark - AWSIdentityProviderManager

- (AWSTask<NSDictionary<NSString *, NSString *> *> *)logins {
    if (!self.currentSignInProvider) {
        return [AWSTask taskWithResult:nil];
    }
    return [[self.currentSignInProvider token] continueWithSuccessBlock:^id _Nullable(AWSTask<NSString *> * _Nonnull task) {
        NSString *token = task.result;
        return [AWSTask taskWithResult:@{self.currentSignInProvider.identityProviderName : token}];
    }];
}

#pragma mark -

- (NSString *)identityId {
    return self.credentialsProvider.identityId;
}

- (BOOL)isLoggedIn {
    return self.currentSignInProvider.isLoggedIn;
}

- (NSURL *)imageURL {
    return self.currentSignInProvider.imageURL;
}

- (NSString *)userName {
    return self.currentSignInProvider.userName;
}

- (void)wipeAll {
    self.credentialsProvider.identityProvider.identityProviderManager = self;
    [self.credentialsProvider clearKeychain];
}

- (void)logoutWithCompletionHandler:(void (^)(id result, NSError *error))completionHandler {
    if ([self.currentSignInProvider isLoggedIn]) {
        [self.currentSignInProvider logout];
    }

    [self wipeAll];

    self.currentSignInProvider = nil;

    [[self.credentialsProvider getIdentityId] continueWithExceptionCheckingBlock:^(id result, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
            [notificationCenter postNotificationName:AWSIdentityManagerDidSignOutNotification
                                              object:[AWSIdentityManager sharedInstance]
                                            userInfo:nil];
            completionHandler(result, error);
        });
    }];
}

- (void)loginWithSignInProvider:(AWSSignInProviderType)signInProviderType
              completionHandler:(void (^)(id result, NSError *error))completionHandler {
    if (signInProviderType == AWSSignInProviderTypeFacebook) {
        self.currentSignInProvider = [AWSFacebookSignInProvider sharedInstance];
    }
    if (signInProviderType == AWSSignInProviderTypeGoogle) {
        self.currentSignInProvider = [AWSGoogleSignInProvider sharedInstance];
    }

    self.completionHandler = completionHandler;
    [self.currentSignInProvider login];
}

- (void)resumeSessionWithCompletionHandler:(void (^)(id result, NSError *error))completionHandler {
    self.completionHandler = completionHandler;

    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"Facebook"]) {
        self.currentSignInProvider = [AWSFacebookSignInProvider sharedInstance];
    }
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"Google"]) {
        self.currentSignInProvider = [AWSGoogleSignInProvider sharedInstance];
    }

    [self.currentSignInProvider reloadSession];

    if (self.credentialsProvider == nil) {
        [self completeLogin];
    }
}

- (void)completeLogin {
    // Force a refresh of credentials to see if we need to merge
    [self.credentialsProvider invalidateCachedTemporaryCredentials];
    
    [[self.credentialsProvider credentials] continueWithExceptionCheckingBlock:^(id result, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.currentSignInProvider) {
                NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
                [notificationCenter postNotificationName:AWSIdentityManagerDidSignInNotification
                                                  object:[AWSIdentityManager sharedInstance]
                                                userInfo:nil];
            }

            self.completionHandler(result, error);
        });
    }];
}

- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    return [self.currentSignInProvider application:application
                     didFinishLaunchingWithOptions:launchOptions];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [self.currentSignInProvider application:application
                                           openURL:url
                                 sourceApplication:sourceApplication
                                        annotation:annotation];
}

@end
