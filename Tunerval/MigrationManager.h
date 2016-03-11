//
//  MigrationManager.h
//  Tunerval
//
//  Created by Sam Bender on 3/9/16.
//  Copyright © 2016 Sam Bender. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MigrationManager : NSObject

+ (void) checkForAndPerformPendingMigrations;

@end
