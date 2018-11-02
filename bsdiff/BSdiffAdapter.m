//
//  BSdiffAdapter.m
//  MultiPatch
//

#import "BSdiffAdapter.h"

NSErrorDomain const BSdiffAdaptorErrorDomain = @"com.sappharad.MultiPatch.bsdiff.error";

@implementation BSdiffAdapter
+(void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[NSError setUserInfoValueProviderForDomain:BSdiffAdaptorErrorDomain provider:^id _Nullable(NSError * _Nonnull err, NSErrorUserInfoKey  _Nonnull userInfoKey) {
			if ([userInfoKey isEqualToString:NSLocalizedDescriptionKey]) {
				switch (err.code) {
					case BSdiffAdaptorErrorCorruptPatch:
						return @"Failed to apply BSdiff patch. Your patch file appears to be corrupt.";
						break;
						
					case BSdiffAdaptorErrorOutOfMemory:
						return @"Not enough memory to create BSDiff patch.\nInput files are probably too big.";
						break;
						
					default:
						break;
				}
			}
			
			return nil;
		}];
	});
}

extern int bspatch_perform(char* oldfile, char* newfile, char* patchfile);
extern int bsdiff_perform(char* oldfile, char* newfile, char* patchfile);

+ (BOOL)applyPatchAtURL:(NSURL *)patch toFileURL:(NSURL *)input destination:(NSURL *)output error:(NSError **)error { 
	int err = bspatch_perform((char*)[input fileSystemRepresentation], (char*)[output fileSystemRepresentation], (char*)[patch fileSystemRepresentation]);
	if(err > 0){
		if (error) {
			*error = [NSError errorWithDomain:BSdiffAdaptorErrorDomain code:err userInfo:nil];
		}
		/*
		if(err==2)
			return @"Failed to apply BSdiff patch. Your patch file appears to be corrupt.";
		return @"Failed to apply BSdiff patch!";
		 */
		
		return NO;
	}
	
	return YES;
}

+ (BOOL)createPatchUsingSourceURL:(NSURL *)orig modifiedFileURL:(NSURL *)modify destination:(NSURL *)output error:(NSError **)error { 
	int err = bsdiff_perform((char*)[orig fileSystemRepresentation], (char*)[modify fileSystemRepresentation], (char*)[output fileSystemRepresentation]);
	if(err > 0){
		/*
		if(err == 5)
			return @"Not enough memory to create BSDiff patch.\nInput files are probably too big.";
		return @"Failed to create BSdiff patch!";
		 */
		if (error) {
			*error = [NSError errorWithDomain:BSdiffAdaptorErrorDomain code:err userInfo:nil];
		}
		return NO;
	}
	
	return YES;
}

@end
