//
//  MGFDraggedTextField.m
//  CodeResign
//
//  Created by MiaoGuangfa on 3/7/16.
//  Copyright © 2016 MiaoGuangfa. All rights reserved.
//

#import "MGFDraggedTextField.h"

@implementation MGFDraggedTextField
- (void)awakeFromNib {
    NSLog(@"%s", __FUNCTION__);
    [self registerForDraggedTypes:@[NSFilenamesPboardType]];
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
    NSLog(@"%s", __FUNCTION__);
    NSPasteboard *pboard = [sender draggingPasteboard];
    
    if ( [[pboard types] containsObject:NSURLPboardType] ) {
        NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
        if (files.count <= 0) {
            return NO;
        }
        self.stringValue = [files objectAtIndex:0];
        
    }
    return YES;
}

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
    if (!self.isEnabled) {
        return NSDragOperationNone;
    }
    
    NSPasteboard *pboard = [sender draggingPasteboard];
    NSDragOperation sourceDragMask = [sender draggingSourceOperationMask];
    
    if ( [[pboard types] containsObject:NSColorPboardType] ) {
        if (sourceDragMask & NSDragOperationCopy) {
            return NSDragOperationCopy;
        }
    }
    if ( [[pboard types] containsObject:NSFilenamesPboardType] ) {
        if (sourceDragMask & NSDragOperationCopy) {
            return NSDragOperationCopy;
        }
    }
    
    return NSDragOperationNone;
}

@end
