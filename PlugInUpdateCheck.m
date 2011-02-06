//
//  PlugInUpdateCheck.m
//  FacebookExporter
//
//  Created by Alex Brand on 18.06.11.
//  Copyright 2011 Alex Brand. All rights reserved.
//

#import "PlugInUpdateCheck.h"


@implementation PlugInUpdateCheck

+ (BOOL)isUpdateAvailable
{
	NSURL *appcastURL = [NSURL URLWithString:[[[NSBundle bundleForClass:[self class]] infoDictionary] objectForKey:@"SUFeedURL"]];
	
	NSMutableArray *versionList = [[NSMutableArray alloc] init];
	NSData *castData = [NSData dataWithContentsOfURL:appcastURL];
	CXMLDocument *doc = [[[CXMLDocument alloc] initWithData:castData options:0 error:nil] autorelease];
	
	NSArray *nodes = NULL;
	nodes = [doc nodesForXPath:@"//channel//item//enclosure" error:nil];
	
	for (CXMLElement *node in nodes) {
		NSMutableDictionary *item = [[NSMutableDictionary alloc] init];
		int counter;
		for(counter = 0; counter < [node childCount]; counter++) {
			[item setObject:[[node childAtIndex:counter] stringValue] forKey:[[node childAtIndex:counter] name]];
		}
	
		[item setObject:[[node attributeForName:@"sparkle:version"] stringValue] forKey:@"sparkle:version"];
		
		[versionList addObject:item];
		[item release];
	}
	
	if ([versionList count] == 0) {
		[versionList release];
		return NO;
	}
	
	NSString *pluginVersion = [[[NSBundle bundleForClass:[self class]] infoDictionary] objectForKey:@"CFBundleShortVersionString"];	
	NSString *latestVersion = pluginVersion;
	
	// search the latest Version
	for (NSDictionary *dic in versionList) {
		NSString *_version = [NSString stringWithString: [dic valueForKey:@"sparkle:version"]];
		NSComparisonResult verResult = [[PlugInSUStandardVersionComparator defaultComparator] compareVersion:pluginVersion toVersion:_version];
		
		if (verResult == NSOrderedAscending) {
			NSComparisonResult verRes = [[PlugInSUStandardVersionComparator defaultComparator] compareVersion:latestVersion toVersion:_version];
			if (verRes == NSOrderedAscending) {
				latestVersion = _version;
			}
		}
	}
	
	[versionList release];
	
	NSComparisonResult verResult = [[PlugInSUStandardVersionComparator defaultComparator] compareVersion:pluginVersion toVersion:latestVersion];
	switch (verResult) {
		case NSOrderedAscending:
			// New Version available -> "b > a"
			return YES;
			break;
		case NSOrderedDescending:
			// "b < a"
			break;
		case NSOrderedSame:
			// "b = a"
			break;
		default:
			break;
	}
	
	return NO;
}


@end
