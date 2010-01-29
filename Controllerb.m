//
//  Controller.m
//  Monkey Simulator
//
//  Created by Aaron B. Russell on 2009-10-27.
//  Copyright 2009 Rocket Dog Creative. All rights reserved.
//

#import "Controller.h"

@implementation Controller

@synthesize stringBeingTested;
@synthesize lastString;
@synthesize lastLength;
@synthesize lastMatches;
@synthesize lastContext;
@synthesize longestString;
@synthesize longestLength;
@synthesize longestMatches;
@synthesize longestContext;
@synthesize humanSeconds;
@synthesize monkeySeconds;
@synthesize startButton;
@synthesize stopButton;
@synthesize progressIndicator;
@synthesize userWantsToAbort;

- (IBAction)startMonkeys:(id)sender {
	//dispatch_queue_t main = dispatch_get_main_queue();
	dispatch_queue_t queue = dispatch_get_global_queue(0,0);
	NSError *error;
	NSArray *allPaths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, TRUE);
	NSString *userApplicationSupportDirectory = [allPaths objectAtIndex:0];
	NSString *simStorage = [userApplicationSupportDirectory stringByAppendingPathComponent:@"Monkey Simulator/"];
	userWantsToAbort = false;
	[progressIndicator startAnimation:progressIndicator];
	[startButton setEnabled:FALSE];
	[stopButton setEnabled:TRUE];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if (![fileManager fileExistsAtPath:simStorage]) {
		[fileManager createDirectoryAtPath:simStorage withIntermediateDirectories:FALSE attributes:[fileManager attributesOfItemAtPath:userApplicationSupportDirectory error:&error] error:&error];
	}
	if (![fileManager fileExistsAtPath:[simStorage stringByAppendingPathComponent:@"progress.tsv"]]) {
		[fileManager copyItemAtPath:[[NSBundle mainBundle] pathForResource:@"progress" ofType:@"tsv"] toPath:[simStorage stringByAppendingPathComponent:@"progress.tsv"] error:&error];
	}
	if (![fileManager fileExistsAtPath:[simStorage stringByAppendingPathComponent:@"log.tsv"]]) {
		[fileManager copyItemAtPath:[[NSBundle mainBundle] pathForResource:@"log" ofType:@"tsv"] toPath:[simStorage stringByAppendingPathComponent:@"log.tsv"] error:&error];
	}
	dispatch_async(queue,^{
		NSError *error;
		int minimumToShow = 4;
		int numberOfPossibleCharacters = 31;
		NSArray *possibleCharacters = [NSArray arrayWithObjects:@"a",@"b",@"c",@"d",@"e",@"f",@"g",@"h",@"i",@"j",@"k",@"l",@"m",@"n",@"o",@"p",@"q",@"r",@"s",@"t",@"u",@"v",@"w",@"x",@"y",@"z",@" ",@",",@".",@";",@"-",nil];
		
		NSArray *progressArray = [[NSString stringWithContentsOfFile:[simStorage stringByAppendingPathComponent:@"progress.tsv"] encoding:NSUTF8StringEncoding error:&error] componentsSeparatedByString:@"\t"];
		int totalKeypresses = [[progressArray objectAtIndex:0] intValue];

		NSString *previousString = [progressArray objectAtIndex:1];
		int previousLength = [[progressArray objectAtIndex:2] intValue];
		int previousMatches = [[progressArray objectAtIndex:3] intValue];
		NSString *previousContext = [progressArray objectAtIndex:4];
		NSString *bestString = [progressArray objectAtIndex:5];
		int bestLength = [[progressArray objectAtIndex:6] intValue];
		int bestMatches = [[progressArray objectAtIndex:7] intValue];
		NSString *bestContext = [progressArray objectAtIndex:8];

		int numberOfMatches = 0;
		int keysSinceLastSave = 0;
		int initialLoop = 0;

		NSString *monkeyKeypresses;
		NSArray *theWorks = [[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"shakespeare" ofType:@"txt"] encoding:NSUTF8StringEncoding error:&error] componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
		NSString *firstMatchString = [NSString stringWithString:@""];
		NSTimeInterval startTime = [NSDate timeIntervalSinceReferenceDate];
		while (userWantsToAbort == false) {
			/*if (keysSinceLastSave > 100) {
				[progressDictionary setValue:totalKeypresses forKey:@"totalKeypresses"];
				[progressDictionary setValue:previousString forKey:@"previousString"];
				[progressDictionary setValue:previousLength forKey:@"previousLength"];
				[progressDictionary setValue:previousMatches forKey:@"previousMatches"];
				[progressDictionary setValue:previousContext forKey:@"previousContext"];
				[progressDictionary setValue:bestString forKey:@"bestString"];
				[progressDictionary setValue:bestLength forKey:@"bestLength"];
				[progressDictionary setValue:bestMatches forKey:@"bestMatches"];
				[progressDictionary setValue:bestContext forKey:@"bestContext"];
				NSLog(@"trying to save...");
				if ([progressDictionary writeToFile:[simStorage stringByAppendingPathComponent:@"progress.plist"] atomically:YES]) {
					NSLog(@"...success!");
				} else {
					NSLog(@"...failed.");
				}
				keysSinceLastSave = 0;
			}*/
			monkeyKeypresses = [NSString stringWithString:@""];
			for (initialLoop = 1; initialLoop <= minimumToShow; initialLoop++) {
				monkeyKeypresses = [NSString stringWithFormat:@"%@%@",monkeyKeypresses,[possibleCharacters objectAtIndex:(random() % numberOfPossibleCharacters)]];
				totalKeypresses++;
				keysSinceLastSave++;
			}
			NSTimeInterval endTime = [NSDate timeIntervalSinceReferenceDate];
			NSTimeInterval timeElapsed = endTime - startTime;
			[stringBeingTested setStringValue:monkeyKeypresses];
			[humanSeconds setIntValue:timeElapsed];
			[monkeySeconds setIntValue:totalKeypresses];
			numberOfMatches = 0;
			for (NSString *thisLine in theWorks) {
				if ([thisLine rangeOfString:monkeyKeypresses].length) {
					numberOfMatches++;
					if (numberOfMatches == 1) {
						firstMatchString = thisLine;
					}
				}
			}
			while (numberOfMatches > 0) {
				previousString = monkeyKeypresses;
				previousLength = [monkeyKeypresses length];
				previousMatches = numberOfMatches;
				previousContext = firstMatchString;
				[lastString setStringValue:monkeyKeypresses];
				[lastLength setIntValue:[monkeyKeypresses length]];
				[lastMatches setIntValue:numberOfMatches];
				[lastContext setString:firstMatchString];
				if ([monkeyKeypresses length] > bestLength) {
					bestString = monkeyKeypresses;
					bestLength = [monkeyKeypresses length];
					bestMatches = numberOfMatches;
					bestContext = firstMatchString;
					[longestString setStringValue:bestString];
					[longestLength setIntValue:bestLength];
					[longestMatches setIntValue:bestMatches];
					[longestContext setString:bestContext];
					NSString *logFileContents = [[NSString alloc] initWithContentsOfFile:[simStorage stringByAppendingPathComponent:@"log.tsv"]];
					NSString *newLogFileContents = [NSString stringWithFormat:@"%@%@\t%@\t%@\t%@\n",logFileContents,bestString,[[NSNumber numberWithInt:bestLength] stringValue],[[NSNumber numberWithInt:bestMatches] stringValue],bestContext];
					[newLogFileContents writeToFile:[simStorage stringByAppendingPathComponent:@"log.tsv"] atomically:YES encoding:NSUTF8StringEncoding error:&error];
				}
				monkeyKeypresses = [NSString stringWithFormat:@"%@%@",monkeyKeypresses,[possibleCharacters objectAtIndex:(random() % numberOfPossibleCharacters)]];
				totalKeypresses++;
				endTime = [NSDate timeIntervalSinceReferenceDate];
				timeElapsed = endTime - startTime;
				[stringBeingTested setStringValue:monkeyKeypresses];
				[humanSeconds setIntValue:timeElapsed];
				[monkeySeconds setIntValue:totalKeypresses];
				numberOfMatches = 0;
				for (NSString *thisLine in theWorks) {
					if ([thisLine rangeOfString:monkeyKeypresses].length) {
						numberOfMatches++;
						if (numberOfMatches == 1) {
							firstMatchString = thisLine;
						}
					}
				}
			}
		}
		NSString *progressSaveString = [NSString stringWithFormat:@"%@\t%@\t%@\t%@\t%@\t%@\t%@\t%@\t%@",totalKeypresses,previousString,[[NSNumber numberWithInt:previousLength] stringValue],[[NSNumber numberWithInt:previousMatches] stringValue],previousContext,bestString,[[NSNumber numberWithInt:bestLength] stringValue],[[NSNumber numberWithInt:bestMatches] stringValue],bestContext];
		[progressSaveString writeToFile:[simStorage stringByAppendingPathComponent:@"progress.tsv"] atomically:YES encoding:NSUTF8StringEncoding error:&error];
	});
}

- (IBAction)stopMonkeys:(id)sender {
	userWantsToAbort = TRUE;
	[progressIndicator stopAnimation:progressIndicator];
	[startButton setEnabled:TRUE];
	[stopButton setEnabled:FALSE];
}

@end
