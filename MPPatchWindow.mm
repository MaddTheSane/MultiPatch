#import "MPPatchWindow.h"
#include "libups.hpp"
#include "XDeltaAdapter.h"
#include "IPSAdapter.h"
#include "PPFAdapter.h"
#include "BSdiffAdapter.h"
#include "BPSAdapter.h"

@implementation MPPatchWindow
static mbFlipWindow* _flipper;

-(void)awakeFromNib{
    [super awakeFromNib];
    _flipper = [mbFlipWindow new];
}

-(void)close{
    [super close];
    [[NSApplication sharedApplication] terminate:nil];
}

-(void)makeKeyAndOrderFront:(id)sender{
    [super makeKeyAndOrderFront:sender]; //This one gets called when mbFlipWindow flips back to this window
    [self onOrderFront];
}

-(void)orderFront:(id)sender{
    [super orderFront:sender]; //This one gets called when the app starts
    [self onOrderFront];
}

-(void)onOrderFront{
    txtRomPath.acceptFileDrop = ^BOOL(NSURL * target) {
        [self setTargetFile:target];
        return YES;
    };
    txtPatchPath.acceptFileDrop = ^BOOL(NSURL * target) {
        [self setPatchFile:target];
        return YES;
    };
}

-(void)orderOut:(id)sender{
    [super orderOut:sender];
    txtRomPath.acceptFileDrop = nil;
    txtPatchPath.acceptFileDrop = nil;
}

- (IBAction)btnApply:(id)sender {
    NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *romPath = [txtRomPath stringValue];
	NSString *outputPath = [txtOutputPath stringValue];
	NSString *patchPath = [txtPatchPath stringValue];
	
	if([fileManager fileExistsAtPath:patchPath]){
		if([romPath length] > 0 && [outputPath length] > 0 && [patchPath length] > 0){
			[lblStatus setStringValue:@"Now patching..."];
            [NSApp beginSheet:pnlPatching modalForWindow:self modalDelegate:nil didEndSelector:nil contextInfo:nil]; //Make a sheet
			[barProgress setUsesThreadedAnimation:YES]; //Make sure it animates.
			[barProgress startAnimation:self];
			NSString* errMsg = [self ApplyPatch:patchPath :romPath :outputPath];
			[barProgress stopAnimation:self];
			[NSApp endSheet:pnlPatching]; //Tell the sheet we're done.
			[pnlPatching orderOut:self]; //Lets hide the sheet.
			
			if(errMsg == nil){
				NSRunAlertPanel(@"Finished!",@"The file was patched successfully.",@"Okay",nil,nil);
			}
			else{
				NSRunAlertPanel(@"Patching failed", errMsg, @"Okay", nil, nil);
				[errMsg release];
				errMsg = nil;
			}
		}
		else{
			NSRunAlertPanel(@"Not ready yet",@"All of the files above must be chosen before patching is possible.",@"Okay",nil,nil);
		}
	}
	else{
		NSRunAlertPanel(@"Patch not found",@"The patch file selected does not exist.\nWhy did you do that?",@"Okay",nil,nil);	
	}
}

-(void)setPatchFile:(NSURL*)patch{
    NSString* selfile = [patch path];
    [txtPatchPath setStringValue:selfile];
    currentFormat = [MPPatchWindow detectPatchFormat:selfile];
    [btnApply setEnabled:currentFormat!=MPPatchFormatUnknown];
    switch (currentFormat) {
        case MPPatchFormatUPS:
            [lblPatchFormat setStringValue:@"UPS"];
            break;
        case MPPatchFormatXDelta:
            [lblPatchFormat setStringValue:@"XDelta"];
            break;
        case MPPatchFormatIPS:
            [lblPatchFormat setStringValue:@"IPS"];
            break;
        case MPPatchFormatPPF:
            [lblPatchFormat setStringValue:@"PPF"];
            break;
        case MPPatchFormatBSDiff:
            [lblPatchFormat setStringValue:@"BSDiff"];
            break;
        case MPPatchFormatBPS:
            [lblPatchFormat setStringValue:@"BPS"];
            break;
        default:
            [lblPatchFormat setStringValue:@"Not supported"];
            break;
    }
}

