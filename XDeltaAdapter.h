//
//  XDeltaAdapter.h
//  MultiPatch
//
//  Created by Paul Kratt on 7/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPPatchAdapter.h"
#import "MPPatchResult.h"

extern NSErrorDomain const XDeltaErrorDomain;

@interface XDeltaAdapter : NSObject <MPPatchAdapter>

+(MPPatchResult*)ApplyPatch:(NSString*)patch toFile:(NSString*)input andCreate:(NSString*)output;
//int code (int encode, FILE* InFile, FILE* SrcFile, FILE* OutFile, int BufSize);
+(MPPatchResult*)CreatePatch:(NSString*)orig withMod:(NSString*)modify andCreate:(NSString*)output;
@end
