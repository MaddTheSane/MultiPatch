//
//  IPSAdapter.h
//  MultiPatch
//

#import <Foundation/Foundation.h>
#import "MPPatchAdapter.h"

extern NSErrorDomain const IPSAdapterErrorDomain;
typedef NS_ERROR_ENUM(IPSAdapterErrorDomain, IPSAdapterError) {
	IPSAdapterErrorApplyingPatch = 1,
	IPSAdapterErrorCreatingPatch
};

@interface IPSAdapter : NSObject <MPPatchAdapter>

@end
