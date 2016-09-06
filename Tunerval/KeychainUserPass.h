// https://developer.apple.com/library/ios/documentation/security/conceptual/keychainServConcepts/iPhoneTasks/iPhoneTasks.html
// Apples version
// This version is from http://stackoverflow.com/questions/5247912/saving-email-password-to-keychain-in-ios

#import <Foundation/Foundation.h>

@interface KeychainUserPass : NSObject

+ (void)save:(NSString *)service data:(id)data;
+ (id)load:(NSString *)service;
+ (void)delete:(NSString *)service;

@end
