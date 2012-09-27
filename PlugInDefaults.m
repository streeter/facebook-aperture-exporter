//
//  PlugInDefaults.m
//  FacebookExporter
//
//  Created by Alexander Brand on 18.06.11.
//  Copyright Alex Brand. All rights reserved.
//

#import "PlugInDefaults.h"

#define kUserAuthenticated @"ApertureFacebookPluginDefaultAuthenticated"
#define	kOpenFacebookOnFinish @"OpenFacebookOnFinish"
#define kUseIPTCHeader @"UseIPTCHeader"

@implementation PlugInDefaults

+ (BOOL)isUserAuthenticated
{
	NSString *pluginBundleID = [[[NSBundle bundleForClass: [self class]] infoDictionary] objectForKey:@"CFBundleIdentifier"];
	BundleUserDefaults *customDefaults = [[[BundleUserDefaults alloc] initWithPersistentDomainName:pluginBundleID] autorelease];
	return [customDefaults boolForKey:kUserAuthenticated];
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

+ (BOOL)isOpenFacebookOnFinish
{
	NSString *pluginBundleID = [[[NSBundle bundleForClass: [self class]] infoDictionary] objectForKey:@"CFBundleIdentifier"];
	BundleUserDefaults *customDefaults = [[[BundleUserDefaults alloc] initWithPersistentDomainName:pluginBundleID] autorelease];
	return [customDefaults boolForKey:kOpenFacebookOnFinish];
}

+ (void)setOpenFacebookOnFinish:(BOOL)openOnFinish
{
	NSString *pluginBundleID = [[[NSBundle bundleForClass: [self class]] infoDictionary] objectForKey:@"CFBundleIdentifier"];
	BundleUserDefaults *customDefaults = [[BundleUserDefaults alloc] initWithPersistentDomainName:pluginBundleID];
	[customDefaults setBool:openOnFinish forKey:kOpenFacebookOnFinish];
	[customDefaults synchronize];
	[customDefaults release];
}

+ (BOOL)isUseIPTCHeader
{
    NSString *pluginBundleID = [[[NSBundle bundleForClass: [self class]] infoDictionary] objectForKey:@"CFBundleIdentifier"];
	BundleUserDefaults *customDefaults = [[[BundleUserDefaults alloc] initWithPersistentDomainName:pluginBundleID] autorelease];
	return [customDefaults boolForKey:kUseIPTCHeader];
}

+ (void)setUseIPTCHeader:(BOOL)useIPTCHeader
{
    NSString *pluginBundleID = [[[NSBundle bundleForClass: [self class]] infoDictionary] objectForKey:@"CFBundleIdentifier"];
	BundleUserDefaults *customDefaults = [[BundleUserDefaults alloc] initWithPersistentDomainName:pluginBundleID];
	[customDefaults setBool:useIPTCHeader forKey:kUseIPTCHeader];
	[customDefaults synchronize];
	[customDefaults release];
}

@end
