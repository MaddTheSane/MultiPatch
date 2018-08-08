//
//  BPSAdapter.m
//  MultiPatch
//

#import "BPSAdapter.h"
#import "patch.hpp"
#import "linear.hpp"
#import "delta.hpp"

@implementation BPSAdapter
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

+(NSString*)applyPatch:(NSString*)patch toFile:(NSString*)input andCreate:(NSString*)output{
    NSString* retval = nil;
    nall::bpspatch bps;
    bps.modify([patch fileSystemRepresentation]);
    bps.source([input fileSystemRepresentation]);
    bps.target([output fileSystemRepresentation]);
    nall::bpspatch::result bpsResult = bps.apply();
    if(bpsResult != nall::bpspatch::result::success){
        retval = [BPSAdapter TranslateBPSresult:bpsResult];
    }
    return retval;
}

+(NSString*)createPatchLinear:(NSString*)orig withMod:(NSString*)modify andCreate:(NSString*)output{
    NSString* retval = nil;
    nall::bpslinear bps;
    bps.source([orig fileSystemRepresentation]);
    bps.target([modify fileSystemRepresentation]);
    if(bps.create([output fileSystemRepresentation])==false){
        retval = @"BPS patch creation failed due to an unknown error!";
    }
    return nil;
}

+(NSString*)createPatchDelta:(NSString*)orig withMod:(NSString*)modify andCreate:(NSString*)output{
    NSString* retval = nil;
    nall::bpsdelta bps;
    bps.source([orig fileSystemRepresentation]);
    bps.target([modify fileSystemRepresentation]);
    if(bps.create([output fileSystemRepresentation])==false){
        retval = @"BPS patch creation failed due to an unknown error!";
    }
    return nil;
}
@end