- (IBAction)btnSelectPatch:(id)sender{
	NSOpenPanel *fbox = [NSOpenPanel openPanel];
    [fbox beginSheetModalForWindow:self completionHandler:^(NSInteger result) {
        if(result == NSModalResponseOK){
            [self setPatchFile:[[fbox URLs] objectAtIndex:0]];
        }
    }];
}

-(void)setTargetFile:(NSURL*)target{
    NSString* selfile = [target path];
    [txtRomPath setStringValue:selfile];
    if(romFormat != nil){
        [romFormat release];
    }
    romFormat = [selfile pathExtension];
    [romFormat retain];
}

- (IBAction)btnSelectOriginal:(id)sender {
    NSOpenPanel *fbox = [NSOpenPanel openPanel];
    [fbox beginSheetModalForWindow:self completionHandler:^(NSInteger result) {
        if(result == NSModalResponseOK){
            [self setTargetFile:[[fbox URLs] objectAtIndex:0]];
        }
    }];
}

- (IBAction)btnSelectOutput:(id)sender{
	NSSavePanel *fbox = [NSSavePanel savePanel];
	if(romFormat != nil && [romFormat length]>0){
		[fbox setAllowedFileTypes:[NSArray arrayWithObject:romFormat]];
	}
    [fbox beginSheetModalForWindow:self completionHandler:^(NSInteger result) {
        if(result == NSModalResponseOK){
            NSString* selfile = [[fbox URL] path];
            [txtOutputPath setStringValue:selfile];
        }
    }];
}

+ (MPPatchFormat)detectPatchFormat:(NSString*)patchPath{
	//I'm just going to look at the file extensions for now.
	//In the future, I might wish to actually look at the contents of the file.
    NSString* lowerPath = [patchPath pathExtension].lowercaseString;
	if([lowerPath hasSuffix:@"ups"]){
		return MPPatchFormatUPS;
	}
	else if([lowerPath hasSuffix:@"ips"]){
		return MPPatchFormatIPS;
	}
	else if([lowerPath hasSuffix:@"ppf"]){
		return MPPatchFormatPPF;
	}
	else if([lowerPath hasSuffix:@"dat"] || [patchPath.lowercaseString hasSuffix:@"delta"]){
		return MPPatchFormatXDelta;
	}
    else if([lowerPath hasSuffix:@"bdf"] || [lowerPath hasSuffix:@"bsdiff"]){
        return MPPatchFormatBSDiff;
    }
    else if([lowerPath hasSuffix:@"bps"]){
        return MPPatchFormatBPS;
    }
	return MPPatchFormatUnknown;
}

- (NSString*)ApplyPatch:(NSString*)patchPath :(NSString*)sourceFile :(NSString*)destFile{
	NSString* retval = nil;
	if(currentFormat == MPPatchFormatUPS){
		UPS ups; //UPS Patcher
		bool result = ups.apply([sourceFile fileSystemRepresentation], [destFile fileSystemRepresentation], [patchPath fileSystemRepresentation]);
		if(result == false){
			retval = @(ups.error);
		}
	}
	else if(currentFormat == MPPatchFormatIPS){
		retval = [IPSAdapter applyPatch:patchPath toFile:sourceFile andCreate:destFile];
	}
	else if(currentFormat == MPPatchFormatXDelta){
		retval = [XDeltaAdapter applyPatch:patchPath toFile:sourceFile andCreate:destFile];
	}
	else if(currentFormat == MPPatchFormatPPF){
		retval = [PPFAdapter applyPatch:patchPath toFile:sourceFile andCreate:destFile];
	}
    else if(currentFormat == MPPatchFormatBSDiff){
        retval = [BSdiffAdapter applyPatch:patchPath toFile:sourceFile andCreate:destFile];
    }
    else if(currentFormat == MPPatchFormatBPS){
        retval = [BPSAdapter applyPatch:patchPath toFile:sourceFile andCreate:destFile];
    }
	return retval;
}

- (IBAction)btnCreatePatch:(id)sender {
    _flipper.flipRight = YES;
    [_flipper flip:self to:wndCreator];
}

+ (mbFlipWindow*)flipper{
    return _flipper;
}

@end
