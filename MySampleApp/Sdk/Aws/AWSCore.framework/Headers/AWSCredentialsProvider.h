//
// Copyright 2010-2016 Amazon.com, Inc. or its affiliates. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License").
// You may not use this file except in compliance with the License.
// A copy of the License is located at
//
// http://aws.amazon.com/apache2.0
//
// or in the "license" file accompanying this file. This file is distributed
// on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
// express or implied. See the License for the specific language governing
// permissions and limitations under the License.
//

#import <Foundation/Foundation.h>
#import "AWSServiceEnum.h"
#import "AWSIdentityProvider.h"

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const AWSCognitoCredentialsProviderErrorDomain;
typedef NS_ENUM(NSInteger, AWSCognitoCredentialsProviderErrorType) {
    AWSCognitoCredentialsProviderErrorUnknown,
    AWSCognitoCredentialsProviderIdentityIdIsNil,
    AWSCognitoCredentialsProviderInvalidConfiguration,
};

@class AWSTask<__covariant ResultType>;

@interface AWSCredentials : NSObject

/**
 *  Access Key component of credentials.
 */
@property (nonatomic, strong, readonly) NSString *accessKey;

/**
 *  Secret Access Key component of credentials.
 */
@property (nonatomic, strong, readonly) NSString *secretKey;

/**
 *  Session Token component of credentials.
 */
@property (nonatomic, strong, readonly, nullable) NSString *sessionKey;

/**
 *  Date at which these credentials will expire.
 */
@property (nonatomic, strong, readonly, nullable) NSDate *expiration;

- (instancetype)initWithAccessKey:(NSString *)accessKey
                        secretKey:(NSString *)secretKey
                       sessionKey:(nullable NSString *)sessionKey
                       expiration:(nullable NSDate *)expiration;

@end

/**
 *  The AWS credentials provider protocol used to provide credentials
 *  to the SDK in order to make calls to the AWS services.
 */
@protocol AWSCredentialsProvider <NSObject>

- (AWSTask<AWSCredentials *> *)credentials;

- (void)invalidateCachedTemporaryCredentials;

@end

/**
 *  @warning This credentials provider is intended only for testing purposes.
 *  We strongly discourage embedding AWS credentials in your production apps because they can be easily extracted and abused. Consider using `AWSCognitoCredentialsProvider`.
 */
@interface AWSStaticCredentialsProvider : NSObject <AWSCredentialsProvider>

- (instancetype)initWithAccessKey:(NSString *)accessKey
                        secretKey:(NSString *)secretKey;

- (instancetype)initWithCredentialsFilename:(NSString *)credentialsFilename;

- (AWSTask<AWSCredentials *> *)credentials;

@end

@interface AWSAnonymousCredentialsProvider : NSObject <AWSCredentialsProvider>

@end

/**
 *  A credentials provider that uses AWS STS web identity federation.
 */
@interface AWSWebIdentityCredentialsProvider : NSObject <AWSCredentialsProvider>

@property (nonatomic, strong) NSString *webIdentityToken;
@property (nonatomic, strong) NSString *roleArn;
@property (nonatomic, strong) NSString *roleSessionName;

@property (nonatomic, strong) NSString *providerId;

- (instancetype)initWithRegionType:(AWSRegionType)regionType
                        providerId:(NSString *)providerId
                           roleArn:(NSString *)roleArn
                   roleSessionName:(NSString *)roleSessionName
                  webIdentityToken:(NSString *)webIdentityToken;

- (AWSTask<AWSCredentials *> *)credentials;

@end

/**
 *  An AWSCredentialsProvider that uses Amazon Cognito to fetch temporary credentials tied to an identity.
 *
 *  To learn more about Amazon Cognito, please visit <a href="https://aws.amazon.com/cognito">https://aws.amazon.com/cognito</a>.
 *
 *  There are 3 different flows supported by this credentials provider, see factory and init methods for
 *  choosing the right one for your use case:
 *
 *  1. Enhanced flow: Uses Cognito for all operations and only requires an identity pool id to initialize.
 *  2. Basic flow: Uses Cognito + STS and requires identity pool plus IAM roles
 *  3. Developer authenticated identities: Uses your own AWSCognitoIdentityProvider to establish identity +
 *      Cognito (and optionally STS) to establish credentials.
 */
@interface AWSCognitoCredentialsProvider : NSObject <AWSCredentialsProvider>

/**
 *  The identityProvider which is responsible for establishing the identity id and
 *  (optionally) the open id token for use in the Amazon Cognito authflow.
 */
@property (nonatomic, strong) id<AWSCognitoIdentityProvider> identityProvider;

/**
 *  The identity id associated with this provider. This value will be fetched from the keychain
 *  at startup. If you do not want to reuse the existing identity id, you must call the clearKeychain method.
 */
@property (nonatomic, strong, readonly, nullable) NSString *identityId;

/**
 *  The identity pool id associated with this provider. Also used to create a namedspaced
 *  keychain area to store identity id and credentials.
 */
@property (nonatomic, strong, readonly) NSString *identityPoolId;

