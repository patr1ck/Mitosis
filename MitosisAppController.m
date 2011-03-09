//
//  MitosisAppController.m
//  Mitosis
//
//  Created by Patrick B. Gibson on look, don't worry about it.
//

#import <YAML/YAMLSerialization.h>

#import "MitosisAppController.h"
#import "MitosisCloneHandler.h"

@interface MitosisAppController (Private)

- (void)createAndLoadConfig;
- (NSString *)findGit;
- (void)startTimerThread;
- (void)findOrCreateMitosisConfig;

@end

@implementation MitosisAppController

@synthesize jobs, config;

- (id) init
{
	self = [super init];
	if (self != nil) {
		// Initialize the jobs list
		jobs = [[NSMutableArray alloc] initWithCapacity:10];
		gitNotFound = NO;
		
		[self findOrCreateMitosisConfig];
		[NSThread detachNewThreadSelector:@selector(startTimerThread) toTarget:self withObject:nil];
				
	}
	return self;
}

#pragma mark URL Handling

- (void)handleGetURLEvent:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent
{
	// Make sure we can run.
	if (gitNotFound) {
		NSAlert *alert = [NSAlert alertWithMessageText:@"Sorry, Mitosis isn't set up properly yet!"
										 defaultButton:@"OK"
									   alternateButton:nil
										   otherButton:nil 
							 informativeTextWithFormat:@"Check ~/Library/Application Support/Mitosis.config to make sure the path to git is correct and try again."];
		NSImage *image = [NSImage imageNamed:@"octocat.jpeg"];
		[alert setIcon:image];
		[alert runModal];
	}
	
	NSURL *url = [NSURL URLWithString:[[event paramDescriptorForKeyword:keyDirectObject] stringValue]];
	
	// Make sure we're actually handling a URL
	if (!url) {
		return;
	}
	
	// Make sure we aren't already downloading the URL
	for (NSURL *inProgressURL in jobs) {
		if ([inProgressURL isEqual:url]) {
			// Throw an error
			NSAlert *alert = [NSAlert alertWithMessageText:@"Sorry, that project is already being cloned!"
							defaultButton:@"OK"
						  alternateButton:nil
							  otherButton:nil 
				informativeTextWithFormat:@"Please be patient."];
			NSImage *image = [NSImage imageNamed:@"octocat.jpeg"];
			[alert setIcon:image];
			[alert runModal];
			return;
		}
	}
	
	// Add the url to the job list, create a window, and start cloning
	[jobs addObject:url];
	MitosisCloneHandler *cloner = [[MitosisCloneHandler alloc] initWithURL:url];
	[cloner start];
}

#pragma mark Private Methods


- (void)findOrCreateMitosisConfig
{
	NSString *configFilePath = [[NSString stringWithFormat:@"%@/%@", kMitosisConfigPath, kMitosisConfigFilename, nil] stringByExpandingTildeInPath];
	NSData *yamlData = [NSData dataWithContentsOfFile:configFilePath];
	
	if (!yamlData) {
		NSLog(@"Mitosis config file not found. Attempting to create one.");
		[self createAndLoadConfig];
	} else {
		NSError *error = nil;
		NSArray *configArray = [YAMLSerialization YAMLWithData:yamlData options:kYAMLReadOptionImmutable|kYAMLReadOptionStringScalars error:&error];
		config = [[configArray objectAtIndex:0] retain];
		
		if (error) {
			NSLog(@"Error loading Mitosis config file: %@", [error localizedDescription]);
			exit(1);
		}
	}
	
}


- (void)createAndLoadConfig
{
	NSString *gitPath = [self findGit];
	config = [[NSDictionary alloc] initWithObjectsAndKeys:gitPath, kMitosisGitPath, @"~/Code", kMitosisWorkingDirectory, nil];
	
	NSString *configDirectoryPath = [[NSString stringWithString:kMitosisConfigPath] stringByExpandingTildeInPath];
	
	NSFileManager *fm = [NSFileManager defaultManager];
	NSError *error = nil;
	[fm createDirectoryAtPath:configDirectoryPath withIntermediateDirectories:YES attributes:nil error:&error];
	
	if (error) {
		NSLog(@"Error creating directory for Mitosis config file: %@", [error localizedDescription]);
		exit(1);
	}
	
	NSString *configFilePath = [NSString stringWithFormat:@"%@/%@", configDirectoryPath, kMitosisConfigFilename, nil];	
	NSOutputStream *outputStream = [NSOutputStream outputStreamToFileAtPath:configFilePath
																	 append:NO];
	
	error = nil;
	[YAMLSerialization writeYAML:config toStream:outputStream options:kYAMLWriteOptionSingleDocument error:&error];
	if (error) {
		NSLog(@"Error writing Mitosis config file: %@", [error localizedDescription]);
		exit(1);
	}
	
	NSLog(@"Mitosis successfully created a new config file at %@", configFilePath);
}

- (NSString *)findGit
{
	NSFileManager *fm = [NSFileManager defaultManager];
	
	// Check these paths in order.
	NSArray *pathsToCheck = [NSArray arrayWithObjects:@"/opt/local/bin/git", @"/usr/local/bin/git", @"/usr/bin/git", nil];
	for (NSString *filePath in pathsToCheck) {
		if ([fm fileExistsAtPath:filePath]) {
			return filePath;
		}
	}
	
	// If we got this far, we're in trouble.
	NSLog(@"Mitosis is unable to find git on this system. Are you sure git is installed?");
	
	// We should throw up a dialog box and tell the user to go fix their config and run Mitosis again.
	gitNotFound = YES;
	return @"/PATH_TO_YOUR_GIT";
}

- (void)checkJobs
{
	// If there's no jobs, we can quit, otherwise we should hang out.
	if ([jobs count] == 0) {
		NSLog(@"No jobs processing after 10 seconds, Mitosis is exiting...");
		[[NSApplication sharedApplication] terminate:self];
	} else {
		NSLog(@"Mitosis jobs still a runnin': %@", jobs);
	}
	
}

- (void)startTimerThread
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	// Every 10 seconds, check to see if we should quit or not.
	NSTimer *checkJobsTimer = [NSTimer timerWithTimeInterval:kCheckJobsInterval target:self selector:@selector(checkJobs) userInfo:nil repeats:YES];
	[[NSRunLoop currentRunLoop] addTimer:checkJobsTimer forMode:NSDefaultRunLoopMode];
	[[NSRunLoop currentRunLoop] run];
	
	[pool drain];
}


@end
