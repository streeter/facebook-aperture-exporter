//
//  FacebookRequestController.m
//  FacebookExporter
//
//  Created by Chris Streeter on 11/16/10.
//  Copyright 2010 chrisstreeter.com. All rights reserved.
//

#import "FacebookRequestController.h"
#import "FacebookExporter.h"
#import "FacebookAlbum.h"

@interface FacebookRequestController(PrivateMethods)


- (void)_openUrl:(NSString *)url params:(NSMutableDictionary *)params httpMethod:(NSString *)httpMethod delegate:(id<FacebookRequestDelegate>)delegate;
@end

static NSString *kGraphBaseURL = @"https://graph.facebook.com/";
static NSString *kRestApiURL = @"https://api.facebook.com/method/";
//static NSString *kUIServerBaseURL = @"http://www.facebook.com/connect/uiserver.php";
// Use this url when you pass access token to the server
//static NSString *kUIServerSecureURL = @"https://www.facebook.com/connect/uiserver.php";

@implementation FacebookRequestController

@synthesize	accessToken	= _accessToken;


- (void)dealloc
{	
	[_accessToken release];
	[_request release];
	
	[super dealloc];
}

#pragma mark -
// Delegate Setter
#pragma mark Delegate Setter
- (void)setDelegate:(id)delegate
{
	_delegate = delegate;
}

#pragma mark -
// User Authentication
#pragma mark User Authentication
- (void)getUserInformation:(NSString *)username
{	
	_startImmediately = NO;
	
	// Get the user's information
	[self requestWithGraphPath:username andDelegate:self];
}

- (void)logOut
{
	_startImmediately = NO;
	
	NSMutableDictionary *params = [[NSMutableDictionary alloc] init]; 
	[self requestWithMethodName:@"auth.expireSession"
					  andParams:params
				  andHttpMethod:@"GET"
					andDelegate:nil];
	[params release];
}

#pragma mark -
// Get Album List
#pragma mark Get Album List
- (void)getAlbumList:(NSString *)userid
{
	_startImmediately = NO;
	
	NSString *path = [NSString stringWithFormat:@"%@/albums", userid];
	[self requestWithGraphPath:path andDelegate:self];
}

#pragma mark -
// Get Create Album
#pragma mark Create Album
- (void)createAlbum:(NSString *)userid albumName:(NSString *)aName albumDescription:(NSString *)aDescription
{
	_startImmediately = NO;
	
	NSString *path = [NSString stringWithFormat:@"%@/albums", userid];
	
	// Get the values and create the album on facebook
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								   aName, @"name",
								   aDescription, @"description",
								   nil];
	NSLog(@"Create album with params %@", params);
	[self requestWithGraphPath:path
					 andParams:params
				 andHttpMethod:@"POST"
				   andDelegate:self];
}

#pragma mark -
// Get Upload Photo
#pragma mark Upload Photo
- (void)uploadPhoto:(NSString *)albumId imageName:(NSString *)aName imageData:(NSData *)data
{
	NSString *path = [NSString stringWithFormat:@"%@/photos", albumId];
	
	_startImmediately = YES;
	
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								   aName, @"name",
								   aName, @"caption",
								   data, @"source",
								   nil];
	[self requestWithGraphPath:path
					 andParams:params
				 andHttpMethod:@"POST"
				   andDelegate:self];
}


#pragma mark -
// Facebook Methods
#pragma mark Facebook Methods

/**
 * Make a request to Facebook's REST API with the given method name and
 * parameters.  
 * 
 * See http://developers.facebook.com/docs/reference/rest/
 *  
 * 
 * @param methodName
 *             a valid REST server API method.
 * @param parameters
 *            Key-value pairs of parameters to the request. Refer to the
 *            documentation: one of the parameters must be "method". To upload
 *            a file, you should specify the httpMethod to be "POST" and the 
 *            “params” you passed in should contain a value of the type 
 *            (UIImage *) or (NSData *) which contains the content that you 
 *            want to upload
 * @param delegate
 *            Callback interface for notifying the calling application when
 *            the request has received response
 */
