//
//  XDeltaAdapter.h
//  MultiPatch
//
//  Created by Paul Kratt on 7/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPPatchAdapter.h"

extern NSErrorDomain const XDeltaErrorDomain;

@interface XDeltaAdapter : NSObject <MPPatchAdapter>
+(NSString*)applyPatch:(NSString*)patch toFile:(NSString*)input andCreate:(NSString*)output;
+(NSString*)createPatch:(NSString*)orig withMod:(NSString*)modify andCreate:(NSString*)output;
@end