/**
 *  Initializer for credentials provider with enhanced authentication flow. This is the recommended
 *  constructor for first time Amazon Cognito developers. Will create an instance of `AWSEnhancedCognitoIdentityProvider`.
 *
 *  @param regionType The region in which your identity pool exists.
 *  @param identityPoolId The identity pool id for this provider. Value is used to communicate with
 *          Amazon Cognito as well as namespace values stored in the keychain.
 */
- (instancetype)initWithRegionType:(AWSRegionType)regionType
                    identityPoolId:(NSString *)identityPoolId;

/**
 *  Initializer for credentials provider with enhanced authentication flow. This is the recommended
 *  method for first time Amazon Cognito developers. Will create an instance of `AWSEnhancedCognitoIdentityProvider`.
 *
 *  @param regionType The region in which your identity pool exists.
 *  @param identityId The identity id to initialize this provider. If nil, the provider will attempt
 *          to read from the keychain.
 *  @param identityPoolId The identity pool id for this provider. Value is used to communicate with
 *          Amazon Cognito as well as namespace values stored in the keychain.
 *  @param logins The map of logins to link to this identity. Can be nil if identity is unauthenticated.
 */
- (instancetype)initWithRegionType:(AWSRegionType)regionType
                        identityId:(nullable NSString *)identityId
                    identityPoolId:(NSString *)identityPoolId
           identityProviderManager:(nullable id<AWSIdentityProviderManager>)identityProviderManager;

/**
 *  Initializer for credentials provider with pre-created `AWSCognitoIdentityProvider`. Use this
 *  method when using developer authenticated identities.
 *
 *  @param regionType The region in which your identity pool exists.
 *  @param identityProvider Implementation of AWSCognitoIdentityProvider which is responsible for
 *          acquirind identity id and (optionally) OpenId Connect token.
 *  @param unauthRoleArn The role ARN to use when getting credentials for unauthenticated identities.
 *          Provider will check the `isAuthenticated` property of the identity provider to
 *          determine which role to use. Can be nil if unauthenticated identities are not supported or
 *          if using enhanced authentication flow.
 *  @param authRoleArn The role ARN to use when getting credentials for authenticated identities.
 *          Provider will check the `isAuthenticated` property of the identity provider to
 *          determine which role to use. Can be nil if authenticated identities are not supported or
 *          if using enhanced authentication flow.
 */
- (instancetype)initWithRegionType:(AWSRegionType)regionType
                  identityProvider:(id<AWSCognitoIdentityProvider>)identityProvider
                     unauthRoleArn:(nullable NSString *)unauthRoleArn
                       authRoleArn:(nullable NSString *)authRoleArn;

/**
 *  Initializer for credentials provider with basic auth flow. Only use this method if you still
 *  need to set your IAM roles client side. This method will create an instance of `AWSBasicCognitoIdentityProvider`.
 *
 *  @param regionType The region in which your identity pool exists.
 *  @param identityId The identity id to initialize this provider. If nil, the provider will attempt
 *          to read from the keychain
 *  @param accountId The AWS account id for the owner of the identity pool. Can be nil as this value
 *          is no longer required
 *  @param identityPoolId The identity pool id for this provider. Value is used to communicate with
 *          Amazon Cognito as well as namespace values stored in the keychain.
 *  @param unauthRoleArn The role ARN to use when getting credentials for unauthenticated identities.
 *          Provider will check the `isAuthenticated` property of the identity provider to
 *          determine which role to use. Can be nil if unauthenticated identities are not supported.
 *  @param authRoleArn The role ARN to use when getting credentials for authenticated identities.
 *          Provider will check the `isAuthenticated` property of the identity provider to
 *          determine which role to use. Can be nil if authenticated identities are not supported.
 *  @param logins The map of logins to link to this identity. Can be nil if identity is unauthenticated.
 */
- (instancetype)initWithRegionType:(AWSRegionType)regionType
                        identityId:(nullable NSString *)identityId
                         accountId:(NSString *)accountId
                    identityPoolId:(NSString *)identityPoolId
                     unauthRoleArn:(nullable NSString *)unauthRoleArn
                       authRoleArn:(nullable NSString *)authRoleArn
           identityProviderManager:(nullable id<AWSIdentityProviderManager>)identityProviderManager;

- (AWSTask<AWSCredentials *> *)credentials;

/**
 *  Get/retrieve the identity id for this provider. If an identity id is already set on this
 *  provider, no remote call is made and the identity will be returned as a result of the AWSTask
 *  (the identityId is also available as a property).
 *  If no identityId is set on this provider, one will be retrieved from the service.
 *
 *  @return AWSTask
 */
- (AWSTask<NSString *> *)getIdentityId;

/**
 *  Clear ALL saved values for this provider (identityId, credentials, logins)
 */
- (void)clearKeychain;

/**
 *  Clear the cached AWS credentials for this provider.
 */
- (void)clearCredentials;

/**
 *  Internal method used to determine if the identityId should be reset on a provider
 */
+ (BOOL)shouldResetIdentityId:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
