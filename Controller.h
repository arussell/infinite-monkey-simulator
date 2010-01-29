//
//  Controller.h
//  Monkey Simulator
//
//  Created by Aaron B. Russell on 2009-10-27.
//  Copyright 2009 Rocket Dog Creative. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Controller : NSObject {
	NSTextField *stringBeingTested;
	NSTextField *lastString;
	NSTextField *lastLength;
	NSTextField *lastMatches;
	NSTextField *lastContext;
	NSTextField *longestString;
	NSTextField *longestLength;
	NSTextField *longestMatches;
	NSTextField *longestContext;
	NSTextField *humanSeconds;
	NSTextField *monkeySeconds;
	NSButton *startButton;
	NSButton *stopButton;
	NSProgressIndicator *progressIndicator;
	bool *userWantsToAbort;
}

@property (assign) IBOutlet NSTextField *stringBeingTested;
@property (assign) IBOutlet NSTextField *lastString;
@property (assign) IBOutlet NSTextField *lastLength;
@property (assign) IBOutlet NSTextField *lastMatches;
@property (assign) IBOutlet NSTextField *lastContext;
@property (assign) IBOutlet NSTextField *longestString;
@property (assign) IBOutlet NSTextField *longestLength;
@property (assign) IBOutlet NSTextField *longestMatches;
@property (assign) IBOutlet NSTextField *longestContext;
@property (assign) IBOutlet NSTextField *humanSeconds;
@property (assign) IBOutlet NSTextField *monkeySeconds;
@property (assign) IBOutlet NSButton *startButton;
@property (assign) IBOutlet NSButton *stopButton;
@property (assign) IBOutlet NSProgressIndicator *progressIndicator;
@property (assign) bool *userWantsToAbort;

- (IBAction)startMonkeys:(id)sender;
- (IBAction)stopMonkeys:(id)sender;

@end
