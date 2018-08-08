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
	MPPatchFormatBPSDelta
};

@interface MPPatchWindow : NSWindow{
    IBOutlet MPFileTextField *txtPatchPath;
    IBOutlet MPFileTextField *txtRomPath;
	IBOutlet NSTextField *txtOutputPath;
	IBOutlet id lblPatchFormat;
    IBOutlet NSWindow *wndCreator;
	IBOutlet id pnlPatching;
	IBOutlet id	barProgress;
	IBOutlet id btnApply;
	IBOutlet NSTextField *lblStatus;
	MPPatchFormat currentFormat;
	NSString* romFormat;
}

- (IBAction)btnApply:(id)sender;
- (IBAction)btnSelectPatch:(id)sender;
- (IBAction)btnSelectOriginal:(id)sender;
- (IBAction)btnSelectOutput:(id)sender;
+ (MPPatchFormat)detectPatchFormat:(NSString*)patchPath;
- (NSString*)ApplyPatch:(NSString*)patchPath :(NSString*)sourceFile :(NSString*)destFile;
- (IBAction)btnCreatePatch:(id)sender;
+ (mbFlipWindow*)flipper;

@end
