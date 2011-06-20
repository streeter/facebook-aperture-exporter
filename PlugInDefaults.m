//
//  PlugInDefaults.m
//  FacebookExporter
//
//  Created by Alexander Brand on 18.06.11.
//  Copyright Alex Brand. All rights reserved.
//

#import "PlugInDefaults.h"

#define kUserAuthenticated @"ApertureFacebookPluginDefaultAuthenticated"

@implementation PlugInDefaults

+ (BOOL)isUserAuthenticated
{
	NSString *pluginBundleID = [[[NSBundle bundleForClass: [self class]] infoDictionary] objectForKey:@"CFBundleIdentifier"];
	BundleUserDefaults *customDefaults = [[BundleUserDefaults alloc] initWithPersistentDomainName:pluginBundleID];
	BOOL bAuth = [customDefaults boolForKey:kUserAuthenticated];
	[customDefaults release];
	return bAuth;
}

+ (void)setUserAuthenticated:(BOOL)defaultAuthenticated
{
	NSString *pluginBundleID = [[[NSBundle bundleForClass: [self class]] infoDictionary] objectForKey:@"CFBundleIdentifier"];
	BundleUserDefaults *customDefaults = [[BundleUserDefaults alloc] initWithPersistentDomainName:pluginBundleID];
	[customDefaults setBool:defaultAuthenticated forKey:kUserAuthenticated];
	[customDefaults synchronize];
	[customDefaults release];
}

+ (void)removeUserAuthenticated
{
	NSString *pluginBundleID = [[[NSBundle bundleForClass: [self class]] infoDictionary] objectForKey:@"CFBundleIdentifier"];
	BundleUserDefaults *customDefaults = [[BundleUserDefaults alloc] initWithPersistentDomainName:pluginBundleID];
	[customDefaults removeObjectForKey:kUserAuthenticated];
	[customDefaults synchronize];
	[customDefaults release];
}

@end
