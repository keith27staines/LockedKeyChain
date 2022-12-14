/* Copyright Airship and Contributors */

#import "UAActionResult.h"

@interface UAActionResult()
@property (nonatomic, strong, nullable) id value;
@property (nonatomic, assign) UAActionFetchResult fetchResult;
@property (nonatomic, strong, nullable) NSError *error;
@property (nonatomic, assign) UAActionStatus status;
@end

@implementation UAActionResult

- (instancetype)initWithValue:(id)value
              withFetchResult:(UAActionFetchResult)fetchResult
                   withStatus:(UAActionStatus) status {

    self = [super init];
    if (self) {
        self.value = value;
        self.fetchResult = fetchResult;
        self.status = status;
    }

    return self;
}

+ (instancetype)resultWithValue:(id)value {
    return [self resultWithValue:value withFetchResult:UAActionFetchResultNoData];
}

+ (instancetype)resultWithValue:(id)value
                 withFetchResult:(UAActionFetchResult)fetchResult {
    return [[self alloc] initWithValue:value
                       withFetchResult:fetchResult
                            withStatus:UAActionStatusCompleted];
}

+ (instancetype)emptyResult {
    return [self resultWithValue:nil withFetchResult:UAActionFetchResultNoData];
}


+ (instancetype)resultWithError:(NSError *)error
                withFetchResult:(UAActionFetchResult)fetchResult {
    UAActionResult *result = [[self alloc] initWithValue:nil
                                         withFetchResult:fetchResult
                                              withStatus:UAActionStatusError];
    result.error = error;
    return result;
}

+ (instancetype)resultWithError:(NSError *)error {
    return [self resultWithError:error withFetchResult:UAActionFetchResultNoData];
}

+ (instancetype)rejectedArgumentsResult {
    return [[self alloc] initWithValue:nil
                       withFetchResult:UAActionFetchResultNoData
                            withStatus:UAActionStatusArgumentsRejected];
}

+ (instancetype)actionNotFoundResult {
    return [[self alloc] initWithValue:nil
                       withFetchResult:UAActionFetchResultNoData
                            withStatus:UAActionStatusActionNotFound];
}
@end
