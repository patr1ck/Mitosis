//
//  MitosisAppDelegate.h
//  Mitosis
//
//  Created by Patrick B. Gibson on 2/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MitosisAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
	NSMutableArray *jobs;
	NSDictionary *config;
	BOOL gitNotFound;
}

@property (assign) IBOutlet NSWindow *window;

@end