- (void)requestWithMethodName:(NSString *)methodName 
                    andParams:(NSMutableDictionary *)params 
                andHttpMethod:(NSString *)httpMethod 
                  andDelegate:(id <FacebookRequestDelegate>)delegate {
	NSString * fullURL = [kRestApiURL stringByAppendingString:methodName];
	[self _openUrl:fullURL params:params httpMethod:httpMethod delegate:delegate];
}

/**
 * Make a request to the Facebook Graph API without any parameters.
 * 
 * See http://developers.facebook.com/docs/api
 * 
 * @param graphPath
 *            Path to resource in the Facebook graph, e.g., to fetch data
 *            about the currently logged authenticated user, provide "me",
 *            which will fetch http://graph.facebook.com/me
 * @param delegate
 *            Callback interface for notifying the calling application when
 *            the request has received response
 */
- (void) requestWithGraphPath:(NSString *)graphPath
				  andDelegate:(id <FacebookRequestDelegate>)delegate {
	
	[self requestWithGraphPath:graphPath 
					 andParams:[NSMutableDictionary dictionary] 
				 andHttpMethod:@"GET" 
				   andDelegate:delegate];
	
}

/**
 * Make a request to the Facebook Graph API with the given string 
 * parameters using an HTTP GET (default method).
 * 
 * See http://developers.facebook.com/docs/api
 *  
 * 
 * @param graphPath
 *            Path to resource in the Facebook graph, e.g., to fetch data
 *            about the currently logged authenticated user, provide "me",
 *            which will fetch http://graph.facebook.com/me
 * @param parameters
 *            key-value string parameters, e.g. the path "search" with
 *            parameters "q" : "facebook" would produce a query for the
 *            following graph resource:
 *            https://graph.facebook.com/search?q=facebook
 * @param delegate
 *            Callback interface for notifying the calling application when
 *            the request has received response
 */
-(void) requestWithGraphPath:(NSString *)graphPath 
                   andParams:(NSMutableDictionary *)params  
                 andDelegate:(id <FacebookRequestDelegate>)delegate {
	
	[self requestWithGraphPath:graphPath 
					 andParams:params 
				 andHttpMethod:@"GET" 
				   andDelegate:delegate];  
}

/**
 * Make a request to the Facebook Graph API with the given
 * HTTP method and string parameters. Note that binary data parameters 
 * (e.g. pictures) are not yet supported by this helper function.
 * 
 * See http://developers.facebook.com/docs/api
 *  
 * 
 * @param graphPath
 *            Path to resource in the Facebook graph, e.g., to fetch data
 *            about the currently logged authenticated user, provide "me",
 *            which will fetch http://graph.facebook.com/me
 * @param parameters
 *            key-value string parameters, e.g. the path "search" with
 *            parameters {"q" : "facebook"} would produce a query for the
 *            following graph resource:
 *            https://graph.facebook.com/search?q=facebook
 *            To upload a file, you should specify the httpMethod to be 
 *            "POST" and the “params” you passed in should contain a value 
 *            of the type (UIImage *) or (NSData *) which contains the 
 *            content that you want to upload
 * @param httpMethod
 *            http verb, e.g. "GET", "POST", "DELETE"
 * @param delegate
 *            Callback interface for notifying the calling application when
 *            the request has received response
 */
-(void)requestWithGraphPath:(NSString *)graphPath 
				  andParams:(NSMutableDictionary *)params 
			  andHttpMethod:(NSString *)httpMethod 
				andDelegate:(id <FacebookRequestDelegate>)delegate {
	NSString * fullURL = [kGraphBaseURL stringByAppendingString:graphPath];
	[self _openUrl:fullURL params:params httpMethod:httpMethod delegate:delegate];
}

/**
 * private helper function for send http request to an url with specified
 * http method @"GET" or @"POST" and specified parameters 
 * 
 * @param url
 *            url to send http request
 * @param params
 *            parameters to append to the url
 * @param httpMethod
 *            http method @"GET" or @"POST"
 * @param delegate
 *            Callback interface for notifying the calling application when
 *            the request has received response
 */
