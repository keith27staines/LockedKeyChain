/* Copyright Airship and Contributors */

#import "UAInAppMessageHTMLDisplayContent+Internal.h"
#import "UAAirshipAutomationCoreImport.h"

#if __has_include("AirshipKit/AirshipKit-Swift.h")
#import <AirshipKit/AirshipKit-Swift.h>
#elif __has_include("AirshipKit-Swift.h")
#import "AirshipKit-Swift.h"
#else
@import AirshipCore;
#endif
NSString *const UAInAppMessageHTMLDisplayContentDomain = @"com.urbanairship.html_display_content";
NSString *const UAInAppMessageURLKey = @"url";

@implementation UAInAppMessageHTMLDisplayContentBuilder

- (instancetype)init {
    self = [super init];

    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.dismissButtonColor = [UIColor blackColor];
        self.requiresConnectivity = YES;
    }

    return self;
}

- (instancetype)initWithDisplayContent:(UAInAppMessageHTMLDisplayContent *)content {
    self = [super init];

    if (self) {
        self.url = content.url;
        self.backgroundColor = content.backgroundColor;
        self.dismissButtonColor = content.dismissButtonColor;
        self.borderRadiusPoints = content.borderRadiusPoints;
        self.allowFullScreenDisplay = content.allowFullScreenDisplay;
        self.height = content.height;
        self.width = content.width;
        self.aspectLock = content.aspectLock;
        self.requiresConnectivity = content.requireConnectivity;
    }

    return self;
}

+ (instancetype)builderWithDisplayContent:(UAInAppMessageHTMLDisplayContent *)content {
    return [[self alloc] initWithDisplayContent:content];
}

- (BOOL)isValid {

    if (!self.url) {
        UA_LERR(@"HTML display must have a URL.");
        return NO;
    }

    return YES;
}

@end

@interface UAInAppMessageHTMLDisplayContent ()

@property(nonatomic, copy) NSString *url;
@property(nonatomic, strong) UIColor *backgroundColor;
@property(nonatomic, strong) UIColor *dismissButtonColor;
@property(nonatomic, assign) CGFloat borderRadiusPoints;
@property(nonatomic, assign) BOOL allowFullScreenDisplay;
@property(nonatomic, assign) CGFloat height;
@property(nonatomic, assign) CGFloat width;
@property(nonatomic, assign) BOOL aspectLock;
@property(nonatomic, assign) BOOL requireConnectivity;

@end

@implementation UAInAppMessageHTMLDisplayContent

+ (nullable instancetype)displayContentWithBuilderBlock:(void (^)(UAInAppMessageHTMLDisplayContentBuilder *))builderBlock {
    UAInAppMessageHTMLDisplayContentBuilder *builder = [[UAInAppMessageHTMLDisplayContentBuilder alloc] init];

    if (builderBlock) {
        builderBlock(builder);
    }

    return [[UAInAppMessageHTMLDisplayContent alloc] initWithBuilder:builder];
}

