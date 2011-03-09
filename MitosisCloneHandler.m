//
//  MitosisCloneHandler.m
//  Mitosis
//
//  Created by Patrick B. Gibson on look, don't worry about it.
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
		
		_userDidCancel = NO;
		url = [inURL retain];
		
		NSArray *urlComponents = [[[inURL absoluteString] stringByDeletingPathExtension] componentsSeparatedByString:@"/"];
		projectName = [[urlComponents objectAtIndex:([urlComponents count] - 1)] retain];
		
		// Make sure the folder path is available
		// Nahh, let git do it.
		
		// Create the window to handle the job process
		[NSBundle loadNibNamed:@"MitosisCloneWindow" owner:self];
		[window makeKeyAndOrderFront:self];
		
		
		// This is potentially evil
		[[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
		
		//[window orderFrontRegardless];
		//[window makeKeyWindow];
		
		[window setReleasedWhenClosed:YES];
		
		
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
	NSString *workingDirectoryFromConfig = [(NSString *)[app.config objectForKey:kMitosisWorkingDirectory] stringByExpandingTildeInPath];
	_gitPath = [[(NSString *)[app.config objectForKey:kMitosisGitPath] stringByExpandingTildeInPath] retain];
	
	// Make sure to add the trailing path if it's not there.
	if ([workingDirectoryFromConfig characterAtIndex:([workingDirectoryFromConfig length] - 1)] != '/') {
		workingDirectoryFromConfig = [[NSString alloc] initWithString:[workingDirectoryFromConfig stringByAppendingString:@"/"]];
	}
	
	// Add the project name
	_workingDirPath = [[NSString alloc] initWithString:[workingDirectoryFromConfig stringByAppendingString:projectName]];
	
	
	// Create the arguments array
	NSString *gitURLString = [NSString stringWithFormat:@"git://%@%@", [url host], [url path], nil];
	_gitArguments = [[NSArray alloc] initWithObjects:@"clone", gitURLString, _workingDirPath, nil];
	
	[NSThread detachNewThreadSelector:@selector(runGit) toTarget:self withObject:nil];
}

#pragma mark IBActions

- (IBAction)cancel:(id)sender
{
	_userDidCancel = YES;
	[self finishClone];
}

#pragma mark Private Stuff

// This is meant to be run in its own thread.
- (void)runGit
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	// Launch the git process
	_gitTask = [[NSTask alloc] init];
	[_gitTask setLaunchPath:_gitPath];
	[_gitTask setArguments:_gitArguments];
	[_gitTask launch];
	
	[_gitTask waitUntilExit];
	
	// If we cancelled, then don't do anything
	if (_userDidCancel) {
		return;
	}
	
	// Check the return value
	if ([_gitTask terminationStatus] != 0) {
		NSAlert *alert = [NSAlert alertWithMessageText:@"Sorry, Mitosis failed!"
										 defaultButton:@"OK"
									   alternateButton:nil
										   otherButton:nil 
							 informativeTextWithFormat:@"Couldn't clone %@. Git exit status: %d", projectName, [_gitTask terminationStatus], nil];
		NSImage *image = [NSImage imageNamed:@"octocat.jpeg"];
		[alert setIcon:image];
		[alert runModal];
	} else {
		[[NSWorkspace sharedWorkspace] openFile:_workingDirPath];
	}
	
	dispatch_sync(dispatch_get_main_queue(), ^{
		[self finishClone];
	});
	
	[pool drain];
}

- (void)finishClone
{
	MitosisAppController *app = (MitosisAppController *)[MitosisAppController sharedApplication];
	[app.jobs removeObject:url];
	
	if ([_gitTask isRunning]) {
		[_gitTask terminate];
	}
	
	[window close];
	[self release];
}

- (void)dealloc
{
	if(_gitTask) { [_gitTask release]; }
	if(_gitArguments) { [_gitArguments release]; }
	if(_workingDirPath) { [_workingDirPath release]; }
	if(_gitPath) { [_gitPath release]; }
	[projectName release];
	[url release];
	[super dealloc];
}


@end
