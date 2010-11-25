//
//  FacebookAlbum.m
//  FacebookExporter
//
//  Created by Chris Streeter on 11/7/10.
//  Copyright 2010 chrisstreeter.com. All rights reserved.
//

#import "FacebookAlbum.h"


@implementation FacebookAlbum

- (id)init
{
	if (self = [super init])
	{
		[self setAlbumName:@"FacebookAlbum"];
		[self setAlbumID:@"1"];
		[self setLink:nil];
	}
	return self;
}

- (void)dealloc
{
	[self setAlbumName:nil];
	[self setAlbumID:nil];
	[self setLink:nil];
	
	[super dealloc];
}


#pragma mark -
#pragma mark Accessors

- (NSString *)albumName
{
	return _albumName;
}

- (void)setAlbumName:(NSString *)aValue
{
	NSString *oldName = _albumName;
	_albumName = [aValue copy];
	[oldName release];
}

- (NSString *)albumID
{
	return _albumID;
}

- (void)setAlbumID:(NSString *)aValue
{
	NSString *oldID = _albumID;
	_albumID = [aValue copy];
	[oldID release];
}

- (NSString *)link
{
	return _link;
}

- (void)setLink:(NSString *)aValue
{
	NSString *oldLink = _link;
	_link = [aValue copy];
	[oldLink release];
}

@end
