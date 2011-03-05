//
//  MitosisJobHandler.h
//  Mitosis
//
//  Created by Patrick B. Gibson on 3/1/11.
//

#import <Cocoa/Cocoa.h>

@class MitosisAppController;

@interface MitosisCloneHandler : NSObject {
	IBOutlet NSWindow *window;
	IBOutlet NSProgressIndicator *progressBar;
	IBOutlet NSTextField *label;
	
	NSString *projectName;
	
	NSURL *url;
}

- (id)initWithURL:(NSURL *)inURL;
- (void)start;

- (IBAction)cancel:(id)sender;

@end
