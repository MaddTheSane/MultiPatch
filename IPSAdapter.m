//
//  IPSAdapter.m
//  MultiPatch
//

#import "IPSAdapter.h"
#include "uips/uips.c"

NSErrorDomain const IPSAdapterErrorDomain = @"com.sappharad.MultiPatch.ips.error";

@implementation IPSAdapter
+ (BOOL)applyPatchAtURL:(NSURL *)patch toFileURL:(NSURL *)input destination:(NSURL *)output error:(NSError **)error {
	if(![input isEqual:output]){
		NSFileManager* fileMan = [NSFileManager defaultManager];
		if(![fileMan copyItemAtURL:input toURL:output error:error])
		{
			return NO;
			//return @"Unable to open original file or write to output file.";
		}
	}
	
	int err = apply_patch([patch fileSystemRepresentation], [output fileSystemRepresentation]);
	if(err == 1){
		if (error) {
			*error = [NSError errorWithDomain:IPSAdapterErrorDomain code:1 userInfo:nil];
		}
		return NO;
		//return @"Failed to apply IPS patch!";
	}
	
	return YES;
}

+ (BOOL)createPatchUsingSourceURL:(NSURL *)orig modifiedFileURL:(NSURL *)modify destination:(NSURL *)output error:(NSError **)error {
	const char* listOfOne[1];
	listOfOne[0] = (const char*)[orig fileSystemRepresentation];
	int err = create_patch([output fileSystemRepresentation], 1, (const char**)listOfOne, [modify fileSystemRepresentation]);
	if(err == 1){
		if (error) {
			*error = [NSError errorWithDomain:IPSAdapterErrorDomain code:2 userInfo:nil];
		}

		return NO;
		//return @"Failed to create IPS patch!";
	}
	
	return YES;
}

@end
