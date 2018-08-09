//
//  BPSAdapter.m
//  MultiPatch
//

#import "BPSAdapter.h"
#import "patch.hpp"
#import "linear.hpp"
#import "delta.hpp"

NSErrorDomain const BPSAdapterErrorDomain = @"com.sappharad.MultiPatch.bps.error";

@implementation BPSAdapter

+ (void)initialize
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[NSError setUserInfoValueProviderForDomain:BPSAdapterErrorDomain provider:^id _Nullable(NSError * _Nonnull err, NSErrorUserInfoKey  _Nonnull userInfoKey) {
			if ([userInfoKey isEqualToString:NSLocalizedDescriptionKey]) {
				return [BPSAdapter TranslateBPSresult:(nall::bpspatch::result)err.code];
			}
			
			return nil;
		}];
	});
}

+ (NSString*)TranslateBPSresult:(nall::bpspatch::result)result{
    NSString* retval = nil;
    switch (result) {
        case nall::bpspatch::result::patch_checksum_invalid:
            retval = @"The patch checksum is invalid!";
            break;
        case nall::bpspatch::result::patch_invalid_header:
            retval = @"The patch has an invalid header!";
            break;
        case nall::bpspatch::result::patch_too_small:
            retval = @"The patch is too small!";
            break;
        case nall::bpspatch::result::source_checksum_invalid:
            retval = @"The source file checksum is invalid. This usually means that the file you picked to patch is not the correct file.";
            break;
        case nall::bpspatch::result::source_too_small:
            retval = @"The source file is too small!";
            break;
        case nall::bpspatch::result::target_checksum_invalid:
            retval = @"The target (output file) checksum is invalid.";
            break;
        case nall::bpspatch::result::target_too_small:
            retval = @"The target (output file) is too small.";
            break;
        case nall::bpspatch::result::unknown:
        default:
            retval = @"Unknown BPS error!";
            break;
    }
    return retval;
}

+ (BOOL)applyPatchAtURL:(NSURL *)patch toFileURL:(NSURL *)input destination:(NSURL *)output error:(NSError **)error
{
	nall::bpspatch bps;
	bps.modify([patch fileSystemRepresentation]);
	bps.source([input fileSystemRepresentation]);
	bps.target([output fileSystemRepresentation]);
	auto bpsResult = bps.apply();
	if (bpsResult != nall::bpspatch::result::success) {
		if (error) {
			*error = [NSError errorWithDomain:BPSAdapterErrorDomain code:bpsResult userInfo:nil];
		}
		return NO;
	}
	return YES;
}

+ (BOOL)createPatchUsingSourceURL:(NSURL *)orig modifiedFileURL:(NSURL *)modify destination:(NSURL *)output error:(NSError **)error
{
	return [self createLinearPatchUsingSourceURL:orig modifiedFileURL:modify destination:output error:error];
}


+ (BOOL)createLinearPatchUsingSourceURL:(NSURL *)orig modifiedFileURL:(NSURL *)modify destination:(NSURL *)output error:(NSError **)error
{
	nall::bpslinear bps;
	bps.source([orig fileSystemRepresentation]);
	bps.target([modify fileSystemRepresentation]);
	if(bps.create([output fileSystemRepresentation])==false){
		if (error) {
			*error = [NSError errorWithDomain:BPSAdapterErrorDomain code:nall::bpspatch::result::unknown userInfo:nil];
		}
		return NO;
	}
	return YES;
}

+ (BOOL)createDeltaPatchUsingSourceURL:(NSURL *)orig modifiedFileURL:(NSURL *)modify destination:(NSURL *)output error:(NSError **)error
{
	nall::bpsdelta bps;
	bps.source([orig fileSystemRepresentation]);
	bps.target([modify fileSystemRepresentation]);
	if(bps.create([output fileSystemRepresentation])==false){
		if (error) {
			*error = [NSError errorWithDomain:BPSAdapterErrorDomain code:nall::bpspatch::result::unknown userInfo:nil];
		}
		return NO;
	}
	return YES;
}
@end
