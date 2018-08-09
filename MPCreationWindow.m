//
//  CreationController.mm
//  MultiPatch
//

#import "MPCreationWindow.h"
#include "XDeltaAdapter.h"
#include "IPSAdapter.h"
#include "PPFAdapter.h"
#include "BSdiffAdapter.h"
#include "BPSAdapter.h"
#include "MPUPSAdapter.h"

@implementation MPCreationWindow

-(void)close{
    [super close];
    [[NSApplication sharedApplication] terminate:nil];
}

-(void)makeKeyAndOrderFront:(id)sender{
    [super makeKeyAndOrderFront:sender];
    __weak MPCreationWindow *weakSelf = self;
    txtOrigFile.acceptFileDrop = ^BOOL(NSURL * target) {
        [weakSelf setOriginalFile:target];
        return YES;
    };
    txtModFile.acceptFileDrop = ^BOOL(NSURL * target) {
        [weakSelf setModifiedFile:target];
        return YES;
    };
}

-(void)orderOut:(id)sender{
    [super orderOut:sender]; //This is what you do when you order a pizza
    txtOrigFile.acceptFileDrop = nil;
    txtModFile.acceptFileDrop = nil;
}

-(void)setOriginalFile:(NSURL*)original{
    NSString* selfile = [original path];
    [txtOrigFile setStringValue:selfile];
}

- (IBAction)btnPickOrig:(id)sender {
    NSOpenPanel *fbox = [NSOpenPanel openPanel];
    [fbox beginSheetModalForWindow:self completionHandler:^(NSInteger result) {
        if(result == NSModalResponseOK){
            [self setOriginalFile:fbox.URL];
        }
    }];
}

-(void)setModifiedFile:(NSURL*)modified{
    NSString* selfile = [modified path];
    [txtModFile setStringValue:selfile];
}

- (IBAction)btnPickModified:(id)sender{
    NSOpenPanel *fbox = [NSOpenPanel openPanel];
    [fbox beginSheetModalForWindow:self completionHandler:^(NSInteger result) {
        if(result == NSModalResponseOK){
            [self setModifiedFile:[[fbox URLs] objectAtIndex:0]];
        }
    }];
}

- (IBAction)btnPickOutput:(id)sender{
    NSSavePanel *fbox = [NSSavePanel savePanel];
	[fbox setExtensionHidden:NO];
    [ddFormats removeAllItems];
    [ddFormats addItemWithTitle:@"UPS Patch (*.ups)"];
    [ddFormats addItemWithTitle:@"IPS Patch (*.ips)"];
    //[ddFormats addItemWithTitle:@"PPF Patch (*.ppf)"]; //No PPF creation in LibPPF. :-(
    [ddFormats addItemWithTitle:@"XDelta Patch (*.delta)"];
    [ddFormats addItemWithTitle:@"BSDiff Patch (*.bdf)"];
    [ddFormats addItemWithTitle:@"Linear BPS Patch (*.bps)"];
    [ddFormats addItemWithTitle:@"Delta BPS Patch (*.bps)"];
    [fbox setAccessoryView:vwFormatPicker];
    [fbox beginSheetModalForWindow:self completionHandler:^(NSInteger result) {
        [self selOutputPanelEnd:fbox returnCode:result];
    }];
}

- (void)selOutputPanelEnd:(NSSavePanel*)panel returnCode:(NSInteger)returnCode{
	if(returnCode == NSModalResponseOK){
		NSString* selfile = [[panel URL] path];
        bool bps_delta = false;
        if([[ddFormats titleOfSelectedItem] hasPrefix:@"UPS"] && ![selfile hasSuffix:@".ups"]){
            selfile = [selfile stringByAppendingPathExtension:@"ups"];
        }
        else if([[ddFormats titleOfSelectedItem] hasPrefix:@"Linear BPS"] && ![selfile hasSuffix:@".bps"]){
            selfile = [selfile stringByAppendingPathExtension:@"bps"];
        }
        else if([[ddFormats titleOfSelectedItem] hasPrefix:@"Delta BPS"] && ![selfile hasSuffix:@".bps"]){
            selfile = [selfile stringByAppendingPathExtension:@"bps"];
            bps_delta = true;
        }
        else if([[ddFormats titleOfSelectedItem] hasPrefix:@"IPS"] && ![selfile hasSuffix:@".ips"]){
            selfile = [selfile stringByAppendingPathExtension:@"ips"];
        }
        else if([[ddFormats titleOfSelectedItem] hasPrefix:@"XDelta"] && ![selfile hasSuffix:@".delta"]){
            selfile = [selfile stringByAppendingPathExtension:@"delta"];
        }
        else if([[ddFormats titleOfSelectedItem] hasPrefix:@"BSDiff"] && ![selfile hasSuffix:@".bdf"]){
            selfile = [selfile stringByAppendingPathExtension:@"bdf"];
        }
        [txtPatchFile setStringValue:selfile];
        currentFormat = [MPPatchWindow detectPatchFormat:selfile];
        if(currentFormat == MPPatchFormatUPS){
            [lblPatchFormat setStringValue:@"UPS Patch"];
        }
        else if(currentFormat == MPPatchFormatIPS){
            [lblPatchFormat setStringValue:@"IPS Patch"];
        }
        else if(currentFormat == MPPatchFormatXDelta){
            [lblPatchFormat setStringValue:@"XDelta Patch"];
        }
        /*else if(currentFormat == PPFPAT){
            [lblPatchFormat setStringValue:@"PPF Patch"];
        }*/
        else if(currentFormat == MPPatchFormatBSDiff){
            [lblPatchFormat setStringValue:@"BSDiff Patch"];
        }
        else if(currentFormat == MPPatchFormatBPS){
            if(bps_delta){
                [lblPatchFormat setStringValue:@"BPS Patch (Delta)"];
                currentFormat = MPPatchFormatBPSDelta;
            }
            else{
                [lblPatchFormat setStringValue:@"BPS Patch (Linear)"];
            }
        }
        else{
            [lblPatchFormat setStringValue:@"Unknown"];
        }
        [btnCreatePatch setEnabled:currentFormat!=MPPatchFormatUnknown];
	}
}

