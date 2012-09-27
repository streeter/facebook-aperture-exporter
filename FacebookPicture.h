//
//  FacebookPicture.h
//  FacebookExporter
//
//  Created by Chris Streeter on 11/7/10.
//  Copyright 2010 chrisstreeter.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PlugInDefaults.h"


@interface FacebookPicture : NSObject {
	NSString *_title;
	NSString *_description;
    NSString *_caption;
    NSString *_iptcHeadline;
	NSArray *_keywords;  // Array of NSStrings
	NSImage *_defaultThumbnail;
	BOOL _uploadExifInformation;
	BOOL _uploadDescription;
	BOOL _uploadKeywords;
	NSData *_data;
	NSString *_path;
}

#pragma mark Accessors

- (NSString *)title;
- (void)setTitle:(NSString *)aValue;

- (NSString *)description;
- (void)setDescription:(NSString *)aValue;

- (NSString *)iptcHeadline;
- (void)setIptcHeadline:(NSString *)aValue;

- (NSString *)caption;
- (void)setCaption:(NSString *)aValue;

- (BOOL)uploadDescription;
- (void)setUploadDescription:(BOOL)aValue;

- (NSImage *)defaultThumbnail;
- (void)setDefaultThumbnail:(NSImage *)aValue;

- (void)setData:(NSData *)aValue;
- (NSData *)data;

- (void)setPath:(NSString *)aValue;
- (NSString *)path;
@end
