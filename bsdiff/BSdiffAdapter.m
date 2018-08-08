//
//  BSdiffAdapter.m
//  MultiPatch
//

#import "BSdiffAdapter.h"

@implementation BSdiffAdapter

extern int bspatch_perform(char* oldfile, char* newfile, char* patchfile);
extern int bsdiff_perform(char* oldfile, char* newfile, char* patchfile);

+(NSString*)applyPatch:(NSString*)patch toFile:(NSString*)input andCreate:(NSString*)output{
    int err = bspatch_perform((char*)[input fileSystemRepresentation], (char*)[output fileSystemRepresentation], (char*)[patch fileSystemRepresentation]);
	if(err > 0){
		if(err==2)
			return @"Failed to apply BSdiff patch. Your patch file appears to be corrupt.";
		return @"Failed to apply BSdiff patch!";
    }
	
    return nil;
}

+(NSString*)createPatch:(NSString*)orig withMod:(NSString*)modify andCreate:(NSString*)output{
    int err = bsdiff_perform((char*)[orig fileSystemRepresentation], (char*)[modify fileSystemRepresentation], (char*)[output fileSystemRepresentation]);
    if(err > 0){
		if(err == 5)
			return @"Not enough memory to create BSDiff patch.\nInput files are probably too big.";
		return @"Failed to create BSdiff patch!";
    }
	
    return nil;
}
@end
