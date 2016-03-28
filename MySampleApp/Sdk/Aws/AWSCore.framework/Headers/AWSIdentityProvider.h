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

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const AWSCognitoIdentityIdChangedNotification;
FOUNDATION_EXPORT NSString *const AWSCognitoNotificationPreviousId;
FOUNDATION_EXPORT NSString *const AWSCognitoNotificationNewId;

FOUNDATION_EXPORT NSString *const AWSIdentityProviderDigits;
FOUNDATION_EXPORT NSString *const AWSIdentityProviderFacebook;
FOUNDATION_EXPORT NSString *const AWSIdentityProviderGoogle;
FOUNDATION_EXPORT NSString *const AWSIdentityProviderLoginWithAmazon;
FOUNDATION_EXPORT NSString *const AWSIdentityProviderTwitter;

typedef NS_ENUM(NSInteger, AWSCognitoLoginProviderKey) {
    AWSCognitoLoginProviderKeyUnknown,
    AWSCognitoLoginProviderKeyFacebook,
    AWSCognitoLoginProviderKeyGoogle,
    AWSCognitoLoginProviderKeyLoginWithAmazon,
    AWSCognitoLoginProviderKeyTwitter,
} __attribute__((deprecated("Use AWSIdentityProvider const strings instead. e.g. AWSIdentityProviderFacebook")));

FOUNDATION_EXPORT NSString *const AWSCognitoIdentityProviderErrorDomain;
typedef NS_ENUM(NSInteger, AWSCognitoIdentityProviderErrorType) {
    AWSCognitoIdentityProviderErrorIdentityIsNil,
    AWSCognitoIdentityProviderErrorTokenRefreshTimeout,
};

@class AWSTask<__covariant ResultType>;

/**
 * AWSIdentityProvider provides an interface for acquiring an identity token from a provider.
 */
@protocol AWSIdentityProvider <NSObject>

/**
 *  The name of the identity provider. e.g. graph.facebook.com.
 */
@property (nonatomic, readonly) NSString *identityProviderName;

/**
 * Returns the token associated with this provider. If the token is cached and invalid, should refresh and return the valid token.
 */
- (AWSTask<NSString *> *)token;

@end

@protocol AWSIdentityProviderManager <NSObject>

/**
 * Each entry in logins represents a single login with an identity provider.
 * The key is the domain of the login provider (e.g. 'graph.facebook.com') and the value is the
 * OAuth/OpenId Connect token that results from an authentication with that login provider.
 */
- (AWSTask<NSDictionary<NSString *, NSString *> *> *)logins;

@end

/**
 * AWSCognitoIdentityProvider provides a Cognito specific identity provider. Cognito Identity 
 * providers are associated with an identity pool. If the identity pool supports authenticated
 * access, multiple logins may be added to link to the Cognito identity.
 */
@protocol AWSCognitoIdentityProvider <AWSIdentityProvider, AWSIdentityProviderManager>

/**
 * The identity pool for this provider. Used to when making calls to the Amazon Cognito service
 */
@property (nonatomic, strong, readonly) NSString *identityPoolId;

/**
 * The identity id as determined by the Amazon Cognito service
 */
@property (nonatomic, strong) NSString * _Nullable identityId;

/**
 *
 */
@property (nonatomic, strong) id<AWSIdentityProviderManager> _Nullable identityProviderManager;

/**
 * Get/retrieve the identity id for this provider. If an identity id is already set on this
 * provider, no remote call is made and the identity will be returned as a result of the AWSTask 
 * (the identityId is also available as a property). 
 * If no identityId is set on this provider, one will be retrieved from the service.
 */
- (AWSTask<NSString *> *)getIdentityId;

/**
 * Is this provider considered 'authenticated'. By default, only returns YES if logins is set.
 */
- (BOOL)isAuthenticated;

/**
 * Clear saved values for identityId, token, and logins.
 */
- (void)clear;

@optional

/**
 * Specifies the AWS Account Id for the owner of the identity pool.
 * No longer required by Amazon Cognito
 */
@property (nonatomic, strong, readonly) NSString *accountId;

@end

/**
 * An abstract implementation of the AWSCognitoIdentityProvider. Developers should extend this class
 * when they want to implement developer authenticated identities but do not need to support the basic
 * Amazon Cognito authflow in the same application.
 */
@interface AWSAbstractIdentityProvider : NSObject <AWSCognitoIdentityProvider>

/**
 * The identity pool for this provider. Used to when making calls to the Amazon Cognito service
 */
@property (nonatomic, strong, readonly) NSString *identityPoolId;

/**
 * The identity id as determined by the Amazon Cognito service
 */
@property (nonatomic, strong) NSString * _Nullable identityId;

/**
 *
 */
@property (nonatomic, strong) id<AWSIdentityProviderManager> _Nullable identityProviderManager;

@end

/**
 * An abstract implementation of the AWSCognitoIdentityProvider. Developers should extend this class
 * when they want to implement developer authenticated identities and want to support the basic
 * Amazon Cognito authflow in the same application.
 */
@interface AWSAbstractCognitoIdentityProvider : AWSAbstractIdentityProvider

- (instancetype)initWithRegionType:(AWSRegionType)regionType
                        identityId:(nullable NSString *)identityId
                         accountId:(nullable NSString *)accountId
                    identityPoolId:(NSString *)identityPoolId
           identityProviderManager:(nullable id<AWSIdentityProviderManager>)identityProviderManager;
@end

/**
 * The basic Amazon Cognito Identity Provider. Follows the following flow for credentials:
 * 1. Calls GetId to establish an identity id.
 * 2. Calls GetOpenIdToken to get an OpenId Connect token for that identity id.
 * 3. Calls AssumeRoleWithWebIdentity to get credentials with that token.
 */
@interface AWSBasicCognitoIdentityProvider : AWSAbstractCognitoIdentityProvider

@end

/**
 * The basic Amazon Cognito Identity Provider. Follows the following flow for credentials:
 * 1. Calls GetId to establish an identity id.
 * 2. Calls GetCredentialsForIdentity to get credentials that identity id.
 */
@interface AWSEnhancedCognitoIdentityProvider : AWSAbstractCognitoIdentityProvider

- (instancetype)initWithRegionType:(AWSRegionType)regionType
                        identityId:(nullable NSString *)identityId
                    identityPoolId:(NSString *)identityPoolId
           identityProviderManager:(nullable id<AWSIdentityProviderManager>)identityProviderManager;

@end

NS_ASSUME_NONNULL_END
