#import "MPPatchWindow.h"
#include "XDeltaAdapter.h"
#include "IPSAdapter.h"
#include "PPFAdapter.h"
#include "BSdiffAdapter.h"
#include "BPSAdapter.h"
#include "MPUPSAdapter.h"

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
	__weak MPPatchWindow *weakSelf = self;
    txtRomPath.acceptFileDrop = ^BOOL(NSURL * target) {
        [weakSelf setTargetFile:target];
        return YES;
    };
    txtPatchPath.acceptFileDrop = ^BOOL(NSURL * target) {
        [weakSelf setPatchFile:target];
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
			[self beginSheet:pnlPatching completionHandler:^(NSModalResponse returnCode) {
				//Do nothing
			}];
			[barProgress setUsesThreadedAnimation:YES]; //Make sure it animates.
			[barProgress startAnimation:self];
			NSError *err;
			NSURL *romURL = [NSURL fileURLWithPath:romPath];
			NSURL *outputURL = [NSURL fileURLWithPath:outputPath];
			NSURL *patchURL = [NSURL fileURLWithPath:patchPath];
			BOOL success = [self applyPatchAtURL:patchURL source:romURL destination:outputURL error:&err];
			[barProgress stopAnimation:self];
			[self endSheet:pnlPatching]; //Tell the sheet we're done.
			[pnlPatching orderOut:self]; //Lets hide the sheet.
			
			if(success){
				NSAlert *alert = [[NSAlert alloc] init];
				alert.messageText = @"Finished!";
				alert.informativeText = @"The file was patched successfully.";
				[alert runModal];
			}
			else{
				[NSApp presentError:err];
			}
		}
		else{
			NSAlert *alert = [[NSAlert alloc] init];
			alert.messageText = @"Not ready yet";
			alert.informativeText = @"All of the files above must be chosen before patching is possible.";
			[alert runModal];
		}
	}
	else{
		NSAlert *alert = [[NSAlert alloc] init];
		alert.messageText = @"Patch not found";
		alert.informativeText = @"The patch file selected does not exist.\nWhy did you do that?";
		[alert runModal];
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
	fbox.allowedFileTypes = @[@"ups", @"ips", @"ppf", @"dat", @"xdelta", @"delta", @"bdf", @"bsdiff", @"bps"];
    [fbox beginSheetModalForWindow:self completionHandler:^(NSInteger result) {
        if(result == NSModalResponseOK){
            [self setPatchFile:[[fbox URLs] objectAtIndex:0]];
        }
    }];
}

-(void)setTargetFile:(NSURL*)target{
    NSString* selfile = [target path];
    [txtRomPath setStringValue:selfile];
    romFormat = [selfile pathExtension];
}

- (IBAction)btnSelectOriginal:(id)sender {
    NSOpenPanel *fbox = [NSOpenPanel openPanel];
    [fbox beginSheetModalForWindow:self completionHandler:^(NSInteger result) {
        if(result == NSModalResponseOK){
            [self setTargetFile:fbox.URL];
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
			[self->txtOutputPath setStringValue:selfile];
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

- (BOOL)applyPatchAtURL:(NSURL*)patchPath source:(NSURL*)sourceFile destination:(NSURL*)destFile error:(NSError**)outError
{
	BOOL retval = NO;
	switch (currentFormat) {
		case MPPatchFormatUPS:
			retval = [MPUPSAdapter applyPatchAtURL:patchPath toFileURL:sourceFile destination:destFile error:outError];
			break;
			
		case MPPatchFormatIPS:
			retval = [IPSAdapter applyPatchAtURL:patchPath toFileURL:sourceFile destination:destFile error:outError];
			break;
			
		case MPPatchFormatXDelta:
			retval = [XDeltaAdapter applyPatchAtURL:patchPath toFileURL:sourceFile destination:destFile error:outError];
			break;
			
		case MPPatchFormatPPF:
			retval = [PPFAdapter applyPatchAtURL:patchPath toFileURL:sourceFile destination:destFile error:outError];
			break;
			
		case MPPatchFormatBSDiff:
			retval = [BSdiffAdapter applyPatchAtURL:patchPath toFileURL:sourceFile destination:destFile error:outError];
			break;
			
		case MPPatchFormatBPS:
			retval = [BPSAdapter applyPatchAtURL:patchPath toFileURL:sourceFile destination:destFile error:outError];
			break;
			
		default:
			if (outError) {
				*outError = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFeatureUnsupportedError userInfo:nil];
			}
			break;
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
