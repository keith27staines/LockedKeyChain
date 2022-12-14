/* Copyright Airship and Contributors */

#import <Foundation/Foundation.h>

#import "UAAirshipMessageCenterCoreImport.h"

@class UAUser;
@class UARuntimeConfig;
@class UAPreferenceDataStore;
@class UARequestSession;

NS_ASSUME_NONNULL_BEGIN

#define kUAChannelIDHeader @"X-UA-Channel-ID"

/**
 * Represents possible inbox API client errors.
 */
typedef NS_ENUM(NSInteger, UAEventAPIClientError) {
    /**
     * Indicates an unsuccessful client status.
     */
    UAInboxAPIClientErrorUnsuccessfulStatus,

    /**
     * Indicates the response was invalid.
     */
    UAInboxAPIClientErrorInvalidResponse
};

/**
 * The domain for NSErrors generated by the inbox API client.
 */
extern NSString * const UAInboxAPIClientErrorDomain;

/**
 * A high level abstraction for performing Rich Push API requests.
 */
@interface UAInboxAPIClient : NSObject

///---------------------------------------------------------------------------------------
/// @name Inbox API Client Internal Methods
///---------------------------------------------------------------------------------------

/**
 * Factory method for client.
 * @param config The Airship config.
 * @param session The request session.
 * @param user The inbox user.
 * @param dataStore The preference data store.
 * @return UAInboxAPIClient instance.
 */
+ (instancetype)clientWithConfig:(UARuntimeConfig *)config
                         session:(UARequestSession *)session
                            user:(UAUser *)user
                       dataStore:(UAPreferenceDataStore *)dataStore;

/**
 * Retrieves the full message list from the server.
 * @param error A pointer to an NSError.
 * @return The messages, or nil if there was an error or the message list has not changed since the last update.
 */
- (nullable NSArray *)retrieveMessageList:(NSError **)error;

/**
 * Performs a batch delete request on the server.
 *
 * @param messageReporting An NSArray of message reporting IDs to be deleted.
 * @return The success status
 */
- (BOOL)performBatchDeleteForMessageReporting:(NSArray<NSDictionary *> *)messageReporting;

/**
 * Performs a batch mark-as-read request on the server.
 *
 * @param messageReporting An NSArray of message reporting IDs to be marked as read.
 * @return The success status
 */
- (BOOL)performBatchMarkAsReadForMessageReporting:(NSArray<NSDictionary *> *)messageReporting;

/**
 * Clears the last modified time for message list requests.
 */
- (void)clearLastModifiedTime;

/**
 * Cancels all in-flight requests.
 */
- (void)cancelAllRequests;

@end

NS_ASSUME_NONNULL_END
