//
//  MitosisAppDelegate.m
//  Mitosis
//
//  Created by Patrick B. Gibson on 2/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <YAML/YAMLSerialization.h>
#import "MitosisAppDelegate.h"
#import "MitosisAppController.h"


@implementation MitosisAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Get the app controller
	MitosisAppController *controller = (MitosisAppController *)[MitosisAppController sharedApplication];
	
	// Get the config
	[controller findOrCreateMitosisConfig];
	
	// Create a timer on a seperate thread that closes the app after 10 seconds if there are no running downloads.
	[NSThread detachNewThreadSelector:@selector(startTimerThread) toTarget:controller withObject:nil];
	
}

@end