+ (nullable instancetype)displayContentWithJSON:(id)json error:(NSError * _Nullable __autoreleasing *)error {
    UAInAppMessageHTMLDisplayContentBuilder *builder = [[UAInAppMessageHTMLDisplayContentBuilder alloc] init];

    if (![json isKindOfClass:[NSDictionary class]]) {
        if (error) {
            NSString *msg = [NSString stringWithFormat:@"Attempted to deserialize invalid object: %@", json];
            *error =  [NSError errorWithDomain:UAInAppMessageHTMLDisplayContentDomain
                                          code:UAInAppMessageHTMLDisplayContentErrorCodeInvalidJSON
                                      userInfo:@{NSLocalizedDescriptionKey:msg}];
        }
        return nil;
    }

    builder.url = json[UAInAppMessageURLKey];
    if (!builder.url) {
        return nil;
    }

    id backgroundColor = json[UAInAppMessageBackgroundColorKey];
    if (backgroundColor) {
        if (![backgroundColor isKindOfClass:[NSString class]]) {
            if (error) {
                NSString *msg = [NSString stringWithFormat:@"Background color must be a string. Invalid value: %@", backgroundColor];
                *error =  [NSError errorWithDomain:UAInAppMessageHTMLDisplayContentDomain
                                              code:UAInAppMessageHTMLDisplayContentErrorCodeInvalidJSON
                                          userInfo:@{NSLocalizedDescriptionKey:msg}];
            }
            return nil;
        }
        builder.backgroundColor = [UAColorUtils colorWithHexString:backgroundColor];
    }

    id dismissButtonColor = json[UAInAppMessageDismissButtonColorKey];
    if (dismissButtonColor) {
        if (![dismissButtonColor isKindOfClass:[NSString class]]) {
            if (error) {
                NSString *msg = [NSString stringWithFormat:@"Dismiss button color must be a string. Invalid value: %@", dismissButtonColor];
                *error =  [NSError errorWithDomain:UAInAppMessageHTMLDisplayContentDomain
                                              code:UAInAppMessageHTMLDisplayContentErrorCodeInvalidJSON
                                          userInfo:@{NSLocalizedDescriptionKey:msg}];
            }
            return nil;
        }
        builder.dismissButtonColor = [UAColorUtils colorWithHexString:dismissButtonColor];
    }

    id borderRadius = json[UAInAppMessageBorderRadiusKey];
    if (borderRadius) {
        if (![borderRadius isKindOfClass:[NSNumber class]]) {
            if (error) {
                NSString *msg = [NSString stringWithFormat:@"Border radius must be a number. Invalid value: %@", borderRadius];
                *error =  [NSError errorWithDomain:UAInAppMessageHTMLDisplayContentDomain
                                              code:UAInAppMessageHTMLDisplayContentErrorCodeInvalidJSON
                                          userInfo:@{NSLocalizedDescriptionKey:msg}];
            }
            return nil;
        }
        builder.borderRadiusPoints = [borderRadius doubleValue];
    }

    id allowFullScreenDisplay = json[UAInAppMessageHTMLAllowsFullScreenKey];
    if (allowFullScreenDisplay) {
        if (![allowFullScreenDisplay isKindOfClass:[NSNumber class]]) {
            if (error) {
                NSString *msg = [NSString stringWithFormat:@"Allows full screen flag must be a boolean stored as an NSNumber. Invalid value: %@", allowFullScreenDisplay];
                *error =  [NSError errorWithDomain:UAInAppMessageHTMLDisplayContentDomain
                                              code:UAInAppMessageHTMLDisplayContentErrorCodeInvalidJSON
                                          userInfo:@{NSLocalizedDescriptionKey:msg}];
            }
            return nil;
        }
        builder.allowFullScreenDisplay = [allowFullScreenDisplay boolValue];
    }

    id height = json[UAInAppMessageHTMLHeightKey];
    if (height) {
        if (![height isKindOfClass:[NSNumber class]]) {
            if (error) {
                NSString *msg = [NSString stringWithFormat:@"Height must be a number. Invalid value: %@", height];
                *error =  [NSError errorWithDomain:UAInAppMessageHTMLDisplayContentDomain
                                              code:UAInAppMessageHTMLDisplayContentErrorCodeInvalidJSON
                                          userInfo:@{NSLocalizedDescriptionKey:msg}];
            }
            return nil;
        }
        builder.height = [height floatValue];
    }

    id width = json[UAInAppMessageHTMLWidthKey];
    if (width) {
        if (![width isKindOfClass:[NSNumber class]]) {
            if (error) {
                NSString *msg = [NSString stringWithFormat:@"Width must be a number. Invalid value: %@", width];
                *error =  [NSError errorWithDomain:UAInAppMessageHTMLDisplayContentDomain
                                              code:UAInAppMessageHTMLDisplayContentErrorCodeInvalidJSON
                                          userInfo:@{NSLocalizedDescriptionKey:msg}];
            }
            return nil;
        }
        builder.width = [width floatValue];
    }

    id aspectLock = json[UAInAppMessageHTMLAspectLockKey];
    if (aspectLock) {
        if (![aspectLock isKindOfClass:[NSNumber class]]) {
            if (error) {
                NSString *msg = [NSString stringWithFormat:@"Aspect lock flag must be a boolean stored as an NSNumber. Invalid value: %@", aspectLock];
                *error =  [NSError errorWithDomain:UAInAppMessageHTMLDisplayContentDomain
                                              code:UAInAppMessageHTMLDisplayContentErrorCodeInvalidJSON
                                          userInfo:@{NSLocalizedDescriptionKey:msg}];
            }
            return nil;
        }
        builder.aspectLock = [aspectLock boolValue];
    }

    id requiresConnectivity = json[UAInAppMessageHTMLRequireConnectivityKey];
    if (requiresConnectivity) {
        if (![requiresConnectivity isKindOfClass:[NSNumber class]]) {
            if (error) {
                NSString *msg = [NSString stringWithFormat:@"Requires connectivity flag must be a boolean stored as an NSNumber. Invalid value: %@", requiresConnectivity];
                *error =  [NSError errorWithDomain:UAInAppMessageHTMLDisplayContentDomain
                                              code:UAInAppMessageHTMLDisplayContentErrorCodeInvalidJSON
                                          userInfo:@{NSLocalizedDescriptionKey:msg}];
            }
            return nil;
        }
        builder.requiresConnectivity = [requiresConnectivity boolValue];
    }

    if (![builder isValid]) {
        if (error) {
            NSString *msg = [NSString stringWithFormat:@"Invalid HTML display content: %@", json];
            *error =  [NSError errorWithDomain:UAInAppMessageHTMLDisplayContentDomain
                                          code:UAInAppMessageHTMLDisplayContentErrorCodeInvalidJSON
                                      userInfo:@{NSLocalizedDescriptionKey:msg}];
        }

        return nil;
    }

    return [[UAInAppMessageHTMLDisplayContent alloc] initWithBuilder:builder];
}

