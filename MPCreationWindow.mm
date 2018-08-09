//
//  CreationController.mm
//  MultiPatch
//

#import "MPCreationWindow.h"
#include "libups.hpp"
#include "XDeltaAdapter.h"
#include "IPSAdapter.h"
#include "PPFAdapter.h"
#include "BSdiffAdapter.h"
#include "BPSAdapter.h"

@implementation MPCreationWindow

-(void)close{
    [super close];
    [[NSApplication sharedApplication] terminate:nil];
}

-(void)makeKeyAndOrderFront:(id)sender{
    [super makeKeyAndOrderFront:sender];
    txtOrigFile.acceptFileDrop = ^BOOL(NSURL * target) {
        [self setOriginalFile:target];
        return YES;
    };
    txtModFile.acceptFileDrop = ^BOOL(NSURL * target) {
        [self setModifiedFile:target];
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
            [self setOriginalFile:[[fbox URLs] objectAtIndex:0]];
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
			[NSApp beginSheet:pnlPatching modalForWindow:self modalDelegate:nil didEndSelector:nil contextInfo:nil];
            //Make a sheet
            [barProgress setUsesThreadedAnimation:YES]; //Make sure it animates.
			[barProgress startAnimation:self];
			NSString* errMsg = [self CreatePatch:origPath :modPath :patchPath];
			[barProgress stopAnimation:self];
			[NSApp endSheet:pnlPatching]; //Tell the sheet we're done.
			[pnlPatching orderOut:self]; //Lets hide the sheet.
			
			if(errMsg == nil){
				NSRunAlertPanel(@"Finished!",@"The patch was created sucessfully!",@"Okay",nil,nil);
			}
			else{
				NSRunAlertPanel(@"Patch creation failed.", errMsg, @"Okay", nil, nil);
				[errMsg release];
				errMsg = nil;
			}
		}
		else{
			NSRunAlertPanel(@"Not ready yet",@"All of the files above must be chosen before patching is possible.",@"Okay",nil,nil);
		}
	}
	else{
		NSRunAlertPanel(@"Input file(s) not found",@"The input files must be selected and should exist.",@"Okay",nil,nil);	
	}
}

- (IBAction)btnApplyMode:(id)sender {
    mbFlipWindow* flipper = [MPPatchWindow flipper];
    flipper.flipRight = NO;
    [flipper flip:self to:wndApplyPatch];
}

- (NSString*)CreatePatch:(NSString*)origFile :(NSString*)modFile :(NSString*)createFile{
    NSString* retval = nil;
	if(currentFormat == MPPatchFormatUPS){
		UPS ups; //UPS Patcher
		bool result = ups.create([origFile cStringUsingEncoding:[NSString defaultCStringEncoding]], [modFile cStringUsingEncoding:[NSString defaultCStringEncoding]], [createFile cStringUsingEncoding:[NSString defaultCStringEncoding]]);
		if(result == false){
			retval = [NSString stringWithCString:ups.error encoding:NSASCIIStringEncoding];
			[retval retain];
		}
	}
	else if(currentFormat == MPPatchFormatIPS){
		retval = [IPSAdapter createPatch:origFile withMod:modFile andCreate:createFile];
	}
	else if(currentFormat == MPPatchFormatXDelta){
        retval = [XDeltaAdapter createPatch:origFile withMod:modFile andCreate:createFile];
	}
	else if(currentFormat == MPPatchFormatPPF){
		retval = [PPFAdapter createPatch:origFile withMod:modFile andCreate:createFile];
	}
    else if(currentFormat == MPPatchFormatBSDiff){
        retval = [BSdiffAdapter createPatch:origFile withMod:modFile andCreate:createFile];
    }
    else if(currentFormat == MPPatchFormatBPS){
        retval = [BPSAdapter createPatchLinear:origFile withMod:modFile andCreate:createFile];
    }
    else if(currentFormat == MPPatchFormatBPSDelta){
        retval = [BPSAdapter createPatchDelta:origFile withMod:modFile andCreate:createFile];
    }
	return retval;
}
@end