- (void)_openUrl:(NSString *)url 
		  params:(NSMutableDictionary *)params 
	  httpMethod:(NSString *)httpMethod 
		delegate:(id<FacebookRequestDelegate>)delegate
{
	[params setValue:@"json" forKey:@"format"];
	if ([self accessToken]) {
		[params setValue:[self accessToken] forKey:@"access_token"];
	}
	
	NSLog(@"openUrl %@", url);
	//NSLog(@"\tParams %@", params);
	
	[_request release];
	_request = [[FacebookRequest getRequestWithParams:params
										   httpMethod:httpMethod
											 delegate:delegate
										   requestURL:url] retain];
	[_request connect:_startImmediately];
}

- (void)request:(FacebookRequest *)request didLoad:(id)result
{
	NSLog(@"Request url: %@", [request url]);
	
	NSArray *components = [(NSString *)[request url] componentsSeparatedByString:@"/"];
	NSString *method = (NSString *)[components objectAtIndex:([components count] - 1)];
	
	// Get User Information
	if ([@"me" compare:method] == NSOrderedSame) {
		// Check for an error
		NSString *errorMessage = nil;
		if ([(NSDictionary *)result objectForKey:@"error"]) {
			NSDictionary *error = [(NSDictionary *)result objectForKey:@"error"];
			NSLog(@"Authentication error %@", error);
			errorMessage = [error objectForKey:@"message"];
		}
		
		[_delegate finishGetUserInformation:(NSString *)[(NSDictionary *)result objectForKey:@"id"]
								   username:(NSString *)[(NSDictionary *)result objectForKey:@"name"]
									  error:errorMessage];
		
	} else if ([@"albums" compare:method] == NSOrderedSame) {
		// Check for an error
		NSString *errorMessage = nil;
		if ([(NSDictionary *)result objectForKey:@"error"]) {
			NSDictionary *error = [(NSDictionary *)result objectForKey:@"error"];
			NSLog(@"Request error %@", error);
			errorMessage = [error objectForKey:@"message"];
		}
		
		if ([[request httpMethod] compare:@"GET"] == NSOrderedSame) {
			NSMutableArray *albumList = [[[NSMutableArray alloc] init] autorelease];
			
			// Get the list of albums
			NSArray *albums = (NSArray *)[(NSDictionary *)result objectForKey:@"data"];
			
			for (NSInteger i = 0; i < [albums count]; i++) {
				NSDictionary *album = (NSDictionary *)[albums objectAtIndex:i];
				FacebookAlbum *albumInfo = [[[FacebookAlbum alloc] init] autorelease];
				
				[albumInfo setAlbumName:[album objectForKey:@"name"]];
				[albumInfo setAlbumID:[album objectForKey:@"id"]];
				[albumInfo setLink:[album objectForKey:@"link"]];
				
				if ([@"Profile Pictures" compare:[albumInfo albumName]] == NSOrderedSame) {
					continue;
				} else {
					//[albumListController addObject:albumInfo];
					[albumList addObject:albumInfo];
				}
			}
			
			[_delegate finishFetchAllAlbums:albumList error:errorMessage];
			
			NSLog(@"Finished getting albums");
			
		} else {
			NSString *albumId = (NSString *)[(NSDictionary *)result objectForKey:@"id"];
			
			NSLog(@"Finished POSTing album with albumId %@", albumId);
			
			[_delegate finishCreateNewAlbumRequest:albumId error:errorMessage];
		}
	} else if ([@"photos" compare:method] == NSOrderedSame) {
		NSLog(@"photos result %@", result);
		if ([[request httpMethod] compare:@"GET"] == NSOrderedSame) {
			NSLog(@"photos GET finished!");
		} else {
			NSLog(@"photos POST finished!");
			[_delegate _finishCurrentUploadWithSuccess:YES];
		}
	} else {
		// Do something
	}
}

@end
