//
//  AWSGoogleSignInProvider.m
//
//
// Copyright 2016 Amazon.com, Inc. or its affiliates (Amazon). All Rights Reserved.
//
// Code generated by AWS Mobile Hub. Amazon gives unlimited permission to 
// copy, distribute and modify it.
//
// Source code generated from template: aws-my-sample-app-ios-objc v0.6
//
#import "AWSGoogleSignInProvider.h"
#import "AWSIdentityManager.h"
#import "AWSConfiguration.h"

#import <GoogleSignIn/GoogleSignIn.h>

static NSString *const AWSGoogleSignInProviderKey = @"Google";
static NSString *const AWSGoogleSignInProviderUserNameKey = @"Google.userName";
static NSString *const AWSGoogleSignInProviderImageURLKey = @"Google.imageURL";
static NSString *const AWSGoogleSignInProviderClientScope = @"https://www.googleapis.com/auth/userinfo.profile";
static NSString *const AWSGoogleSignInProviderOIDCScope = @"openid";
static NSTimeInterval const AWSGoogleSignInProviderTokenRefreshBuffer = 10 * 60;
static NSUInteger const AWSGoogleSignInProviderProfileImageDimension = 150;
static int64_t const AWSGoogleSignInProviderTokenRefreshTimeout = 60 * NSEC_PER_SEC;

@interface AWSIdentityManager()

- (void)completeLogin;

@end

@interface AWSGoogleSignInProvider() <GIDSignInDelegate>

@property (atomic, strong) AWSTaskCompletionSource *taskCompletionSource;
@property (nonatomic, strong) dispatch_semaphore_t semaphore;

@end

@implementation AWSGoogleSignInProvider

+ (instancetype)sharedInstance {
    static AWSGoogleSignInProvider *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [AWSGoogleSignInProvider new];
    });

    return _sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        _semaphore = dispatch_semaphore_create(0);

        GIDSignIn *signIn = [GIDSignIn sharedInstance];
        signIn.delegate = self;
        signIn.clientID = GOOGLE_CLIENT_IDENTITY;
        signIn.scopes = @[AWSGoogleSignInProviderClientScope, AWSGoogleSignInProviderOIDCScope];
        signIn.allowsSignInWithBrowser = YES;
        signIn.allowsSignInWithWebView = NO;
    }

    return self;
}

#pragma mark - AWSIdentityProvider

- (NSString *)identityProviderName {
    return AWSIdentityProviderGoogle;
}

- (AWSTask<NSString *> *)token {
    AWSTask *task = [AWSTask taskWithResult:nil];
    return [task continueWithSuccessBlock:^id _Nullable(AWSTask * _Nonnull task) {
        @synchronized(self) {
            if (self.taskCompletionSource) {
                // Waits up to 60 seconds for the Google SDK to refresh a token.
                if (dispatch_semaphore_wait(self.semaphore, dispatch_time(DISPATCH_TIME_NOW, AWSGoogleSignInProviderTokenRefreshTimeout)) != 0) {
                    NSError *error = [NSError errorWithDomain:AWSCognitoIdentityProviderErrorDomain
                                                         code:AWSCognitoIdentityProviderErrorTokenRefreshTimeout
                                                     userInfo:nil];
                    return [AWSTask taskWithError:error];
                }
            }

            NSString *idToken = [GIDSignIn sharedInstance].currentUser.authentication.idToken;
            NSDate *idTokenExpirationDate = [GIDSignIn sharedInstance].currentUser.authentication.idTokenExpirationDate;

            if (idToken
                // If the cached token expires within 10 min, tries refreshing a token.
                && [idTokenExpirationDate compare:[NSDate dateWithTimeIntervalSinceNow:AWSGoogleSignInProviderTokenRefreshBuffer]] == NSOrderedDescending) {
                return [AWSTask taskWithResult:idToken];
            }

            // `self.taskCompletionSource` is used to convert the `GIDSignInDelegate` method to a block based method.
            // The `token` string or an error object is returned in a block when the delegate method is called later.
            // See the `GIDSignInDelegate` section of this file.
            self.taskCompletionSource = [AWSTaskCompletionSource taskCompletionSource];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[GIDSignIn sharedInstance] signInSilently];
            });
            return self.taskCompletionSource.task;
        }
    }];
}

#pragma mark -

- (BOOL)isLoggedIn {
    BOOL loggedIn = [[GIDSignIn sharedInstance] hasAuthInKeychain];
    return [[NSUserDefaults standardUserDefaults] objectForKey:AWSGoogleSignInProviderKey] != nil && loggedIn;
}

- (NSString *)userName {
    return [[NSUserDefaults standardUserDefaults] objectForKey:AWSGoogleSignInProviderUserNameKey];
}

- (void)setUserName:(NSString *)userName {
    [[NSUserDefaults standardUserDefaults] setObject:userName
                                              forKey:AWSGoogleSignInProviderUserNameKey];
}

- (NSURL *)imageURL {
    return [NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:AWSGoogleSignInProviderImageURLKey]];
}

- (void)setImageURL:(NSURL *)imageURL {
    [[NSUserDefaults standardUserDefaults] setObject:imageURL.absoluteString
                                              forKey:AWSGoogleSignInProviderImageURLKey];
}

- (void)reloadSession {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:AWSGoogleSignInProviderKey]) {
        GIDSignIn *signIn = [GIDSignIn sharedInstance];
        [signIn signInSilently];
    }
}

- (void)completeLoginWithToken:(GIDGoogleUser *)googleUser {
    [[NSUserDefaults standardUserDefaults] setObject:@"YES"
                                              forKey:AWSGoogleSignInProviderKey];
    [[AWSIdentityManager sharedInstance] completeLogin];

    self.userName = googleUser.profile.name;
    self.imageURL = [googleUser.profile imageURLWithDimension:AWSGoogleSignInProviderProfileImageDimension];
}

- (void)login {
    GIDSignIn *signIn = [GIDSignIn sharedInstance];
    [signIn signIn];
}

- (void)logout {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:AWSGoogleSignInProviderKey];
    GIDSignIn *signIn = [GIDSignIn sharedInstance];
    [signIn disconnect];
}

#pragma mark - GIDSignInDelegate

- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error {
    // `self.taskCompletionSource` is used to return `user.authentication.idToken` or `error` to the `- token` method.
    // See the `AWSIdentityProvider` section of this file.
    if (error) {
        AWSLogError(@"Error: %@", error);
        if (self.taskCompletionSource) {
            self.taskCompletionSource.error = error;
            self.taskCompletionSource = nil;
        }
    } else {
        if (self.taskCompletionSource) {
            self.taskCompletionSource.result = user.authentication.idToken;
            self.taskCompletionSource = nil;
        }
        [self completeLoginWithToken:user];
    }

    dispatch_semaphore_signal(self.semaphore);
}

- (void)signIn:(GIDSignIn *)signIn didDisconnectWithUser:(GIDGoogleUser *)user withError:(NSError *)error {
    if (error) {
        AWSLogError(@"Error: %@", error);
    }
}

#pragma mark - Application delegates

- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    return YES;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [[GIDSignIn sharedInstance] handleURL:url
                               sourceApplication:sourceApplication
                                      annotation:annotation];
}

@end
