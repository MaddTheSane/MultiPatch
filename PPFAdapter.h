//
//  PPFAdapter.h
//  MultiPatch
//

#import <Cocoa/Cocoa.h>

@interface PPFAdapter : NSObject {}
+(NSString*)errorMsg:(int)error;
+(NSString*)applyPatch:(NSString*)patch toFile:(NSString*)input andCreate:(NSString*)output;
+(NSString*)createPatch:(NSString*)orig withMod:(NSString*)modify andCreate:(NSString*)output;
@end
