//
//  IPSAdapter.m
//  MultiPatch
//

#import "IPSAdapter.h"
#include "uips/uips.c"


@implementation IPSAdapter
+(NSString*)applyPatch:(NSString*)patch toFile:(NSString*)input andCreate:(NSString*)output{
	if(![input isEqualToString:output]){
		NSFileManager* fileMan = [NSFileManager defaultManager];
        NSError* error;
        if(![fileMan copyItemAtPath:input toPath:output error:&error])
		{
			return @"Unable to open original file or write to output file.";
		}
	}
    
    int err = apply_patch([patch fileSystemRepresentation], [output fileSystemRepresentation]);
    if(err == 1){
        return @"Failed to apply IPS patch!";
    }
	
    return nil;
}

+(NSString*)createPatch:(NSString*)orig withMod:(NSString*)modify andCreate:(NSString*)output{
	const char* listOfOne[1];
    listOfOne[0] = (const char*)[orig fileSystemRepresentation];
    int err = create_patch([output fileSystemRepresentation], 1, (const char**)listOfOne, [modify fileSystemRepresentation]);
    if(err == 1){
        return @"Failed to create IPS patch!";
    }
	
    return nil;
}
@end
