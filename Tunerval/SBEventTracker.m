//
//  SBEventTracker.m
//  Tunerval
//
//  Created by Sam Bender on 9/8/16.
//  Copyright © 2016 Sam Bender. All rights reserved.
//

@import StoreKit;
#import <AWSMobileAnalytics/AWSMobileAnalytics.h>
#import "SBEventTracker.h"
#import "Constants.h"

@interface SBEventTracker()

@property (nonatomic, strong) id<AWSMobileAnalyticsEventClient> eventClient;

@end

@implementation SBEventTracker

+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static SBEventTracker *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[SBEventTracker alloc] init];
        if (DEBUGMODE == NO) {
            sharedInstance.eventClient = [MOBILE_ANALYTICS eventClient];
        }
    });
    return sharedInstance;
}

+ (void)trackAppOpenFromPushNotificationWithLaunchOptions:(NSDictionary*)dict
{
    if (DEBUGMODE == YES) {
        return;
    }
    
    if ([dict valueForKey:UIApplicationLaunchOptionsLocalNotificationKey]) {
        id<AWSMobileAnalyticsEventClient> eventClient = [SBEventTracker sharedInstance].eventClient;
        id<AWSMobileAnalyticsEvent> screenViewEvent = [eventClient createEventWithEventType:@"OpenFromReminder"];
        [eventClient recordEvent:screenViewEvent];
    }
}

+ (void)trackScreenViewForScreenName:(NSString*)screenName
{
    if (!screenName || DEBUGMODE == YES) {
        return;
    }
    
    id<AWSMobileAnalyticsEventClient> eventClient = [SBEventTracker sharedInstance].eventClient;
    id<AWSMobileAnalyticsEvent> screenViewEvent = [eventClient createEventWithEventType:@"ScreenView"];
    [screenViewEvent addAttribute:@"ScreenName" forKey:screenName];
    [eventClient recordEvent:screenViewEvent];
}

+ (void)trackDailyGoalComplete
{
    if (DEBUGMODE == YES) {
        return;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger dailyQuestionGoal = [[defaults objectForKey:@"daily-goal"] integerValue];
    NSInteger daysGoalMet = [defaults integerForKey:@"total-days-goal-met"];
    
    id<AWSMobileAnalyticsEventClient> eventClient = [SBEventTracker sharedInstance].eventClient;
    id<AWSMobileAnalyticsEvent> dailyGoalEvent = [eventClient
                                                  createEventWithEventType:@"DailyGoalComplete"];
    [dailyGoalEvent addMetric:@(dailyQuestionGoal) forKey:@"DailyQuestionGoal"];
    [dailyGoalEvent addMetric:@(daysGoalMet) forKey:@"total-days-goal-met"];
    [eventClient recordEvent:dailyGoalEvent];
    [eventClient submitEvents];
}

+ (void)trackAskForReminderWithValue:(BOOL)accepted
{
    if (DEBUGMODE == YES) {
        return;
    }
    
    id<AWSMobileAnalyticsEventClient> eventClient = [SBEventTracker sharedInstance].eventClient;
    id<AWSMobileAnalyticsEvent> askForReminderEvent = [eventClient
                                                       createEventWithEventType:@"AskForReminder"];
    
    [askForReminderEvent addMetric:@(accepted ? 1.0 : 0.0) forKey:@"Answer"];
    [eventClient recordEvent:askForReminderEvent];
    [eventClient submitEvents];
}

+ (void)trackInstrumentPurchaseWithTransaction:(SKPaymentTransaction*)transaction productCatalog:(NSMutableDictionary<NSString*,SKProduct*>*)productCatalog;
{
    if (DEBUGMODE == YES) {
        return;
    }
    
    SKProduct *product = [productCatalog objectForKey:transaction.payment.productIdentifier];
    
    // get the event client for the builder
    id<AWSMobileAnalyticsEventClient> eventClient = [SBEventTracker sharedInstance].eventClient;
    
    // create a builder that can record purchase events from Apple
    AWSMobileAnalyticsAppleMonetizationEventBuilder* builder = [AWSMobileAnalyticsAppleMonetizationEventBuilder builderWithEventClient:eventClient];
    
    // set the product id of the purchased item (obtained from the SKPurchaseTransaction object)
    [builder withProductId:transaction.payment.productIdentifier];
    
    // set the item price and price locale (obtained from the SKProduct object)
    [builder withItemPrice:[product.price doubleValue]
            andPriceLocale:product.priceLocale];
    
    // set the quantity of item(s) purchased (obtained from the SKPurchaseTransaction object)
    [builder withQuantity:transaction.payment.quantity];
    
    // set the transactionId of the transaction (obtained from the SKPurchaseTransaction object)
    [builder withTransactionId:transaction.transactionIdentifier];
    
    // build the monetization event
    id<AWSMobileAnalyticsEvent> purchaseEvent = [builder build];
    
    // add any additional metrics/attributes and record
    [eventClient recordEvent:purchaseEvent];
    [eventClient submitEvents];
}

+ (void)trackError:(NSError*)error
{
    if (DEBUGMODE == YES) {
        return;
    }
    
    id<AWSMobileAnalyticsEventClient> eventClient = [SBEventTracker sharedInstance].eventClient;
    id<AWSMobileAnalyticsEvent> errorEvent = [eventClient
                                              createEventWithEventType:@"Error"];
    
    [errorEvent addAttribute:[error localizedDescription] forKey:@"description"];
    [eventClient recordEvent:errorEvent];
    [eventClient submitEvents];
}

+ (void)trackEvent:(NSString*)eventName attributeName:(NSString*)name attributeMsg:(NSString*)msg;
{
    if (DEBUGMODE == YES) {
        return;
    }
    
    id<AWSMobileAnalyticsEventClient> eventClient = [SBEventTracker sharedInstance].eventClient;
    id<AWSMobileAnalyticsEvent> errorEvent = [eventClient
                                              createEventWithEventType:eventName];
    
    [errorEvent addAttribute:msg forKey:name];
    [eventClient recordEvent:errorEvent];
    [eventClient submitEvents];
}

@end
