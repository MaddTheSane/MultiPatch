//
//  PPFAdapter.m
//  MultiPatch
//

#import "PPFAdapter.h"
#include "libppf.hh"

NSErrorDomain const PPFAdaptorErrorDomain = @"com.sappharad.MultiPatch.ppf.error";

@implementation PPFAdapter

+(void)initialize
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[NSError setUserInfoValueProviderForDomain:PPFAdaptorErrorDomain provider:^id _Nullable(NSError * _Nonnull err, NSErrorUserInfoKey  _Nonnull userInfoKey) {
			if ([userInfoKey isEqualToString:NSLocalizedDescriptionKey]) {
				return [PPFAdapter errorMsg:(int)err.code];
			}
			
			return nil;
		}];
	});
}

+(NSString*)errorMsg:(int)error{
	switch (error) {
		case ERROR_PPF_FORMAT:
			return @"Selected patch file is NOT a PPF file!";
		case ERROR_PPF_VERSION:
			return @"PPF version not supported or unknown.";
		case ERROR_PPF_EXISTS:
			return @"PPF file not found!";
		case ERROR_PPF_OPEN:
			return @"Error opening PPF file.";
		case ERROR_PPF_CLOSE:
			return @"Error closing PPF file.";
		case ERROR_PPF_READ:
			return @"Error reading from PPF file.";
		case ERROR_PPF_LOADED:
			return @"PPF file hasn't been loaded";
		case ERROR_PPF_UNDO:
			return @"No undo data available";
		case ERROR_ISO_EXISTS:
			return @"Input file not found.";
		case ERROR_ISO_OPEN:
			return @"Error opening file.";
		case ERROR_ISO_CLOSE:
			return @"Error closing output file.";
		case ERROR_ISO_READ:
			return @"Error reading from input!";
		case ERROR_ISO_WRITE:
			return @"Error writing to output file!";
		default:
			return @"Unknown error code!";
	}
}

+(NSString*)applyPatch:(NSString*)patch toFile:(NSString*)input andCreate:(NSString*)output{
	lppf::LibPPF ppf;
	int error;
	
	if ((error = ppf.loadPatch([patch fileSystemRepresentation])) != 0) {
		return [self errorMsg:error];
	}
	
	if(![input isEqualToString:output]){
		NSFileManager* fileMan = [NSFileManager defaultManager];
        NSError* error;
        if(![fileMan copyItemAtPath:input toPath:output error:&error])
		{
			return @"Unable to open original file or write to output file.";
		}
	}
	
	// Apply PPF data to file
	if ((error = ppf.applyPatch([output fileSystemRepresentation], false)) != 0) {
		return [self errorMsg:error];
	}
	return nil; //Success!
}

+(NSString*)createPatch:(NSString*)orig withMod:(NSString*)modify andCreate:(NSString*)output{
    return @"Oops, PPF creation not supported."; //Success! :-(
}
+ (BOOL)applyPatch:(NSURL *)patch toFile:(NSURL *)input andCreate:(NSURL *)output error:(NSError **)outError {
	lppf::LibPPF ppf;
	int error;
	
	if ((error = ppf.loadPatch([patch fileSystemRepresentation])) != 0) {
		if (outError) {
			*outError = [NSError errorWithDomain:PPFAdaptorErrorDomain code:error userInfo:nil];
		}
		return NO;
	}
	
	if(![input isEqual:output]){
		NSFileManager* fileMan = [NSFileManager defaultManager];
		if(![fileMan copyItemAtURL:input toURL:output error:outError])
		{
			return NO;
		}
	}
	
	// Apply PPF data to file
	if ((error = ppf.applyPatch([output fileSystemRepresentation], false)) != 0) {
		if (outError) {
			*outError = [NSError errorWithDomain:PPFAdaptorErrorDomain code:error userInfo:nil];
		}
		return NO;
	}
	return YES; //Success!
}

+ (BOOL)createPatch:(NSURL *)orig withMod:(NSURL *)modify andCreate:(NSURL *)output error:(NSError **)error {
	if (error) {
		*error = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:nil];
	}
	
	return NO;
}

@end
