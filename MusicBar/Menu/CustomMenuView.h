//
//  CustomMenu.h
//  MusicBar
//
//  Created by Wongkraiwich Chuenchomphu on 29/5/23.
//

#import <AppKit/AppKit.h>
 
@interface NSMenu (MusicBar)
- (void) _setHasPadding: (BOOL) pad onEdge: (int) whatEdge;
@end
