//
//  MitosisAppController.h
//  Mitosis
//
//  Created by Patrick B. Gibson on 3/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MitosisJobHandler.h"

@interface MitosisAppController : NSApplication {
	NSMutableArray *jobs;
	NSDictionary *config;
	BOOL gitNotFound;
}

@property (retain) NSMutableArray *jobs;

- (void)findOrCreateMitosisConfig;

@end