- (nullable instancetype)initWithBuilder:(UAInAppMessageHTMLDisplayContentBuilder *)builder {
    self = [super init];

    if (![builder isValid]) {
        UA_LERR(@"UAInAppMessageHTMLScreenDisplayContent could not be initialized, builder has missing or invalid parameters.");
        return nil;
    }

    if (self) {
        self.url = builder.url;
        self.backgroundColor = builder.backgroundColor;
        self.dismissButtonColor = builder.dismissButtonColor;
        self.allowFullScreenDisplay = builder.allowFullScreenDisplay;
        self.borderRadiusPoints = builder.borderRadiusPoints;
        self.height = builder.height;
        self.width = builder.width;
        self.aspectLock = builder.aspectLock;
        self.requireConnectivity = builder.requiresConnectivity;
    }

    return self;
}

- (NSDictionary *)toJSON {
    NSMutableDictionary *json = [NSMutableDictionary dictionary];

    [json setValue:self.url forKey:UAInAppMessageURLKey];
    [json setValue:[UAColorUtils hexStringWithColor:self.backgroundColor] forKey:UAInAppMessageBackgroundColorKey];
    [json setValue:[UAColorUtils hexStringWithColor:self.dismissButtonColor] forKey:UAInAppMessageDismissButtonColorKey];
    [json setValue:@(self.borderRadiusPoints) forKey:UAInAppMessageBorderRadiusKey];
    [json setValue:@(self.allowFullScreenDisplay) forKey:UAInAppMessageHTMLAllowsFullScreenKey];
    [json setValue:@(self.height) forKey:UAInAppMessageHTMLHeightKey];
    [json setValue:@(self.width) forKey:UAInAppMessageHTMLWidthKey];
    [json setValue:@(self.aspectLock) forKey:UAInAppMessageHTMLAspectLockKey];
    [json setValue:@(self.requireConnectivity) forKey:UAInAppMessageHTMLRequireConnectivityKey];

    return [json copy];
}

- (nullable UAInAppMessageHTMLDisplayContent *)extend:(void(^)(UAInAppMessageHTMLDisplayContentBuilder *builder))builderBlock {
    if (builderBlock) {
        UAInAppMessageHTMLDisplayContentBuilder *builder = [UAInAppMessageHTMLDisplayContentBuilder builderWithDisplayContent:self];
        builderBlock(builder);
        return [[UAInAppMessageHTMLDisplayContent alloc] initWithBuilder:builder];
    }

    UA_LDEBUG(@"Extended %@ with nil builderBlock. Returning self.", self);
    return self;
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }

    if (![object isKindOfClass:[UAInAppMessageHTMLDisplayContent class]]) {
        return NO;
    }

    return [self isEqualToInAppMessageHTMLDisplayContent:(UAInAppMessageHTMLDisplayContent *)object];
}

- (BOOL)isEqualToInAppMessageHTMLDisplayContent:(UAInAppMessageHTMLDisplayContent *)content {

    if (![content.url isEqualToString:self.url]) {
        return NO;
    }

    // Unfortunately, UIColor won't compare across color spaces. It works to convert them to hex and then compare them.

    if (content.backgroundColor != self.backgroundColor && ![[UAColorUtils hexStringWithColor:self.backgroundColor] isEqualToString:[UAColorUtils hexStringWithColor:content.backgroundColor]]) {
        return NO;
    }

    if (content.dismissButtonColor != self.dismissButtonColor && ![[UAColorUtils hexStringWithColor:self.dismissButtonColor] isEqualToString:[UAColorUtils hexStringWithColor:content.dismissButtonColor]]) {
        return NO;
    }

    if (![UAUtils float:self.borderRadiusPoints isEqualToFloat:content.borderRadiusPoints withAccuracy:0.01]) {
        return NO;
    }

    if (self.requireConnectivity != content.requireConnectivity) {
        return NO;
    }
    if (self.allowFullScreenDisplay != content.allowFullScreenDisplay) {
        return NO;
    }

    if (![UAUtils float:self.height isEqualToFloat:content.height withAccuracy:0.01]) {
        return NO;
    }

    if (![UAUtils float:self.width isEqualToFloat:content.width withAccuracy:0.01]) {
        return NO;
    }

    if (self.aspectLock != content.aspectLock) {
        return NO;
    }


    return YES;
}

- (NSUInteger)hash {
    NSUInteger result = 1;
    result = 31 * result + [self.url hash];
    result = 31 * result + [[UAColorUtils hexStringWithColor:self.backgroundColor] hash];
    result = 31 * result + [[UAColorUtils hexStringWithColor:self.dismissButtonColor] hash];
    result = 31 * result + self.borderRadiusPoints;
    result = 31 * result + self.allowFullScreenDisplay;
    result = 31 * result + self.height;
    result = 31 * result + self.width;
    result = 31 * result + self.aspectLock;
    result = 31 * result + self.requireConnectivity;

    return result;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<UAInAppMessageHTMLDisplayContent: %@>", [self toJSON]];
}

- (UAInAppMessageDisplayType)displayType {
    return UAInAppMessageDisplayTypeHTML;
}

@end
