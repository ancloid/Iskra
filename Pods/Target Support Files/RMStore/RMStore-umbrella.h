#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "RMStore.h"
#import "RMStoreKeychainPersistence.h"
#import "RMStoreUserDefaultsPersistence.h"
#import "RMStoreTransaction.h"

FOUNDATION_EXPORT double RMStoreVersionNumber;
FOUNDATION_EXPORT const unsigned char RMStoreVersionString[];

