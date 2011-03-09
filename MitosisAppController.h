//
//  MitosisAppController.h
//  Mitosis
//
//  Created by Patrick B. Gibson on look, don't worry about it.
//

#import <Cocoa/Cocoa.h>
#import "MitosisCloneHandler.h"

#define kMitosisConfigPath			@"~/Library/Application Support/Mitosis/"
#define kMitosisConfigFilename		@"config.yaml"
#define kMitosisGitPath				@"Mitosis Git Path"
#define kMitosisWorkingDirectory	@"Mitosis Working Directory"

@interface MitosisAppController : NSApplication {
	NSMutableArray *jobs;
	NSDictionary *config;
	BOOL gitNotFound;
}

@property (retain) NSMutableArray *jobs;
@property (nonatomic, retain) NSDictionary *config;

- (void)findOrCreateMitosisConfig;

@end
