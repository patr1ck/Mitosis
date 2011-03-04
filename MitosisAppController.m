//
//  MitosisAppController.m
//  Mitosis
//
//  Created by Patrick B. Gibson on 3/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <YAML/YAMLSerialization.h>

#import "MitosisAppDelegate.h"
#import "MitosisAppController.h"
#import "MitosisJobHandler.h"

#define kMitosisConfigPath			@"~/Library/Application Support/Mitosis/"
#define kMitosisConfigFilename		@"config.yaml"
#define kMitosisGitPath				@"Mitosis Git Path"
#define kMitosisWorkingDirectory	@"Mitosis Working Directory"

@interface MitosisAppController (Private)

- (void)createAndLoadConfig;
- (NSString *)findGit;
- (void)startTimerThread;

@end

@implementation MitosisAppController

@synthesize jobs;

- (id) init
{
	self = [super init];
	if (self != nil) {
		// Initialize the jobs list
		jobs = [[NSMutableArray alloc] initWithCapacity:10];
		gitNotFound = NO;
		
		MitosisAppDelegate *delegate = [[MitosisAppDelegate alloc] init];
		self.delegate = delegate;
		//jobHandler = [[MitosisJobHandler alloc] initWithController:self];
		
	}
	return self;
}


- (void)handleGetURLEvent:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent
{
	NSURL *url = [NSURL URLWithString:[[event paramDescriptorForKeyword:keyDirectObject] stringValue]];
    NSLog(@"url = %@", url); 
	
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
	
	[jobs addObject:url];
	[[MitosisJobHandler alloc] initWithURL:url];
	
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
		config = [configArray objectAtIndex:0];
		
		NSLog(@"config: %@", config);
		
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
	NSTimer *jobTimeOutTimer = [NSTimer timerWithTimeInterval:10 target:self selector:@selector(checkJobs) userInfo:nil repeats:YES];
	[[NSRunLoop currentRunLoop] addTimer:jobTimeOutTimer forMode:NSDefaultRunLoopMode];
	[[NSRunLoop currentRunLoop] run];
	[pool drain];
}


@end
