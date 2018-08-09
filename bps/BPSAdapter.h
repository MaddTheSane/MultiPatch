//
//  BPSAdapter.h
//  MultiPatch
//

#import <Foundation/Foundation.h>
#import "MPPatchAdapter.h"

extern NSErrorDomain const BPSAdapterErrorDomain;

@interface BPSAdapter : NSObject <MPPatchAdapter>
+ (NSString*)applyPatch:(NSString*)patch toFile:(NSString*)input andCreate:(NSString*)output;
+ (NSString*)createPatchLinear:(NSString*)orig withMod:(NSString*)modify andCreate:(NSString*)output;
+ (NSString*)createPatchDelta:(NSString*)orig withMod:(NSString*)modify andCreate:(NSString*)output;
+ (BOOL)createLinearPatchUsingSourceURL:(NSURL *)orig modifiedFileURL:(NSURL *)modify destination:(NSURL *)output error:(NSError **)error;
+ (BOOL)createDeltaPatchUsingSourceURL:(NSURL *)orig modifiedFileURL:(NSURL *)modify destination:(NSURL *)output error:(NSError **)error;
@end
