//
//  MitosisJobHandler.m
//  Mitosis
//
//  Created by Patrick B. Gibson on 3/1/11.
//

#import "MitosisCloneHandler.h"
#import "MitosisAppController.h"

@interface MitosisCloneHandler (Private)
- (void)finishClone;
@end


@implementation MitosisCloneHandler


- (id)initWithURL:(NSURL *)inURL;
{
	
	self = [super init];
	if (self != nil) {
		
		url = [inURL retain];
		
		NSArray *urlComponents = [[[inURL absoluteString] stringByDeletingPathExtension] componentsSeparatedByString:@"/"];
		projectName = [urlComponents objectAtIndex:([urlComponents count] - 1)];
		
		// Make sure the folder path is available
		// Nahh, let git do it.
		
		// Create the window to handle the job process
		[NSBundle loadNibNamed:@"MitosisCloneWindow" owner:self];
		[window makeKeyAndOrderFront:self];
		[window setReleasedWhenClosed:YES];
		
		// This is potentially evil
		[[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
		
		// Get the title of the project and set it in the label
		[label setStringValue:[NSString stringWithFormat:@"Cloning %@...", projectName, nil]];
		
	}
	return self;
	

}

- (void)start
{
	// Start the progress indicator
	[progressBar startAnimation:nil];
	
	// Get the config
	MitosisAppController *app = (MitosisAppController *)[MitosisAppController sharedApplication];
	NSString *workingDirPath = [(NSString *)[app.config objectForKey:kMitosisWorkingDirectory] stringByExpandingTildeInPath];
	NSString *gitPath = [(NSString *)[app.config objectForKey:kMitosisGitPath] stringByExpandingTildeInPath];
	
	// Make sure to add the trailing path if it's not there.
	if ([workingDirPath characterAtIndex:([workingDirPath length] - 1)] != '/') {
		workingDirPath = [workingDirPath stringByAppendingString:@"/"];
	}
	
	// Add the project name
	workingDirPath = [workingDirPath stringByAppendingString:projectName];
	
	
	// Create the arguments array
	NSString *gitURLString = [NSString stringWithFormat:@"git://%@%@", [url host], [url path], nil];
	NSArray *arguments = [NSArray arrayWithObjects:@"clone", gitURLString, workingDirPath, nil];
	
	// Launch the git process
	NSTask *gitTask = [[NSTask alloc] init];
	[gitTask setLaunchPath:gitPath];
	[gitTask setArguments:arguments];
	[gitTask launch];
	
	[gitTask waitUntilExit];
	
	// Check the return value
	if ([gitTask terminationStatus] != 0) {
		NSAlert *alert = [NSAlert alertWithMessageText:@"Sorry, Mitosis failed!"
										 defaultButton:@"OK"
									   alternateButton:nil
										   otherButton:nil 
							 informativeTextWithFormat:@"Couldn't clone %@. Git exit status: %d", projectName, [gitTask terminationStatus], nil];
		NSImage *image = [NSImage imageNamed:@"octocat.jpeg"];
		[alert setIcon:image];
		[alert runModal];
	} else {
		[[NSWorkspace sharedWorkspace] openFile:workingDirPath];
	}

	
	[self finishClone];
	[self release];
}

#pragma mark IBActions

- (IBAction)cancel:(id)sender
{
	[self finishClone];
	[self release];
}

#pragma mark Private Stuff


- (void)finishClone
{
	MitosisAppController *app = (MitosisAppController *)[MitosisAppController sharedApplication];
	[app.jobs removeObject:url];
	[window close];
}

- (void)dealloc
{
	[url release];
	[super dealloc];
}


@end
