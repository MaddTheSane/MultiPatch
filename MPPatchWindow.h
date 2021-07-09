#import <Cocoa/Cocoa.h>
#include "mbFlipWindow.h"
#include "MPFileTextField.h"

typedef NS_ENUM(NSInteger, MPPatchFormat) {
	MPPatchFormatUnknown,
	MPPatchFormatUPS,
	MPPatchFormatXDelta,
	MPPatchFormatIPS,
	MPPatchFormatPPF,
	MPPatchFormatBSDiff,
	MPPatchFormatBPS,
	MPPatchFormatBPSDelta,
	MPPatchFormatNinjaRUP
};

@interface MPPatchWindow : NSWindow{
    IBOutlet MPFileTextField *txtPatchPath;
    IBOutlet MPFileTextField *txtRomPath;
	IBOutlet NSTextField *txtOutputPath;
	IBOutlet NSTextField *lblPatchFormat;
    IBOutlet NSWindow *wndCreator;
	IBOutlet NSPanel *pnlPatching;
	IBOutlet NSProgressIndicator	*barProgress;
	IBOutlet NSButton *btnApply;
	IBOutlet NSTextField *lblStatus;
	MPPatchFormat currentFormat;
	NSString* romFormat;
}

- (IBAction)btnApply:(id)sender;
- (IBAction)btnSelectPatch:(id)sender;
- (IBAction)btnSelectOriginal:(id)sender;
- (IBAction)btnSelectOutput:(id)sender;
+ (MPPatchFormat)detectPatchFormat:(NSString*)patchPath;
+ (MPPatchFormat)detectPatchFormatFromURL:(NSURL*)patchPath;
- (BOOL)applyPatchAtURL:(NSURL*)patchPath source:(NSURL*)sourceFile destination:(NSURL*)destFile error:(NSError**)outError;
- (IBAction)btnCreatePatch:(id)sender;
+ (mbFlipWindow*)flipper;

@end
