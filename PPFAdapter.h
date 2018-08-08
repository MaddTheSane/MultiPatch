//
//  PPFAdapter.h
//  MultiPatch
//

#import <Foundation/Foundation.h>
#import "MPPatchAdaptor.h"

extern NSErrorDomain const PPFAdaptorErrorDomain;
typedef NS_ERROR_ENUM(PPFAdaptorErrorDomain, PPFAdaptorError) {
	PPFAdaptorErrorFormat = 0x01,
	PPFAdaptorErrorVersion = 0x02,
	PPFAdaptorErrorExists = 0x03,
	PPFAdaptorErrorOpen = 0x04,
	PPFAdaptorErrorClose = 0x05,
	PPFAdaptorErrorRead = 0x06,
	PPFAdaptorErrorLoaded = 0x07,
	PPFAdaptorErrorUndo = 0x08,
	
	PPFAdaptorErrorFileExists = 0x11,
	PPFAdaptorErrorFileOpen = 0x12,
	PPFAdaptorErrorFileClose = 0x13,
	PPFAdaptorErrorFileRead = 0x14,
	PPFAdaptorErrorFileWrite = 0x15
};

@interface PPFAdapter : NSObject <MPPatchAdaptor>
+(NSString*)errorMsg:(int)error;
+(NSString*)applyPatch:(NSString*)patch toFile:(NSString*)input andCreate:(NSString*)output;
+(NSString*)createPatch:(NSString*)orig withMod:(NSString*)modify andCreate:(NSString*)output;
@end
