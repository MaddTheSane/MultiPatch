//
//  MPUPSAdapter.m
//  MultiPatcher
//
//  Created by C.W. Betts on 8/9/18.
//

#import "MPUPSAdapter.h"
#include "libups.hpp"

NSErrorDomain const MPUPSErrorDomain = @"com.sappharad.MultiPatch.ups.error";

@implementation MPUPSAdapter

+ (BOOL)applyPatchAtURL:(NSURL *)patch toFileURL:(NSURL *)input destination:(NSURL *)output error:(NSError **)error { 
	UPS ups; //UPS Patcher
	bool result = ups.apply([input fileSystemRepresentation], [output fileSystemRepresentation], [patch fileSystemRepresentation]);
	if (!result) {
		if (error) {
			*error = [NSError errorWithDomain:MPUPSErrorDomain code:MPUPSErrorGeneric userInfo:@{NSLocalizedDescriptionKey:@(ups.error)}];
		}
		return NO;
	}
	return YES;
}

+ (BOOL)createPatchUsingSourceURL:(NSURL *)orig modifiedFileURL:(NSURL *)modify destination:(NSURL *)output error:(NSError **)error { 
	UPS ups; //UPS Patcher
	bool result = ups.create([orig fileSystemRepresentation], [modify fileSystemRepresentation], [output fileSystemRepresentation]);
	if (result == false) {
		if (error) {
			*error = [NSError errorWithDomain:MPUPSErrorDomain code:MPUPSErrorGeneric userInfo:@{NSLocalizedDescriptionKey:@(ups.error)}];
		}
		return NO;
	}
	return YES;
}

@end
