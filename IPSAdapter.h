//
//  IPSAdapter.h
//  MultiPatch
//

#import <Cocoa/Cocoa.h>


@interface IPSAdapter : NSObject {}
+(NSString*)applyPatch:(NSString*)patch toFile:(NSString*)input andCreate:(NSString*)output;
+(NSString*)createPatch:(NSString*)orig withMod:(NSString*)modify andCreate:(NSString*)output;
@end
