//
//  FacebookAlbum.h
//  FacebookExporter
//
//  Created by Chris Streeter on 11/7/10.
//  Copyright 2010 chrisstreeter.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface FacebookAlbum : NSObject {
	NSString *_albumName;
	NSString *_albumID;
	NSString *_link;
}

#pragma mark Accessors

- (NSString *)albumName;
- (void)setAlbumName:(NSString *)aValue;
- (NSString *)albumID;
- (void)setAlbumID:(NSString *)aValue;
- (NSString *)link;
- (void)setLink:(NSString *)aValue;

@end
