//
//  MPPatchAdaptor.h
//  MultiPatcher
//
//  Created by C.W. Betts on 8/8/18.
//

#import <Foundation/Foundation.h>

@protocol MPPatchAdaptor <NSObject>
+(BOOL)applyPatch:(NSURL*)patch toFile:(NSURL*)input andCreate:(NSURL*)output error:(NSError**)error;
+(BOOL)createPatch:(NSURL*)orig withMod:(NSURL*)modify andCreate:(NSURL*)output error:(NSError**)error;
@end
