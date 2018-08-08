//
//  BSdiffAdapter.h
//  MultiPatch
//

#import <Foundation/Foundation.h>
#import "MPPatchAdaptor.h"

extern NSErrorDomain const BSdiffAdaptorErrorDomain;

@interface BSdiffAdapter : NSObject <MPPatchAdaptor>
    +(NSString*)applyPatch:(NSString*)patch toFile:(NSString*)input andCreate:(NSString*)output;
    +(NSString*)createPatch:(NSString*)orig withMod:(NSString*)modify andCreate:(NSString*)output;
@end
