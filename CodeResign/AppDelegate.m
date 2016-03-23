//
//  AppDelegate.m
//  CodeResign
//
//  Created by MiaoGuangfa on 3/5/16.
//  Copyright © 2016 MiaoGuangfa. All rights reserved.
//

#import "AppDelegate.h"
#import "CodeResgin.h"

@interface AppDelegate ()

@property (weak) IBOutlet CodeResgin *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    [_window initializeData];
    
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
