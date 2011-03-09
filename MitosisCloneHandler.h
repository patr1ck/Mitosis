//
//  MitosisCloneHandler.h
//  Mitosis
//
//  Created by Patrick B. Gibson on look, don't worry about it.
//

#import <Cocoa/Cocoa.h>

@class MitosisAppController;

@interface MitosisCloneHandler : NSObject {
	IBOutlet NSWindow *window;
	IBOutlet NSProgressIndicator *progressBar;
	IBOutlet NSTextField *label;
	
	NSString *projectName;
	NSURL *url;
	
	NSTask		*_gitTask;
	NSString	*_workingDirPath;
	NSString	*_gitPath;
	NSArray		*_gitArguments;
	BOOL		_userDidCancel;
}

- (id)initWithURL:(NSURL *)inURL;
- (void)start;

- (IBAction)cancel:(id)sender;

@end
