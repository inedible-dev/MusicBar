//
//  CustomMenu.m
//  MusicBar
//
//  Created by Wongkraiwich Chuenchomphu on 29/5/23.
//

#import "CustomMenuView.h"

@implementation NSMenu (MusicBar)

- (void)_setHasPadding:(BOOL)pad onEdge:(int)whatEdge {
    if ([self respondsToSelector: @selector(_setHasPadding:onEdge:)])
    {
        [self _setHasPadding: NO onEdge: 1];
        [self _setHasPadding: NO onEdge: 3];
    }
}

@end
