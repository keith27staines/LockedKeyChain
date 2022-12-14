/* Copyright Airship and Contributors */

#import "UAKeychainUtils.h"
#import "UAGlobal.h"

#import <Security/Security.h>
#include <sys/utsname.h>

static NSString * const UAKeychainDeviceIDKey = @"com.urbanairship.deviceID";

static NSString *cachedDeviceID_ = nil;

@interface UAKeychainUtils()
+ (NSMutableDictionary *)searchDictionaryWithIdentifier:(NSString *)identifier;

/**
 * Creates a new Airship Device ID (UUID) and stores it in the keychain.
 *
 * @return The device ID.
 */
+ (NSString *)createDeviceID;
@end


@implementation UAKeychainUtils

+ (BOOL)createKeychainValueForUsername:(NSString *)username withPassword:(NSString *)password forIdentifier:(NSString *)identifier {
    NSMutableDictionary *userDictionary = [UAKeychainUtils searchDictionaryWithIdentifier:identifier];

    // Set access permission - we use the keychain for its stickiness, not security,
    // the current security attribute is used primarily to prevent flagging during security scans
    [userDictionary setObject:(__bridge id)kSecAttrAccessibleAfterFirstUnlock forKey:(__bridge id)kSecAttrAccessible];

    // Set username data
    [userDictionary setObject:username forKey:(__bridge id)kSecAttrAccount];

    // Set password data
    NSData *passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
    [userDictionary setObject:passwordData forKey:(__bridge id)kSecValueData];

    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)userDictionary, NULL);

    if (status == errSecSuccess) {
        return YES;
    }

    return NO;
}

+ (void)deleteKeychainValue:(NSString *)identifier {
    NSMutableDictionary *searchDictionary = [UAKeychainUtils searchDictionaryWithIdentifier:identifier];
    SecItemDelete((__bridge CFDictionaryRef)searchDictionary);
}

+ (BOOL)updateKeychainValueForUsername:(NSString *)username 
                          withPassword:(NSString *)password 
                         forIdentifier:(NSString *)identifier {


    // Setup search dict, use username as query param
    NSMutableDictionary *searchDictionary = [self searchDictionaryWithIdentifier:identifier];
    [searchDictionary setObject:username forKey:(__bridge id)kSecAttrAccount];

    // Update password
    NSMutableDictionary *updateDictionary = [NSMutableDictionary dictionary];
    NSData *passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
    [updateDictionary setObject:passwordData forKey:(__bridge id)kSecValueData];

    OSStatus status = SecItemUpdate((__bridge CFDictionaryRef)searchDictionary,
                                    (__bridge CFDictionaryRef)updateDictionary);

    if (status == errSecSuccess) {
        return YES;
    }

    return NO;
}

/**
 * Helper method to get the user credentials.
 *
 * @return The results dictionary with the username stored under the kSecAttrAccount key,
 * and the password stored under kSecValueData.
 */
+ (NSDictionary *)getUserCredentials:(NSString *)identifier {
    if (!identifier) {
        UA_LERR(@"Unable to get user credentials. The identifier for the keychain is nil.");
        return nil;
    }

    NSMutableDictionary *searchQuery = [UAKeychainUtils searchDictionaryWithIdentifier:identifier];

    // Add search attributes
    [searchQuery setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];

    // Add search return types
    [searchQuery setObject:(id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
    [searchQuery setObject:(id)kCFBooleanTrue forKey:(__bridge id)kSecReturnAttributes];

    CFDictionaryRef resultDataRef = nil;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)searchQuery, (CFTypeRef *)&resultDataRef);
    NSDictionary *resultDict = (__bridge_transfer NSDictionary *)resultDataRef;

    if (status == errSecSuccess && resultDict) {

        // Check if we have the old attribute type(s)
        if ([[[resultDict objectForKey:(__bridge id)kSecAttrAccessible] copy] isEqualToString:(__bridge NSString *)(kSecAttrAccessibleAlways)]
            || [[[resultDict objectForKey:(__bridge id)kSecAttrAccessible] copy] isEqualToString:(__bridge NSString *)(kSecAttrAccessibleAlwaysThisDeviceOnly)]) {

            UA_LTRACE(@"Updating user credentials attributes");

            // Update the deviceID attribute to kSecAttrAccessibleAlwaysThisDeviceOnly
            NSMutableDictionary *updateQuery = [NSMutableDictionary dictionary];

            // Set the new attribute
            [updateQuery setObject:(__bridge id)kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly forKey:(__bridge id)kSecAttrAccessible];

            // Perform the update
            OSStatus status = SecItemUpdate((__bridge CFDictionaryRef)[UAKeychainUtils searchDictionaryWithIdentifier:UAKeychainDeviceIDKey], (__bridge CFDictionaryRef)updateQuery);
            if (status != errSecSuccess) {
                UA_LTRACE(@"Failed to update user credentials accessibility attribute.");
            } else {
                UA_LTRACE(@"Updated user credentials attributes.");
            }
        }

        return resultDict;
    }

    return nil;
}

+ (NSString *)getPassword:(NSString *)identifier {
    NSDictionary *credentials = [self getUserCredentials:identifier];
    if (credentials) {
        return [[NSString alloc] initWithData:[credentials valueForKey:(__bridge id)kSecValueData] encoding:NSUTF8StringEncoding];
    }
    return nil;
}