- (IBAction)btnCreatePatch:(id)sender{
    NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *origPath = [txtOrigFile stringValue];
	NSString *modPath = [txtModFile stringValue];
	NSString *patchPath = [txtPatchFile stringValue];
	//NSRange lastSlash = [patchPath rangeOfString:@"/" options:NSBackwardsSearch];
	
	if([fileManager fileExistsAtPath:origPath] && [fileManager fileExistsAtPath:modPath]){
		if([origPath length] > 0 && [modPath length] > 0 && [patchPath length] > 0){
			[lblStatus setStringValue:@"Now creating patch..."];
			[self beginSheet:pnlPatching completionHandler:^(NSModalResponse returnCode) {
				//Do nothing
			}];
            //Make a sheet
            [barProgress setUsesThreadedAnimation:YES]; //Make sure it animates.
			[barProgress startAnimation:self];
			NSError *err;
			NSURL *origURL = [NSURL fileURLWithPath:origPath];
			NSURL *modURL = [NSURL fileURLWithPath:modPath];
			NSURL *patchURL = [NSURL fileURLWithPath:patchPath];
			BOOL success = [self createPatchUsingSourceURL:origURL modifiedFileURL:modURL toURL:patchURL error:&err];
			[barProgress stopAnimation:self];
			[self endSheet:pnlPatching]; //Tell the sheet we're done.
			[pnlPatching orderOut:self]; //Lets hide the sheet.
			
			if(success){
				NSAlert *alert = [[NSAlert alloc] init];
				alert.messageText = @"Finished!";
				alert.informativeText = @"The patch was created sucessfully!";
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
		alert.messageText = @"Input file(s) not found";
		alert.informativeText = @"The input files must be selected and should exist.";
		[alert runModal];
	}
}

- (IBAction)btnApplyMode:(id)sender {
    mbFlipWindow* flipper = [MPPatchWindow flipper];
    flipper.flipRight = NO;
    [flipper flip:self to:wndApplyPatch];
}

- (BOOL)createPatchUsingSourceURL:(NSURL*)sourceFile modifiedFileURL:(NSURL*)destFile toURL:(NSURL*)patchPath error:(NSError**)outError
{
	BOOL retval = NO;
	switch (currentFormat) {
		case MPPatchFormatUPS:
			retval = [MPUPSAdapter createPatchUsingSourceURL:sourceFile modifiedFileURL:destFile destination:patchPath error:outError];
			break;
			
		case MPPatchFormatIPS:
			retval = [IPSAdapter createPatchUsingSourceURL:sourceFile modifiedFileURL:destFile destination:patchPath error:outError];
			break;
			
		case MPPatchFormatXDelta:
			retval = [XDeltaAdapter createPatchUsingSourceURL:sourceFile modifiedFileURL:destFile destination:patchPath error:outError];
			break;
			
		case MPPatchFormatPPF:
			retval = [PPFAdapter createPatchUsingSourceURL:sourceFile modifiedFileURL:destFile destination:patchPath error:outError];
			break;
			
		case MPPatchFormatBSDiff:
			retval = [BSdiffAdapter createPatchUsingSourceURL:sourceFile modifiedFileURL:destFile destination:patchPath error:outError];
			break;
			
		case MPPatchFormatBPS:
			retval = [BPSAdapter createLinearPatchUsingSourceURL:sourceFile modifiedFileURL:destFile destination:patchPath error:outError];
			break;
			
		case MPPatchFormatBPSDelta:
			retval = [BPSAdapter createDeltaPatchUsingSourceURL:sourceFile modifiedFileURL:destFile destination:patchPath error:outError];
			break;
			
		default:
		case MPPatchFormatUnknown:
			if (outError) {
				*outError = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFeatureUnsupportedError userInfo:nil];
			}
			break;
	}
	return retval;
}
@end
