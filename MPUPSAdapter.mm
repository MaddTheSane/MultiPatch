//
//  MPUPSAdapter.m
//  MultiPatcher
//
//  Created by C.W. Betts on 8/9/18.
//

#import "MPUPSAdapter.h"
#include "libups.hpp"

@implementation MPUPSAdapter

+ (BOOL)applyPatchAtURL:(NSURL *)patch toFileURL:(NSURL *)input destination:(NSURL *)output error:(NSError **)error { 
	UPS ups; //UPS Patcher
	bool result = ups.apply([input fileSystemRepresentation], [output fileSystemRepresentation], [patch fileSystemRepresentation]);
	if (!result) {
		if (error) {
			*error = [NSError errorWithDomain:NSCocoaErrorDomain code:1 userInfo:@{NSLocalizedDescriptionKey:@(ups.error)}];
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
			*error = [NSError errorWithDomain:NSCocoaErrorDomain code:1 userInfo:@{NSLocalizedDescriptionKey:@(ups.error)}];
		}
		return NO;
	}
	return YES;
}

@end
