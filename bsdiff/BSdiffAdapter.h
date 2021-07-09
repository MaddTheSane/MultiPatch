//
//  BSdiffAdapter.h
//  MultiPatch
//

#import <Foundation/Foundation.h>
#import "MPPatchAdapter.h"
#import "MPPatchResult.h"

extern NSErrorDomain const BSdiffAdaptorErrorDomain;
typedef NS_ERROR_ENUM(BSdiffAdaptorErrorDomain, BSdiffAdaptorError) {
	BSdiffAdaptorErrorFileOperation = 1,
	BSdiffAdaptorErrorCorruptPatch = 2,
	BSdiffAdaptorErrorOutOfMemory = 5
};

@interface BSdiffAdapter : NSObject <MPPatchAdapter>
    +(MPPatchResult*)ApplyPatch:(NSString*)patch toFile:(NSString*)input andCreate:(NSString*)output;
    +(MPPatchResult*)CreatePatch:(NSString*)orig withMod:(NSString*)modify andCreate:(NSString*)output;
@end