+ (NSString *)getUsername:(NSString *)identifier {
    NSDictionary *credentials = [self getUserCredentials:identifier];
    return [[credentials objectForKey:(__bridge id)kSecAttrAccount] copy];
}

+ (NSMutableDictionary *)searchDictionaryWithIdentifier:(NSString *)identifier {
    NSMutableDictionary *searchDictionary = [NSMutableDictionary dictionary];

    [searchDictionary setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];

    //use identifier param and the bundle ID as keys
    NSData *encodedIdentifier = [identifier dataUsingEncoding:NSUTF8StringEncoding];
    [searchDictionary setObject:encodedIdentifier forKey:(__bridge id)kSecAttrGeneric];

    NSString *bundleID = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    if (bundleID) {
        [searchDictionary setObject:bundleID forKey:(__bridge id)kSecAttrService];
    }

    return searchDictionary; 
}

#pragma mark -
#pragma Airship Device ID

+ (NSString *)createDeviceID {
    NSString *deviceID = [NSUUID UUID].UUIDString;

    NSMutableDictionary *keychainValues = [UAKeychainUtils searchDictionaryWithIdentifier:UAKeychainDeviceIDKey];

    // Set access permission - we use the keychain for its stickiness, not security,
    // the current security attribute is used primarily to prevent flagging during security scans
    [keychainValues setObject:(__bridge id)kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly forKey:(__bridge id)kSecAttrAccessible];

    //set model name (username) data
    [keychainValues setObject:[UAKeychainUtils deviceModelName] forKey:(__bridge id)kSecAttrAccount];

    //set device ID (password) data
    NSData *deviceIDData = [deviceID dataUsingEncoding:NSUTF8StringEncoding];
    [keychainValues setObject:deviceIDData forKey:(__bridge id)kSecValueData];

    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)keychainValues, NULL);

    if (status == errSecSuccess) {
        return deviceID;
    } else {
        return @"";
    }
}
// Note: Due to the unpredictability of the keychain after unlocking the device, this method should only be called
// on a background queue.
+ (NSString *)getDeviceID {

    if (cachedDeviceID_) {
        return cachedDeviceID_;
    }

    //Get password next
    NSMutableDictionary *deviceIDQuery = [UAKeychainUtils searchDictionaryWithIdentifier:UAKeychainDeviceIDKey];

    // Add search attributes
    [deviceIDQuery setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];

    // Add search return types
    [deviceIDQuery setObject:(id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
    [deviceIDQuery setObject:(id)kCFBooleanTrue forKey:(__bridge id)kSecReturnAttributes];

    CFDictionaryRef resultDataRef = nil;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)deviceIDQuery, (CFTypeRef *)&resultDataRef);

    NSDictionary *resultDict = (__bridge_transfer NSDictionary *)resultDataRef;

    NSString *deviceID = nil;
    if (status == errSecSuccess) {

        UA_LTRACE(@"Retrieved Device ID info from keychain.");

        if (resultDataRef) {
            // Check if we have the old attribute type(s)
            if ([[[resultDict objectForKey:(__bridge id)kSecAttrAccessible] copy] isEqualToString:(__bridge NSString *)(kSecAttrAccessibleAlways)]
                || [[[resultDict objectForKey:(__bridge id)kSecAttrAccessible] copy] isEqualToString:(__bridge NSString *)(kSecAttrAccessibleAlwaysThisDeviceOnly)]) {

                UA_LTRACE(@"Updating Device ID attributes");

                // Update the deviceID attribute to kSecAttrAccessibleAlwaysThisDeviceOnly
                NSMutableDictionary *updateQuery = [NSMutableDictionary dictionary];

                // Set the new attribute
                [updateQuery setObject:(__bridge id)kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly forKey:(__bridge id)kSecAttrAccessible];

                // Perform the update
                OSStatus status = SecItemUpdate((__bridge CFDictionaryRef)[UAKeychainUtils searchDictionaryWithIdentifier:UAKeychainDeviceIDKey], (__bridge CFDictionaryRef)updateQuery);
                if (status != errSecSuccess) {
                    UA_LTRACE(@"Failed to update Device ID accessibility attribute.");
                } else {
                    UA_LTRACE(@"Updated Device ID attributes.");
                }
            }

            // Grab the device ID
            deviceID = [[NSString alloc] initWithData:[resultDict valueForKey:(__bridge id)kSecValueData] encoding:NSUTF8StringEncoding];

            UA_LTRACE(@"Loaded Device ID: %@", deviceID);
        } else {
            UA_LTRACE(@"Device ID result is nil.");
        }
    }

    if (!deviceID) {
        [UAKeychainUtils deleteKeychainValue:UAKeychainDeviceIDKey];
        deviceID = [UAKeychainUtils createDeviceID];
        UA_LDEBUG(@"Generated new Device ID: %@", deviceID);
    }

    cachedDeviceID_ = [deviceID copy];

    return deviceID;
}


+ (NSString *)deviceModelName {
#if TARGET_OS_MACCATALYST
    return @"mac";
#else
    struct utsname systemInfo;
    uname(&systemInfo);

    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
#endif
}
@end
