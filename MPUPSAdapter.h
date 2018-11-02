//
//  MPUPSAdapter.h
//  MultiPatcher
//
//  Created by C.W. Betts on 8/9/18.
//

#import <Foundation/Foundation.h>
#import "MPPatchAdapter.h"

extern NSErrorDomain const MPUPSErrorDomain;
typedef NS_ERROR_ENUM(MPUPSErrorDomain, MPUPSError) {
	MPUPSErrorGeneric = 1
};

@interface MPUPSAdapter : NSObject <MPPatchAdapter>

@end
