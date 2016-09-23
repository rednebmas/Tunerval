//
//  SBEventTracker.h
//  Tunerval
//
//  Created by Sam Bender on 9/8/16.
//  Copyright © 2016 Sam Bender. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SKPaymentTransaction, SKProduct;

@interface SBEventTracker : NSObject

+ (void)trackScreenViewForScreenName:(NSString*)screenName;
+ (void)trackDailyGoalComplete;
+ (void)trackInstrumentPurchaseWithTransaction:(SKPaymentTransaction*)transaction productCatalog:(NSMutableDictionary<NSString*,SKProduct*>*)productCatalog;

@end
