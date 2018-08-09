//
//  MPPatchAdapter.h
//  MultiPatcher
//
//  Created by C.W. Betts on 8/8/18.
//

#import <Foundation/Foundation.h>

@protocol MPPatchAdapter <NSObject>
+(BOOL)applyPatchAtURL:(NSURL*)patch toFileURL:(NSURL*)input destination:(NSURL*)output error:(NSError**)error;
+(BOOL)createPatchUsingSourceURL:(NSURL*)orig modifiedFileURL:(NSURL*)modify destination:(NSURL*)output error:(NSError**)error;
@end
