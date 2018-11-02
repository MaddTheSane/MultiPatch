//
//  BSdiffAdapter.h
//  MultiPatch
//

#import <Foundation/Foundation.h>
#import "MPPatchAdapter.h"

extern NSErrorDomain const BSdiffAdaptorErrorDomain;
typedef NS_ERROR_ENUM(BSdiffAdaptorErrorDomain, BSdiffAdaptorError) {
	BSdiffAdaptorErrorFileOperation = 1,
	BSdiffAdaptorErrorCorruptPatch = 2,
	BSdiffAdaptorErrorOutOfMemory = 5
};

@interface BSdiffAdapter : NSObject <MPPatchAdapter>

@end
