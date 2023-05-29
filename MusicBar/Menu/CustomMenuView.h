//
//  CustomMenu.h
//  MusicBar
//
//  Created by Apiphoom Chuenchompoo on 29/5/23.
//

#import <Cocoa/Cocoa.h>

@interface NSMenu (HasPadding)

- (void) _setHasPadding: (BOOL) pad onEdge: (int) whatEdge;

@end
