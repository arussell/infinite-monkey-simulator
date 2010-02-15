//
//  Controller.m
//  Monkey Simulator
//
//  Created by Aaron B. Russell on 2009-10-27.
//  Copyright 2009 Rocket Dog Creative. Released under the New BSD License.
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
	if (![fileManager fileExistsAtPath:[simStorage stringByAppendingPathComponent:@"progress.plist"]]) {
		[fileManager copyItemAtPath:[[NSBundle mainBundle] pathForResource:@"progress" ofType:@"plist"] toPath:[simStorage stringByAppendingPathComponent:@"progress.plist"] error:&error];
	}
	if (![fileManager fileExistsAtPath:[simStorage stringByAppendingPathComponent:@"log.tsv"]]) {
		[fileManager copyItemAtPath:[[NSBundle mainBundle] pathForResource:@"log" ofType:@"tsv"] toPath:[simStorage stringByAppendingPathComponent:@"log.tsv"] error:&error];
	}
	dispatch_async(queue,^{
		NSError *error;
		int minimumToShow = 4;
		int numberOfPossibleCharacters = 31;
		NSArray *possibleCharacters = [NSArray arrayWithObjects:@"a",@"b",@"c",@"d",@"e",@"f",@"g",@"h",@"i",@"j",@"k",@"l",@"m",@"n",@"o",@"p",@"q",@"r",@"s",@"t",@"u",@"v",@"w",@"x",@"y",@"z",@" ",@",",@".",@";",@"-",nil];
		
		NSString *errorString = [NSString stringWithString:@""];
		NSPropertyListFormat format;
		NSData *progressData = [fileManager contentsAtPath:[simStorage stringByAppendingPathComponent:@"progress.plist"]];
		NSMutableDictionary *progressDictionary = [NSPropertyListSerialization propertyListFromData:progressData mutabilityOption:NSPropertyListMutableContainersAndLeaves format:&format errorDescription:&errorString];
		
		NSTimeInterval timeElapsed = [[progressDictionary objectForKey:@"timeElapsed"] intValue];
		int totalKeypresses = [[progressDictionary objectForKey:@"totalKeypresses"] intValue];
		NSString *previousString = [progressDictionary objectForKey:@"previousString"];
		int previousLength = [[progressDictionary objectForKey:@"previousLength"] intValue];
		int previousMatches = [[progressDictionary objectForKey:@"previousMatches"] intValue];
		NSString *previousContext = [progressDictionary objectForKey:@"previousContext"];
		NSString *bestString = [progressDictionary objectForKey:@"bestString"];
		int bestLength = [[progressDictionary objectForKey:@"bestLength"] intValue];
		int bestMatches = [[progressDictionary objectForKey:@"bestMatches"] intValue];
		NSString *bestContext = [progressDictionary objectForKey:@"bestContext"];
		[lastString setStringValue:previousString];
		[lastLength setIntValue:previousLength];
		[lastMatches setIntValue:previousMatches];
		[lastContext setStringValue:previousContext];
		[longestString setStringValue:bestString];
		[longestLength setIntValue:bestLength];
		[longestMatches setIntValue:bestMatches];
		[longestContext setStringValue:bestContext];
		
		int numberOfMatches = 0;
		int keysSinceLastSave = 0;
		int initialLoop = 0;

		NSString *monkeyKeypresses;
		NSArray *theWorks = [[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"shakespeare" ofType:@"txt"] encoding:NSUTF8StringEncoding error:&error] componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
		NSString *firstMatchString = [NSString stringWithString:@""];
		NSTimeInterval startTime = [NSDate timeIntervalSinceReferenceDate] - timeElapsed;
		NSTimeInterval endTime;
		while (userWantsToAbort == false) {
			if (keysSinceLastSave > 500) {
				endTime = [NSDate timeIntervalSinceReferenceDate];
				timeElapsed = endTime - startTime;
				[progressDictionary setValue:[NSNumber numberWithInt:timeElapsed] forKey:@"timeElapsed"];
				[progressDictionary setValue:[NSNumber numberWithInt:totalKeypresses] forKey:@"totalKeypresses"];
				[progressDictionary setValue:previousString forKey:@"previousString"];
				[progressDictionary setValue:[NSNumber numberWithInt:previousLength] forKey:@"previousLength"];
				[progressDictionary setValue:[NSNumber numberWithInt:previousMatches] forKey:@"previousMatches"];
				[progressDictionary setValue:previousContext forKey:@"previousContext"];
				[progressDictionary setValue:bestString forKey:@"bestString"];
				[progressDictionary setValue:[NSNumber numberWithInt:bestLength] forKey:@"bestLength"];
				[progressDictionary setValue:[NSNumber numberWithInt:bestMatches] forKey:@"bestMatches"];
				[progressDictionary setValue:bestContext forKey:@"bestContext"];
				progressData = [NSPropertyListSerialization dataFromPropertyList:progressDictionary format:NSPropertyListXMLFormat_v1_0 errorDescription:&errorString];
				[progressData writeToFile:[simStorage stringByAppendingPathComponent:@"progress.plist"] atomically:YES];
				keysSinceLastSave = 0;
			}
			monkeyKeypresses = [NSString stringWithString:@""];
			for (initialLoop = 1; initialLoop <= minimumToShow; initialLoop++) {
				monkeyKeypresses = [NSString stringWithFormat:@"%@%@",monkeyKeypresses,[possibleCharacters objectAtIndex:(arc4random() % numberOfPossibleCharacters)]];
				totalKeypresses++;
				keysSinceLastSave++;
			}
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
					if ([monkeyKeypresses length] > bestLength) {
						NSString *logFileContents = [[NSString alloc] initWithContentsOfFile:[simStorage stringByAppendingPathComponent:@"log.tsv"]];
						NSString *newLogFileContents = [NSString stringWithFormat:@"%@%@\t%@\t%@\t%@\t%@\n",logFileContents,[[NSNumber numberWithInt:totalKeypresses] stringValue],monkeyKeypresses,[[NSNumber numberWithInt:[monkeyKeypresses length]] stringValue],[[NSNumber numberWithInt:numberOfMatches] stringValue],thisLine];
						[newLogFileContents writeToFile:[simStorage stringByAppendingPathComponent:@"log.tsv"] atomically:YES encoding:NSUTF8StringEncoding error:&error];
					}
				}
			}
			while (numberOfMatches > 0) {
				previousString = monkeyKeypresses;
				previousLength = [monkeyKeypresses length];
				previousMatches = numberOfMatches;
				previousContext = firstMatchString;
				[lastString setStringValue:previousString];
				[lastLength setIntValue:previousLength];
				[lastMatches setIntValue:previousMatches];
				[lastContext setStringValue:previousContext];
				if ([monkeyKeypresses length] > bestLength) {
					bestString = monkeyKeypresses;
					bestLength = [monkeyKeypresses length];
					bestMatches = numberOfMatches;
					bestContext = firstMatchString;
					[longestString setStringValue:bestString];
					[longestLength setIntValue:bestLength];
					[longestMatches setIntValue:bestMatches];
					[longestContext setStringValue:bestContext];
				}
				monkeyKeypresses = [NSString stringWithFormat:@"%@%@",monkeyKeypresses,[possibleCharacters objectAtIndex:(arc4random() % numberOfPossibleCharacters)]];
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
						if ([monkeyKeypresses length] > bestLength) {
							NSString *logFileContents = [[NSString alloc] initWithContentsOfFile:[simStorage stringByAppendingPathComponent:@"log.tsv"]];
							NSString *newLogFileContents = [NSString stringWithFormat:@"%@%@\t%@\t%@\t%@\t%@\n",logFileContents,[[NSNumber numberWithInt:totalKeypresses] stringValue],monkeyKeypresses,[[NSNumber numberWithInt:[monkeyKeypresses length]] stringValue],[[NSNumber numberWithInt:numberOfMatches] stringValue],thisLine];
							[newLogFileContents writeToFile:[simStorage stringByAppendingPathComponent:@"log.tsv"] atomically:YES encoding:NSUTF8StringEncoding error:&error];
						}
					}
				}
			}
		}
		endTime = [NSDate timeIntervalSinceReferenceDate];
		timeElapsed = endTime - startTime;
		[progressDictionary setValue:[NSNumber numberWithInt:timeElapsed] forKey:@"timeElapsed"];
		[progressDictionary setValue:[NSNumber numberWithInt:totalKeypresses] forKey:@"totalKeypresses"];
		[progressDictionary setValue:previousString forKey:@"previousString"];
		[progressDictionary setValue:[NSNumber numberWithInt:previousLength] forKey:@"previousLength"];
		[progressDictionary setValue:[NSNumber numberWithInt:previousMatches] forKey:@"previousMatches"];
		[progressDictionary setValue:previousContext forKey:@"previousContext"];
		[progressDictionary setValue:bestString forKey:@"bestString"];
		[progressDictionary setValue:[NSNumber numberWithInt:bestLength] forKey:@"bestLength"];
		[progressDictionary setValue:[NSNumber numberWithInt:bestMatches] forKey:@"bestMatches"];
		[progressDictionary setValue:bestContext forKey:@"bestContext"];
		progressData = [NSPropertyListSerialization dataFromPropertyList:progressDictionary format:NSPropertyListXMLFormat_v1_0 errorDescription:&errorString];
		[progressData writeToFile:[simStorage stringByAppendingPathComponent:@"progress.plist"] atomically:YES];
	});
}

- (IBAction)stopMonkeys:(id)sender {
	userWantsToAbort = TRUE;
	[progressIndicator stopAnimation:progressIndicator];
	[startButton setEnabled:TRUE];
	[stopButton setEnabled:FALSE];
}

@end
