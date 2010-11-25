//
//  FacebookRequestController.h
//  FacebookExporter
//
//  Created by Chris Streeter on 11/16/10.
//  Copyright 2010 chrisstreeter.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FacebookRequest.h"


@interface FacebookRequestController : NSObject <FacebookRequestDelegate>
{
	id _delegate;
	
	// Request Object
	FacebookRequest *_request;
	BOOL _startImmediately;
	
	// User authentication information
	NSString *_accessToken;
	
	NSAutoreleasePool *_pool;
	
}

@property(nonatomic,assign) NSString *accessToken;

#pragma mark -
// Delegate Setter
#pragma mark Delegate Setter
- (void)setDelegate:(id)delegate;

#pragma mark -
// User Authentication
#pragma mark User Authentication
- (void)getUserInformation:(NSString *)username;
- (void)logOut;

#pragma mark -
// Get Album List
#pragma mark Get Album List
- (void)getAlbumList:(NSString *)userid;

#pragma mark -
// Get Create Album
#pragma mark Create Album
- (void)createAlbum:(NSString *)userid albumName:(NSString *)aName albumDescription:(NSString *)aDescription;

#pragma mark -
// Get Upload Photo
#pragma mark Upload Photo
- (void)uploadPhoto:(NSString *)albumId imageName:(NSString *)aName imageData:(NSData *)data;


#pragma mark -
// Facebook Delegate Methods
#pragma mark Facebook Delegate Methods
- (void)requestWithMethodName:(NSString *)methodName andParams:(NSMutableDictionary *)params andHttpMethod:(NSString *)httpMethod andDelegate:(id <FacebookRequestDelegate>)delegate;
- (void)requestWithGraphPath:(NSString *)graphPath andDelegate:(id <FacebookRequestDelegate>)delegate;
- (void)requestWithGraphPath:(NSString *)graphPath andParams:(NSMutableDictionary *)params andDelegate:(id <FacebookRequestDelegate>)delegate;
- (void)requestWithGraphPath:(NSString *)graphPath andParams:(NSMutableDictionary *)params andHttpMethod:(NSString *)httpMethod andDelegate:(id <FacebookRequestDelegate>)delegate;
- (void)request:(FacebookRequest *)request didLoad:(id)result;

@end
