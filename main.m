//
//  main.m
//  Mitosis
//
//  Created by Patrick B. Gibson on look, don't worry about it.
//

#import <Cocoa/Cocoa.h>
#import "MitosisAppController.h"

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
