//
//  BPSAdapter.h
//  MultiPatch
//

#import <Foundation/Foundation.h>

@interface BPSAdapter : NSObject
+ (NSString*)applyPatch:(NSString*)patch toFile:(NSString*)input andCreate:(NSString*)output;
+ (NSString*)createPatchLinear:(NSString*)orig withMod:(NSString*)modify andCreate:(NSString*)output;
+ (NSString*)createPatchDelta:(NSString*)orig withMod:(NSString*)modify andCreate:(NSString*)output;
@end
