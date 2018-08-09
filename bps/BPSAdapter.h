//
//  BPSAdapter.h
//  MultiPatch
//

#import <Foundation/Foundation.h>
#import "MPPatchAdapter.h"

extern NSErrorDomain const BPSAdapterErrorDomain;

@interface BPSAdapter : NSObject <MPPatchAdapter>
+ (BOOL)createLinearPatchUsingSourceURL:(NSURL *)orig modifiedFileURL:(NSURL *)modify destination:(NSURL *)output error:(NSError **)error;
+ (BOOL)createDeltaPatchUsingSourceURL:(NSURL *)orig modifiedFileURL:(NSURL *)modify destination:(NSURL *)output error:(NSError **)error;
@end
