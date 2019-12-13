#import "RCTAppleHealthKit.h"

@interface RCTAppleHealthKit (Methods_Results)

- (void)results_getBloodGlucoseSamples:(NSDictionary *)input callback:(RCTResponseSenderBlock)callback;
- (void)results_saveBloodGlucose:(NSDictionary *)input callback:(RCTResponseSenderBlock)callback;
- (void)results_getInsulinDeliverySamples:(NSDictionary *)input callback:(RCTResponseSenderBlock)callback;
- (void)results_saveInsulinDelivery:(NSDictionary *)input callback:(RCTResponseSenderBlock)callback;
@end
