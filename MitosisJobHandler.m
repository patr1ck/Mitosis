//
//  MitosisJobHandler.m
//  Mitosis
//
//  Created by Patrick B. Gibson on 3/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MitosisJobHandler.h"
#import "MitosisAppController.h"

@implementation MitosisJobHandler


- (id)initWithURL:(NSURL *)inURL;
{
	
	self = [super init];
	if (self != nil) {
		
		url = [inURL retain];
		// Make sure the folder path is available
		// Nahh, let git do it.
		
		// Create the window to handle the job process
		[NSBundle loadNibNamed:@"MitosisCloneWindow" owner:self];
		[window makeKeyAndOrderFront:self];
		[window setReleasedWhenClosed:YES];
		
		// This is potentially evil
		[[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
		
		// Get the title of the project and set it in the label
		
		// Start the progress indicator
		[progressBar startAnimation:nil];
		
		// Launch the git process
		
		// Check the return value
		
		// Remove the url from the job list
	}
	return self;
	

}

- (IBAction)cancel:(id)sender
{
	MitosisAppController *app = (MitosisAppController *)[MitosisAppController sharedApplication];
	[app.jobs removeObject:url];
	[window close];
	[self release];
}

- (void)dealloc
{
	[url release];
	[super dealloc];
}


@end
