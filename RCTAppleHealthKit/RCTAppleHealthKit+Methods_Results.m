#import "RCTAppleHealthKit+Methods_Results.h"
#import "RCTAppleHealthKit+Queries.h"
#import "RCTAppleHealthKit+Utils.h"

@implementation RCTAppleHealthKit (Methods_Results)


- (void)results_getBloodGlucoseSamples:(NSDictionary *)input callback:(RCTResponseSenderBlock)callback
{
    HKQuantityType *bloodGlucoseType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodGlucose];

    HKUnit *mmoLPerL = [[HKUnit moleUnitWithMetricPrefix:HKMetricPrefixMilli molarMass:HKUnitMolarMassBloodGlucose] unitDividedByUnit:[HKUnit literUnit]];

    HKUnit *unit = [RCTAppleHealthKit hkUnitFromOptions:input key:@"unit" withDefault:mmoLPerL];
    NSUInteger limit = [RCTAppleHealthKit uintFromOptions:input key:@"limit" withDefault:HKObjectQueryNoLimit];
    BOOL ascending = [RCTAppleHealthKit boolFromOptions:input key:@"ascending" withDefault:false];
    NSDate *startDate = [RCTAppleHealthKit dateFromOptions:input key:@"startDate" withDefault:nil];
    NSDate *endDate = [RCTAppleHealthKit dateFromOptions:input key:@"endDate" withDefault:[NSDate date]];
    if(startDate == nil){
        callback(@[RCTMakeError(@"startDate is required in options", nil, nil)]);
        return;
    }
    
    NSPredicate * predicate = [RCTAppleHealthKit predicateForSamplesBetweenDates:startDate endDate:endDate];

    [self fetchQuantitySamplesOfType:bloodGlucoseType
                                unit:unit
                           predicate:predicate
                           ascending:ascending
                               limit:limit
                          completion:^(NSArray *results, NSError *error) {
        
        if(results){
            callback(@[[NSNull null], results]);
            return;
        } else {
            callback(@[RCTJSErrorFromNSError(error)]);
            return;
        }
    }];
}

- (void)results_getInsulinDeliverySamples:(NSDictionary *)input callback:(RCTResponseSenderBlock)callback
{
    HKQuantityType *insulinDeliveryType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierInsulinDelivery];

    NSUInteger limit = [RCTAppleHealthKit uintFromOptions:input key:@"limit" withDefault:HKObjectQueryNoLimit];
    BOOL ascending = [RCTAppleHealthKit boolFromOptions:input key:@"ascending" withDefault:false];
    NSDate *startDate = [RCTAppleHealthKit dateFromOptions:input key:@"startDate" withDefault:nil];
    NSDate *endDate = [RCTAppleHealthKit dateFromOptions:input key:@"endDate" withDefault:[NSDate date]];
    NSString *reason = [RCTAppleHealthKit stringFromOptions:input key:@"reason" withDefault:nil];
    NSUInteger period = [RCTAppleHealthKit uintFromOptions:input key:@"period" withDefault:60];
    if(startDate == nil){
        callback(@[RCTMakeError(@"startDate is required in options", nil, nil)]);
        return;
    }
    if(reason == nil){
        callback(@[RCTMakeError(@"reason is required in options", nil, nil)]);
        return;
    }
    if ([reason isEqualToString:@"Bolus"] && [reason isEqualToString:@"Basal"]) {
        callback(@[RCTMakeError(@"Invalid reason value in options", nil, nil)]);
        return;
    }
    NSPredicate * predicate = [HKQuery predicateForObjectsWithMetadataKey:HKMetadataKeyInsulinDeliveryReason
                                                            allowedValues:@[[reason isEqualToString:@"Basal"] ? @(HKInsulinDeliveryReasonBasal) : @(HKInsulinDeliveryReasonBolus)]];

    [self fetchCumulativeSumStatisticsCollection:insulinDeliveryType
                                            unit:[HKUnit internationalUnit]
                                          period:period
                                       startDate:startDate
                                         endDate:endDate
                                       ascending:ascending
                                           limit:limit
                                       predicate:predicate
                                      completion:^(NSArray *arr, NSError *err){
                                          if (err != nil) {
                                              callback(@[RCTJSErrorFromNSError(err)]);
                                              return;
                                          }
                                          callback(@[[NSNull null], arr]);
    }];
    
}

- (void)results_saveBloodGlucose:(NSDictionary *)input callback:(RCTResponseSenderBlock)callback {
    double quantity = [RCTAppleHealthKit doubleValueFromOptions:input];
    NSDate *sampleDate = [RCTAppleHealthKit dateFromOptions:input key:@"startDate" withDefault:[NSDate date]];
    HKUnit *unit = [HKUnit unitFromString:@"mg/dL"];

    HKQuantity *bloodGlucoseQuantity = [HKQuantity quantityWithUnit:unit doubleValue:quantity];
    HKQuantityType *bloodGlucoseType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodGlucose];
    HKQuantitySample *bloodGlucoseSample = [HKQuantitySample quantitySampleWithType:bloodGlucoseType quantity:bloodGlucoseQuantity startDate:sampleDate endDate:sampleDate];

    [self.healthStore saveObject:bloodGlucoseSample withCompletion:^(BOOL success, NSError *error) {
        if (!success) {
            NSLog(@"error saving blood glucose sample: %@", error);
            callback(@[RCTMakeError(@"error saving blood glucose sample", error, nil)]);
            return;
        }
        callback(@[[NSNull null], @(quantity)]);
    }];
}

- (void)results_saveInsulinDelivery:(NSDictionary *)input callback:(RCTResponseSenderBlock)callback {
    double value = [RCTAppleHealthKit doubleValueFromOptions:input];
    NSDate *sampleDate = [RCTAppleHealthKit dateFromOptions:input key:@"startDate" withDefault:[NSDate date]];
    NSString *reason = [RCTAppleHealthKit stringFromOptions:input key:@"reason" withDefault:nil];
    
    if (reason == nil) {
        callback(@[RCTMakeError(@"reason is required in options", nil, nil)]);
        return;
    }
    if (![reason isEqualToString:@"Basal"] && ![reason isEqualToString:@"Bolus"]) {
        callback(@[RCTMakeError(@"Invalid reason value in options", nil, nil)]);
        return;
    }
    
    HKInsulinDeliveryReason deliveryReason = [reason isEqualToString:@"Basal"] ? HKInsulinDeliveryReasonBasal : HKInsulinDeliveryReasonBolus;

    HKQuantity *quantity = [HKQuantity quantityWithUnit:[HKUnit internationalUnit] doubleValue:value];
    HKQuantityType *insulinType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierInsulinDelivery];
    HKQuantitySample *insulinSample = [HKQuantitySample quantitySampleWithType:insulinType quantity:quantity startDate:sampleDate endDate:sampleDate metadata:@{HKMetadataKeyInsulinDeliveryReason: @(deliveryReason)}];

    [self.healthStore saveObject:insulinSample withCompletion:^(BOOL success, NSError *error) {
        if (!success) {
            callback(@[RCTJSErrorFromNSError(error)]);
            return;
        }
        callback(@[[NSNull null], @(value)]);
    }];
}

@end
