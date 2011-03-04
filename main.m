//
//  main.m
//  Mitosis
//
//  Created by Patrick B. Gibson on 2/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MitosisAppController.h"
#import "MitosisAppDelegate.h"

int main(int argc, char *argv[])
{	
	
	MitosisAppController *app = (MitosisAppController *) [MitosisAppController sharedApplication];
	
	NSAppleEventManager *appleEventManager = [NSAppleEventManager sharedAppleEventManager];
	[appleEventManager setEventHandler:app 
						   andSelector:@selector(handleGetURLEvent:withReplyEvent:) 
						 forEventClass:kInternetEventClass 
							andEventID:kAEGetURL];
	
    return NSApplicationMain(argc,  (const char **) argv);
}
