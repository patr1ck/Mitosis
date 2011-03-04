//
//  MitosisJobHandler.h
//  Mitosis
//
//  Created by Patrick B. Gibson on 3/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MitosisAppController;

@interface MitosisJobHandler : NSObject {
	IBOutlet NSWindow *window;
	IBOutlet NSProgressIndicator *progressBar;
	IBOutlet NSTextField *label;
	
	NSURL *url;
	NSTask *gitTask;
}

- (id)initWithURL:(NSURL *)inURL;

- (IBAction)cancel:(id)sender;

@end
