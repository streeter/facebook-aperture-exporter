//
//  FacebookPicture.m
//  FacebookExporter
//
//  Created by Chris Streeter on 11/7/10.
//  Copyright 2010 chrisstreeter.com. All rights reserved.
//

#import "FacebookPicture.h"


@implementation FacebookPicture

- (id)init
{
	if (self = [super init])
	{
		[self setTitle:@"FacebookPicture"];
		[self setDescription:@""];
        [self setCaption:@""];
        [self setIptcHeadline:@""];
		[self setDefaultThumbnail:nil];
		[self setPath:nil];
		
		[self setUploadDescription:YES];
	}
	return self;
}

- (void)dealloc
{
	[self setTitle:nil];
	[self setDescription:nil];
    [self setCaption:nil];
    [self setIptcHeadline:nil];
	[self setDefaultThumbnail:nil];
	[self setPath:nil];
	
	[super dealloc];
}


#pragma mark -
#pragma mark Accessors

- (NSString *)title
{
	return _title;
}

- (void)setTitle:(NSString *)aValue
{
	//NSLog(@"Setting title: %@", aValue);
	NSString *oldTitle = _title;
	_title = [aValue copy];
	[oldTitle release];
}

- (NSString *)description
{
    if ([PlugInDefaults isUseIPTCHeader])
        return [self iptcHeadline];
    else
        return [self title];
}

- (void)setDescription:(NSString *)aValue
{
	//NSLog(@"Setting description: %@", aValue);
	NSString *oldDescription = _description;
	_description = [aValue copy];
	[oldDescription release];
}

- (NSString *)caption
{
	return _caption;
}

- (void)setCaption:(NSString *)aValue
{
	NSString *oldCaption = _caption;
	_caption = [aValue copy];
	[oldCaption release];
}

- (NSString *)iptcHeadline
{
    return _iptcHeadline;
}

- (void)setIptcHeadline:(NSString *)aValue
{
    NSString *oldIptcHeadline = _iptcHeadline;
	_iptcHeadline = [aValue copy];
	[oldIptcHeadline release];
}

- (BOOL)uploadDescription
{
	return _uploadDescription;
}

- (void)setUploadDescription:(BOOL)aValue
{
	_uploadDescription = aValue;
}

- (NSImage *)defaultThumbnail
{
	return _defaultThumbnail;
}

- (void)setDefaultThumbnail:(NSImage *)aValue
{
	NSImage *oldDefaultThumbnail = _defaultThumbnail;
	_defaultThumbnail = [aValue retain];
	[oldDefaultThumbnail release];
}

- (void)setData:(NSData *)aValue
{
	NSData *oldValue = _data;
	_data = [aValue copy];
	[oldValue release];
}
// autoload data, if necessary
- (NSData *)data
{
	if (_data == nil && _path != nil) {
		_data = [NSData dataWithContentsOfFile:_path];
	}
	return _data;
}

- (void)setPath:(NSString *)aValue
{
	NSString *oldValue = _path;
	_path = [aValue copy];
	[oldValue release];
}
- (NSString *)path
{
	return _path;
}

@end
