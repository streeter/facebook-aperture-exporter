//
//	FacebookExporter.m
//	FacebookExporter
//
//	Created by Chris Streeter on 11/4/10.
//	Copyright chrisstreeter.com 2010. All rights reserved.
//

#import "FacebookExporter.h"

@interface FacebookExporter(PrivateMethods)

- (void)getUserInformation;

- (void)fetchAllAlbums;
- (void)_populateMenuForAlbumList;

- (void)_adjustTableInterface;
- (void)_authenticate;
- (void)_handleAuthenticationError:(NSString *)error;
- (void)authenticateWithSavedData;

// runs through all the images in the given folder
// (using pathForImages) and sets them as the new
// array for imageList. Sets all data except thumbnail

- (void)reloadImageList;

// Runs through all the images given by _exportManager
// and sets the thumbnails in the imaglist created
// by reloadImageList. intended to be run in the
// background, so sets up an NSAutoreleasePool.
- (void)threadLoadThumbnails;

- (NSURL *)generateURL:(NSString *)baseURL params:(NSDictionary *)params;
- (NSString *)extractParameter:(NSString *)param fromURL:(NSString *)url;


- (void)_displayAuthenticationSheet:(NSMutableDictionary *)params;
- (void)_hideAuthenticationSheet;
- (void)_displayConnectionSheet:(NSString *)aMessage;
- (void)_hideConnectionSheet;

@end


#pragma mark -
// Static Variables
#pragma mark Static Variables

static NSString *kUsernameTitleFormat = @"Logged in as %@";

static NSString *kUserDefaultAccessToken = @"ApertureFacebookPluginDefaultAccessToken";
static NSString *kUserDefaultAuthenticated = @"ApertureFacebookPluginDefaultAuthenticated";


static NSString *kOAuthURL = @"https://graph.facebook.com/oauth/authorize";
static NSString *kRedirectURL = @"http://www.facebook.com/connect/login_success.html";

static NSString *kSDKVersion = @"ios";
static NSString *kFBAccessToken = @"access_token=";
static NSString *kFBExpiresIn = @"expires_in=";
static NSString *kFBErrorReason = @"error_reason";
static NSString *kApplicationID = @"171090106251253";


#pragma mark -
// Implementation
#pragma mark Implementation

@implementation FacebookExporter

@synthesize	selectedAlbum = _selectedAlbum,
			suggestedAlbumName = _suggestedAlbumName,
			requestController = _requestController,
			userID = _userID,
			loadingImages = _loadingImages,
			authenticated = _authenticated,
			shouldCancelUploadActivity = _shouldCancelUploadActivity;

//---------------------------------------------------------
// initWithAPIManager:
//
// This method is called when a plug-in is first loaded, and
// is a good point to conduct any checks for anti-piracy or
// system compatibility. This is also your only chance to
// obtain a reference to Aperture's export manager. If you
// do not obtain a valid reference, you should return nil.
// Returning nil means that a plug-in chooses not to be accessible.
//---------------------------------------------------------

 - (id)initWithAPIManager:(id<PROAPIAccessing>)apiManager
{
	if (self = [super init])
	{
		_apiManager	= apiManager;
		_exportManager = [[_apiManager apiForProtocol:@protocol(ApertureExportManager)] retain];
		if (!_exportManager)
			return nil;
		
		_progressLock = [[NSLock alloc] init];
		
		// Create our temporary directory
		_tempDirectoryPath = [[NSString stringWithFormat:@"%@/FacebookExporter/", NSTemporaryDirectory()] retain];
		
		// If it doesn't exist, create it
		NSFileManager *fileManager = [NSFileManager defaultManager];
		BOOL isDirectory;
		if (![fileManager fileExistsAtPath:_tempDirectoryPath isDirectory:&isDirectory])
		{
			[fileManager createDirectoryAtPath:_tempDirectoryPath attributes:nil];
		}
		else if (isDirectory) // If a folder already exists, empty it.
		{
			NSArray *contents = [fileManager directoryContentsAtPath:_tempDirectoryPath];
			NSInteger i;
			for (i = 0; i < [contents count]; i++)
			{
				NSString *tempFilePath = [NSString stringWithFormat:@"%@%@", _tempDirectoryPath, [contents objectAtIndex:i]];
				[fileManager removeFileAtPath:tempFilePath handler:nil];
			}
		}
		else // Delete the old file and create a new directory
		{
			[fileManager removeFileAtPath:_tempDirectoryPath handler:nil];
			[fileManager createDirectoryAtPath:_tempDirectoryPath attributes:nil];
		}
		
		_albumList = [[NSMutableArray alloc] init];
		
		_tableColumnWidth = 129.0;
		
		// Cleanup Aperture Propertylist from old values 
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults]; 
		if ([defaults stringForKey:kUserDefaultAccessToken]) {
			[defaults removeObjectForKey:kUserDefaultAccessToken];
			[PlugInDefaults setUserAuthenticated:YES];
		}
		if ([defaults boolForKey:kUserDefaultAuthenticated]) {
			[defaults removeObjectForKey:kUserDefaultAuthenticated];
			[PlugInDefaults setUserAuthenticated:YES];
		}
		[defaults synchronize];
		
		[self setAuthenticated:NO];
		[self setShouldCancelUploadActivity:NO];
		[self setSelectedAlbum:nil];
		[self setUserID:nil];
		[self setUsername:nil];
		
		_requestController = [[FacebookRequestController alloc] init];
		[[self requestController] setDelegate:self];
	}
	
	return self;
}

- (void)dealloc
{
	// Release the top-level objects from the nib.
	[_topLevelNibObjects makeObjectsPerformSelector:@selector(release)];
	[_topLevelNibObjects release];
	
	// Clean up the temporary files
	[[NSFileManager defaultManager] removeFileAtPath:_tempDirectoryPath handler:nil];
	[_tempDirectoryPath release];
	
	// TODO - dealloc all the FacebookAlbums inside _albumList
	
	[_albumList release];
	
	[_requestController release];
	
	[_progressLock release];
	[_exportManager release];
	
	[super dealloc];
}


#pragma mark -
// UI Methods
#pragma mark UI Methods

- (NSView *)settingsView
{
	if (nil == settingsView)
	{
		// Load the nib using NSNib, and retain the array of top-level objects so we can release
		// them properly in dealloc
		NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
		NSNib *myNib = [[NSNib alloc] initWithNibNamed:@"FacebookExporter" bundle:myBundle];
		if ([myNib instantiateNibWithOwner:self topLevelObjects:&_topLevelNibObjects])
		{
			[_topLevelNibObjects retain];
		}
		[myNib release];
	}
	
	[openFacebookOnFinishButton setState:[PlugInDefaults isOpenFacebookOnFinish]];
	
	NSString *version = [[[NSBundle bundleForClass:[self class]] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
	NSLog(@"Plugin version: %@", version);
	NSString *versionString = [NSString stringWithFormat:@"Facebook Exporter Version %@", version];
	[versionTextField setTitle:versionString];
	
	NSString *pluginBundleID = [[[NSBundle bundleForClass: [self class]] infoDictionary] objectForKey:@"CFBundleIdentifier"];
	NSLog(@"Plugin Bundle ID: %@", pluginBundleID);
	
	_updateNow = NO;
	
	if ([PlugInUpdateCheck isUpdateAvailable]) {
		SUUpdater *updater = [SUUpdater updaterForBundle:[NSBundle bundleWithIdentifier:pluginBundleID]];
		[updater setDelegate:self];
		[updater setAutomaticallyChecksForUpdates:YES];
		[updater resetUpdateCycle];
		[updater checkForUpdatesInBackground];

		NSLog(@"Plugin feed URL: %@", [updater feedURL]);

		NSString *alertMessage = [self _localizedStringForKey:@"updateAvailable" defaultValue:@"A new version of Facebook Exporter is available! Would you like to update it now?"];
		NSString *informativeText = @"";
		NSAlert *alert = [NSAlert alertWithMessageText:alertMessage 
										 defaultButton:[self _localizedStringForKey:@"updateNow" defaultValue:@"Update now"] 
									   alternateButton:[self _localizedStringForKey:@"updateLater" defaultValue:@"Update later"] 
										   otherButton:nil 
							 informativeTextWithFormat:informativeText];
		[alert setAlertStyle:NSInformationalAlertStyle];
		
		_updateNow = ([alert runModal] == NSAlertDefaultReturn);
	}
	
	return settingsView;
}

- (NSView *)firstView
{
	return firstView;
}

- (NSView *)lastView
{
	return lastView;
}

- (void)willBeActivated
{
	NSLog(@"willBeActivacted for %d images", [_exportManager imageCount]);
	[self setLoadingImages:YES];
	[self _adjustTableInterface];
	
	// We have to load the metadata from the main thread because otherwise Aperture only give us metadata for 
	// images whose metadata has been recently viewed in Aperture. We first load the image metadata minus
	// thumbnails since loading thumbnails is slow and we want the user to be able to start working asap.
	// We then add the thumbnails in a background thread.
	
	// First load the list with all metadata except thumbnails from the main thread:
	[self reloadImageList];
	
	// Then add the Thumbnails in a separate thread
	[NSThread detachNewThreadSelector:@selector(threadLoadThumbnails)
							 toTarget:self
						   withObject:nil];
	
	[self performSelectorOnMainThread:@selector(authenticateWithSavedData)
						   withObject:nil
						waitUntilDone:NO];
}

- (void)willBeDeactivated
{
	// Nothing to do here
	NSLog(@"willBeDeactivacted");
}


#pragma mark -
// Sheet Display Methods
#pragma mark Sheet Display Methods
- (void)_displayAuthenticationSheet:(NSMutableDictionary *)params
{
	NSURL *url = [self generateURL:kOAuthURL params:params];
	[[embeddedWebView mainFrame] loadRequest:[NSURLRequest requestWithURL:url]];
	
	if (_authenticated) 
		[self _displayConnectionSheet:@"Attempting to login...."];
	else {
		[NSApp beginSheet:authenticationWindow
		   modalForWindow:[_exportManager window]
			modalDelegate:self
		   didEndSelector:nil
			  contextInfo:nil];
	}
}

- (void)_hideAuthenticationSheet
{
	if ([authenticationWindow isVisible]) {
		[NSApp endSheet:authenticationWindow];
		[authenticationWindow orderOut:self];
	}
}
- (void)_displayConnectionSheet:(NSString *)aMessage
{
	// Put up a progress sheet and set the appropriate values
	[connectionProgressIndicator startAnimation:self];
	[connectionStatusField setStringValue:[self _localizedStringForKey:@"connectionString"
														  defaultValue:aMessage]];
	
	
	if (![connectionWindow isVisible]) {
		[NSApp beginSheet:connectionWindow
		   modalForWindow:[_exportManager window]
			modalDelegate:self
		   didEndSelector:nil
			  contextInfo:nil];
	}
}
- (void)_hideConnectionSheet
{
	if ([connectionWindow isVisible]) {
		[NSApp endSheet:connectionWindow];
		[connectionWindow orderOut:self];
	}
}

#pragma mark -
// TableView Delegate Methods
#pragma mark TableView Delegate Methods

/*
- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
	NSLog(@"tableView heightOfRow is called");
	NSSize imgSize = [[[[self imageList] objectAtIndex:row] defaultThumbnail] size];
	
	// If img gets resized, let's get the scaled valued.
	if (imgSize.width == _tableColumnWidth || imgSize.width == (CGFloat)0.0) {
		// No scale needed.
		return imgSize.height;
	}
	NSLog(@"\tHeight is %f", (_tableColumnWidth * imgSize.height / imgSize.width));
	return _tableColumnWidth * imgSize.height / imgSize.width;
}
 */

- (void)_adjustTableInterface
{
	NSSize size = [imageTableView intercellSpacing];
	
	size.height += (CGFloat)5.0;
	size.width += (CGFloat)10.0;
	
	[imageTableView setIntercellSpacing:size];
	_tableColumnWidth = [(NSTableColumn *)[[imageTableView tableColumns] objectAtIndex:0] width];
}

- (void)tableViewSelectionIsChanging:(NSNotification *)aNotification
{
	NSLog(@"Selected picture = %@", [[[self imageList] objectAtIndex:[imageTableView selectedRow]] title]);
}

#pragma mark -
// WebView Delegate Methods
#pragma mark WebView Delegate Methods

- (NSURLRequest *)webView:(WebView *)sender
				 resource:(id)identifier
		  willSendRequest:(NSURLRequest *)request
		 redirectResponse:(NSURLResponse *)redirectResponse
		   fromDataSource:(WebDataSource *)dataSource
{
	return request;
}

- (void)webView:(WebView *)sender didCommitLoadForFrame:(WebFrame *)frame
{
	NSString *url = [sender mainFrameURL];
	
	NSComparisonResult res = [url compare:kRedirectURL options:NSCaseInsensitiveSearch range:NSMakeRange(0, [kRedirectURL length])];
    if (res == NSOrderedSame)
    {
        NSString *accessToken = [self extractParameter:kFBAccessToken fromURL:url];
        NSString *tokenExpires = [self extractParameter:kFBExpiresIn fromURL:url];
        //NSString *errorReason = [self extractParameter:kFBErrorReason fromURL:url];
		
		NSLog(@"accessToken: %@", accessToken);
		NSLog(@"tokenExpires: %@", tokenExpires);
		
		[self setAccessToken:accessToken];
		
		// TODO - handle the expires correctly.
		
		if (!accessToken) 
			[self cancelAuthenticationWindow];
		else 
			[self connectToFacebook:self];
    }
	else {
		NSString *err = [self extractParameter:kFBErrorReason fromURL:url];

		if (err) {
			[self setAuthenticated:NO];
			[self _hideConnectionSheet];
			
			[NSApp beginSheet:authenticationWindow
			   modalForWindow:[_exportManager window]
				modalDelegate:self
			   didEndSelector:nil
				  contextInfo:nil];
		}
	}

}


#pragma mark
// Aperture UI Controls
#pragma mark Aperture UI Controls

- (BOOL)allowsOnlyPlugInPresets
{
	return NO;
}

- (BOOL)allowsMasterExport
{
	return NO;
}

- (BOOL)allowsVersionExport
{
	return YES;
}

- (BOOL)wantsFileNamingControls
{
	return NO;
}

- (void)exportManagerExportTypeDidChange
{
	// TODO - figure out if this is correct
	
	// Nothing to do here - this plug-in doesn't show the user any information about the selected images,
	// so there's no need to see if the count or properties changed here.
}


#pragma mark -
// Save Path Methods
#pragma mark Save/Path Methods

- (BOOL)wantsDestinationPathPrompt
{
	// We have already destermined a temporary destination for our images and we delete them as soon as
	// we're done with them, so the user should not select a location.
	return NO;
}

- (NSString *)destinationPath
{
	return _tempDirectoryPath;
}

- (NSString *)defaultDirectory
{
	// Since this plug-in is not asking Aperture to present an open/save dialog,
	// this method should never be called.
	return nil;
}


#pragma mark -
// Export Process Methods
#pragma mark Export Process Methods

- (void)exportManagerShouldBeginExport
{
	// Before telling Aperture to begin generating image data,
	// test the connection using the user-entered values
	
	if (_authenticated && [self selectedAlbum]) {
		NSLog(@"exportManagerShouldBeginExport to album %@", [[self selectedAlbum] albumName]);
		[_exportManager shouldBeginExport];
	} else {
		NSString *errorMessage = @"Cannot export images";
		NSString *informativeText = @"";
		if (!_authenticated) {
			informativeText = @"You must authenticate before uploading photos.";
		} else {
			// No album selected
			informativeText = @"You must select an album before uploading.";
		}
		NSAlert *alert = [NSAlert alertWithMessageText:errorMessage
										 defaultButton:[self _localizedStringForKey:@"OK"
																	   defaultValue:@"OK"]
									   alternateButton:nil
										   otherButton:nil
							 informativeTextWithFormat:informativeText];
		[alert setAlertStyle:NSCriticalAlertStyle];
		[alert runModal];
	}
}

- (void)exportManagerWillBeginExportToPath:(NSString *)path
{
	// Nothing to do here. We could test the path argument and confirm that
	// it's the same path we passed, but that's not really necessary.
	
	NSLog(@"exportManagerWillBeginExportToPath: %@", path);
	
	// Set up our progress to count exported images
	[self lockProgress];
	exportProgress.indeterminateProgress = YES;
	exportProgress.currentValue = 0;
	exportProgress.totalValue = [[self imageList] count];
	[exportProgress.message autorelease];
	exportProgress.message = [[self _localizedStringForKey:@"exportingImages" defaultValue:@"Step 1 of 2: Exporting images..."] retain];
	[self unlockProgress];
}

- (BOOL)exportManagerShouldExportImageAtIndex:(unsigned)index
{
	// This plug-in doesn't exclude any images for any reason, so it always returns YES here.
	NSLog(@"exportManagerShouldExportImageAtIndex: %d", index);
	return YES;
}

- (void)exportManagerWillExportImageAtIndex:(unsigned)index
{
	// Nothing to do here - this is just a confirmation that we returned YES above. We could
	// check to make sure we get confirmation messages for every image.
	NSLog(@"exportManagerWillExportImageAtIndex: %d", index);
}

- (BOOL)exportManagerShouldWriteImageData:(NSData *)imageData toRelativePath:(NSString *)path forImageAtIndex:(unsigned)index
{
	NSLog(@"exportManagerShouldWriteImageData path: %@", path);
	
	// Add to the total bytes we have to upload so we can properly indicate progress.
	NSLog(@"Total number of bytes is %d [%x] plus %d [%x]", totalBytes, totalBytes, [imageData length], [imageData length]);
	totalBytes += [imageData length];
	
	// Set up our progress to count exported images
	
	NSString *exportString = [NSString stringWithFormat:@"Step 1 of 2: Exporting image %d of %d.", index, [[self imageList] count]];
	
	[self lockProgress];
	exportProgress.currentValue = index;
	exportProgress.indeterminateProgress = NO;
	[exportProgress.message autorelease];
	exportProgress.message = [[self _localizedStringForKey:@"exportingImage" defaultValue:exportString] retain];
	[self unlockProgress];
	
	return YES;	
}

- (void)exportManagerDidWriteImageDataToRelativePath:(NSString *)relativePath forImageAtIndex:(unsigned)index
{
	NSLog(@"exportManagerDidWriteImageDataToRelativePath");
	
	if (!_exportedImagePaths)
	{
		_exportedImagePaths = [[NSMutableArray alloc] initWithCapacity:[_exportManager imageCount]];
	}
	
	// Save the paths of all the images that Aperture has exported
	NSString *imagePath = [NSString stringWithFormat:@"%@%@", _tempDirectoryPath, relativePath];
	FacebookPicture *picture = [[self imageList] objectAtIndex:index];
	[picture setPath:imagePath];
	[_exportedImagePaths addObject:picture];
	
	// Set up our progress to count exported images
	NSString *exportString = [NSString stringWithFormat:@"Step 1 of 2: Exported image %d of %d.", index, [[self imageList] count]];
	
	// Increment the current progress
	[self lockProgress];
	[exportProgress.message autorelease];
	exportProgress.message = [[self _localizedStringForKey:@"exportedImage" defaultValue:exportString] retain];
	exportProgress.currentValue++;
	[self unlockProgress];
}

- (void)exportManagerDidFinishExport
{
	NSLog(@"exportManagerDidFinishExport");
	
	// You must call [_exportManager shouldFinishExport] before Aperture will put away the progress window and complete the export.
	// NOTE: You should assume that your plug-in will be deallocated immediately following this call. Be sure you have cleaned up
	// any callbacks or running threads before calling.
	
	// Now that Aperture has written all the images to disk for us, we will begin uploading them one-by-one. 
	// There are alternative strategies for uploading - sending the data as soon as Aperture gives it to us, or running several
	// simultaneous uploads. But the solution that lets Aperture write them all to disk first, and then uploads them one-by-one is 
	// the simplest for this example.
	
	
	[self _incrementUploadProgress:0];
	
	[self _uploadNextImage];
}

- (void)exportManagerShouldCancelExport
{
	// You must call [_exportManager shouldCancelExport] here or elsewhere before Aperture will cancel the export process
	// NOTE: You should assume that your plug-in will be deallocated immediately following this call. Be sure you have cleaned up
	// any callbacks or running threads before calling.
	
	// Set our shouldCancel flag so any in-progress exports will know to exit
	[self setShouldCancelUploadActivity:YES];
	
	// Tell Aperture to go ahead and cancel - this will immediately deallocate us.
	// Since we may have Upload callbacks still open, we have retained ourself and do not release until
	// all the callbacks have finished. An alternate solution is to not call -shouldCancelExport until
	// all the callbacks have returned.
	[_exportManager shouldCancelExport];
}


#pragma mark -
// Progress Methods
#pragma mark Progress Methods

- (ApertureExportProgress *)progress
{
	return &exportProgress;
}

- (void)lockProgress
{
	
	if (!_progressLock)
		_progressLock = [[NSLock alloc] init];
		
	[_progressLock lock];
}

- (void)unlockProgress
{
	[_progressLock unlock];
}

#pragma mark -
// Connection Progress Methods
#pragma mark Connection Progress Methods

- (IBAction)cancelConnectionWindow:(id)sender
{
	[self setShouldCancelUploadActivity:YES];
	
	[self _hideConnectionSheet];
	
	[self exportManagerShouldCancelExport];
}

#pragma mark -
// Authentication Methods
#pragma mark Authentication Methods

- (void)authenticateWithSavedData
{
	[self setAuthenticated:[PlugInDefaults isUserAuthenticated]];
	
	if (_updateNow)
		[self cancelAuthenticationWindow];
	else
		[self _authenticate];
}

- (void)_authenticate
{
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								   kApplicationID, @"client_id",
								   @"user_agent", @"type", 
								   kRedirectURL, @"redirect_uri",
								   kSDKVersion, @"sdk",
								   @"publish_stream,user_photos,offline_access", @"scope",
								   nil];
	
	[self _displayAuthenticationSheet:params];
}

- (void)_handleAuthenticationError:(NSString *)error
{
	NSString *errorMessage = [NSString stringWithFormat:@"There was an error authenticating with Facebook. Please try again.\n\n%@", error];
	[connectionProgressIndicator startAnimation:self];
	[connectionStatusField setStringValue:[self _localizedStringForKey:@"connectionString"
														  defaultValue:errorMessage]];
}

- (void)cancelAuthenticationWindow
{
	NSLog(@"%@",@"cancelAuthentication");
	
	[self _hideAuthenticationSheet];
	
	[self exportManagerShouldCancelExport];
}

- (IBAction)connectToFacebook:(id)sender
{
	[self _hideAuthenticationSheet];
	
	[PlugInDefaults setUserAuthenticated:_authenticated];
	
	[self getUserInformation];
}

- (void)getUserInformation
{
	[self _displayConnectionSheet:@"Getting logged in user information..."];
	
	[[self requestController] getUserInformation:@"me"];
}

- (void)finishGetUserInformation:(NSString *)userid username:(NSString *)username error:(NSString *)message
{
	// TODO - handle error
	
	if (userid) {
		[self setUserID:userid];
	}
	if (username) {
		[self setUsername:username];
	}
	
	if (!message) {
		[self fetchAllAlbums];
	}
}

- (void)_endAuthorizationTestWithSuccess:(BOOL)success albumListing:(id *)remoteAlbumListingInfo
{
	// Put away the sheet
	[self _hideConnectionSheet];
	
	if (success)
	{
		// The user's values were valid and we are connected to Facebook.
		
		if (![self shouldCancelUploadActivity])
		{
			// Set our progress before beginning export activity
			[self lockProgress];
			exportProgress.totalValue = 1;
			exportProgress.currentValue = 1;
			exportProgress.indeterminateProgress = NO;
			exportProgress.message = [[self _localizedStringForKey:@"preparingImages" defaultValue:@"Step 1 of 2: Preparing Images..."] retain];
			[self unlockProgress];
			
			// Initialize variables for progress indicators
			totalBytes = 0;
			
			// The test was successful, we have set the progress correctly, and are ready for Aperture to begin generating image data.
			[_exportManager shouldBeginExport];
		}
	}
	else
	{		
		if (![self shouldCancelUploadActivity])
		{
			// If we're here, then there was an error. Alert the user
			NSString *errorMessage = [self _localizedStringForKey:@"couldNotVerifyAuthorization" defaultValue:@"Could Not Verify Authorization to Facebook."];
			NSString *informativeText = @"";
			NSAlert *alert = [NSAlert alertWithMessageText:errorMessage defaultButton:[self _localizedStringForKey:@"OK" defaultValue:@"OK"] alternateButton:nil otherButton:nil informativeTextWithFormat:informativeText];
			[alert setAlertStyle:NSCriticalAlertStyle];
			[alert runModal];
		}
		
	}
}

- (IBAction)logOut:(id)sender
{	
	
	[[self requestController] logOut];
	
	[self setAccessToken:nil];
	[self setUsername:nil];

	[PlugInDefaults removeUserAuthenticated];
	
	NSHTTPCookieStorage *cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
	NSArray *facebookCookies = [cookies cookiesForURL:[NSURL URLWithString:@"http://login.facebook.com"]];
	
	for (NSHTTPCookie *cookie in facebookCookies) {
		[cookies deleteCookie:cookie];
	}
	
	[self _authenticate];
}


#pragma mark -
// Preference Actions
#pragma mark Preference	Actions
- (IBAction)openPreferencesWindow:(id)sender
{
	// TODO
	NSLog(@"Should open preferences sheet");
}

- (IBAction)changeStateOpenOnFinish:(id)sender
{
	[PlugInDefaults setOpenFacebookOnFinish:[openFacebookOnFinishButton state]];
}

#pragma mark -
// Album Actions
#pragma mark Album Actions

- (void)fetchAllAlbums
{
	[self _displayConnectionSheet:@"Fetching list of albums..."];
	
	[[self requestController] getAlbumList:@"me"];
}

- (void)finishFetchAllAlbums:(NSMutableArray *)albumList error:(NSString *)message
{
	[self setAlbumList:albumList];
	
	[self _populateMenuForAlbumList];
	
	[self _hideConnectionSheet];
}

- (void)openNewAlbumWindow:(id)sender
{
	// TODO
	NSLog(@"Should open new album window");
	
	[newAlbumName setStringValue:@""];
	[newAlbumDescription setStringValue:@""];
	
	if (![newAlbumWindow isVisible]) {
		[NSApp beginSheet:newAlbumWindow
		   modalForWindow:[_exportManager window]
			modalDelegate:self
		   didEndSelector:nil
			  contextInfo:nil];
	}
}


- (IBAction)finishCreateNewAlbumWindow:(id)sender
{
	NSLog(@"Finish create new album window");
	
	if (![newAlbumName stringValue]) {
		NSLog(@"blank new album name");
	}
	
	if ([newAlbumWindow isVisible]) {
		[NSApp endSheet:newAlbumWindow];
		[newAlbumWindow orderOut:self];
	}
	
	[self _displayConnectionSheet:@"Creating new album..."];
	
	[[self requestController] createAlbum:@"me" albumName:[newAlbumName stringValue] albumDescription:[newAlbumDescription stringValue]];
}

- (void)finishCreateNewAlbumRequest:(NSString *)albumId error:(NSString *)message
{
	NSLog(@"finisheCreateNewAlbumRequest called");
	
	FacebookAlbum *albumInfo = [[FacebookAlbum alloc] init];
	
	[albumInfo setAlbumName:[newAlbumName stringValue]];
	[albumInfo setAlbumID:albumId];
	
	[[self albumList] insertObject:albumInfo atIndex:0];
	
	[self setSelectedAlbum:albumInfo];
	[self _populateMenuForAlbumList];
	
	// Select this item
	[albumListView selectItemAtIndex:3];
	
	[self _hideConnectionSheet];
}

- (IBAction)cancelCreateNewAlbumWindow:(id)sender
{
	NSLog(@"Cancel create new album");
	
	if ([newAlbumWindow isVisible]) {
		[NSApp endSheet:newAlbumWindow];
		[newAlbumWindow orderOut:self];
	}
}

- (void)updateSelectedAlbum:(id)sender
{
	FacebookAlbum *album = [(NSMenuItem *)sender representedObject];
	NSLog(@"Selected album is %@", [album albumName]);
	
	[self setSelectedAlbum:album];
}

- (void)_populateMenuForAlbumList
{
	NSMenu *menu;
	NSMenuItem *item;
	FacebookAlbum *album;
	
	menu = [[[NSMenu alloc] initWithTitle:@"Select Album"] autorelease];
	[menu addItemWithTitle:@"Select Album"
					action:nil
			 keyEquivalent:@""];
	[[menu addItemWithTitle:@"Create new album"
					 action:@selector(openNewAlbumWindow:)
			  keyEquivalent:@""] setTarget:self];
	[menu addItem:[NSMenuItem separatorItem]];
	
	[albumListView setMenu:menu];
	
	// Populate the menu with all the albums for the user
	for (NSInteger i = 0; i < [[self albumList] count]; i++) {
		album = [[self albumList] objectAtIndex:i];
		
		item = [menu addItemWithTitle:[album albumName]
							   action:@selector(updateSelectedAlbum:)
						keyEquivalent:@""];
		[item setTarget:self];
		[item setRepresentedObject:album];
	}
}


#pragma mark -
// Accessors
#pragma mark Accessors

- (NSString *)accessToken
{
	return _accessToken;
}

- (void)setAccessToken:(NSString *)aValue
{
	if (_accessToken != aValue) {
		[_accessToken release];
		_accessToken = [aValue copy];
	}
	
	[[self requestController] setAccessToken:aValue];
	
	if (aValue == nil) {
		[self setAuthenticated:NO];
	} else {
		[self setAuthenticated:YES];
	}
}

- (NSString *)username
{
	return _username;
}

- (void)setUsername:(NSString *)aValue
{
	_username = aValue;
	
	[[loggedInAsTextField cell] setTitle:
	 [NSString stringWithFormat:kUsernameTitleFormat, _username]];
}

- (NSMutableArray *)imageList
{
	return _imageList;
}

- (void)setImageList:(NSArray *)aValue
{
	NSMutableArray *oldImageList = _imageList;
	_imageList = [aValue mutableCopy];
	[oldImageList release];
	
	//[self setLoadingImages:NO];
}

- (NSMutableArray *)albumList
{
	return _albumList;
}

- (void)setAlbumList:(NSMutableArray *)aValue
{
	NSMutableArray *oldAlbumList = _albumList;
	_albumList = [aValue mutableCopy];
	[oldAlbumList release];
}

-(void)setDoneLoadingThumbnails:(id)obj
{
	[self setLoadingImages: NO];
}

- (void)setThumbnail:(NSImage *)image forImageatIndex:(NSInteger)index
{
	[[_imageList objectAtIndex:index] setDefaultThumbnail:image];
	//[imageTableView reloadData];
}

- (void)setThumbnailFromDict:(NSDictionary *)dict
{
	NSArray *allKeys = [dict allKeys];
	
	NSEnumerator *e = [allKeys objectEnumerator];
	NSNumber *onekey = [e nextObject];
	
	while (onekey) {
		NSImage *thumb = [dict objectForKey:onekey];
		[self setThumbnail:thumb forImageatIndex:[onekey intValue]];
		onekey = [e nextObject];
	}
}

#pragma mark -
// Sparkle Delegate Methods
#pragma mark Sparkle Delegate Methods
- (void)updater:(SUUpdater *)updater didFinishLoadingAppcast:(SUAppcast *)appcast
{
	NSLog(@"updater:didFinishLoadingAppcast:%@", appcast);
}

- (void)updater:(SUUpdater *)updater didFindValidUpdate:(SUAppcastItem *)update
{
	NSLog(@"updater:didFindValidUpdate:%@", update);
}

- (void)updaterDidNotFindUpdate:(SUUpdater *)update
{
	NSLog(@"updaterDidNotFindUpdate");
}

- (NSString *)pathToRelaunchForUpdater:(SUUpdater *)update
{
	NSLog(@"pathToRelaunchForUpdater:  %@", [[NSBundle mainBundle] bundlePath]);
	return [[NSBundle mainBundle] bundlePath];
}


#pragma mark -
// Private Methods
#pragma mark Private Methods

- (NSString *)_localizedStringForKey:(NSString *)key defaultValue:(NSString *)value
{
	NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
	NSString *localizedString = [myBundle localizedStringForKey:key value:value table:@"Localizable"];
	
	return localizedString;
}


- (void)_finishCurrentUploadWithSuccess:(BOOL)success
{
	// If successful, delete the current image from our temp directory, and upload the next image
	if (success)
	{
		// Delete the last uploaded file
		NSFileManager *fileManager = [NSFileManager defaultManager];
		FacebookPicture *picture = [_exportedImagePaths objectAtIndex:0];
		NSString *imagePath = [picture path];
		[fileManager removeFileAtPath:imagePath handler:nil];
		[_exportedImagePaths removeObjectAtIndex:0];
		
		[self _incrementUploadProgress:[[picture data] length]];
		
		[picture release];
		
		// Upload the next file
		[self _uploadNextImage];
	}
	else
	{
		if (![self shouldCancelUploadActivity])
		{
			// If we're here, then there was an error. Alert the user
			NSString *errorMessage = [NSString stringWithFormat:[self _localizedStringForKey:@"uploadErrorFormat" defaultValue:@"There was an error uploading %@."], [[_exportedImagePaths objectAtIndex:0] lastPathComponent]];
			NSString *informativeText = @"";
			NSAlert *alert = [NSAlert alertWithMessageText:errorMessage defaultButton:[self _localizedStringForKey:@"OK" defaultValue:@"OK"] alternateButton:nil otherButton:nil informativeTextWithFormat:informativeText];
			[alert setAlertStyle:NSCriticalAlertStyle];
			[alert runModal];
		}
	}
}

- (void)_uploadNextImage
{
	NSLog(@"_uploadNextImage with %d images left", [_exportedImagePaths count]);
	
	NSMenuItem *menuItem = [albumListView selectedItem];
	FacebookAlbum *albumInfo = (FacebookAlbum *)[menuItem representedObject];
	
	if (!_exportedImagePaths || ([_exportedImagePaths count] == 0)) {
		// There are no more images to upload. We're done.
		if ([openFacebookOnFinishButton state])
			[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[albumInfo link]]];
		[_exportManager shouldFinishExport];
	} else if ([self shouldCancelUploadActivity]) {
		[_exportManager shouldCancelExport];
	} else {
		
		// Read in our image data
		FacebookPicture *picture = [_exportedImagePaths objectAtIndex:0];
		NSString *nextImagePath = [picture path];
		NSLog(@"Uploading %@ to Facebook", [picture	title]);
		NSLog(@"nextImagePath %@", nextImagePath);
		
		NSData *imageData = [[NSData alloc] initWithContentsOfFile:nextImagePath];
		if (!imageData || ([imageData length] == 0))
		{
			// Exit when there's an error like this
			NSString *errorMessage = [NSString stringWithFormat:[self _localizedStringForKey:@"fileReadErrorFormat" defaultValue:@"There was an error reading %@."], [[_exportedImagePaths objectAtIndex:0] lastPathComponent]];
			NSString *informativeText = @"";
			NSAlert *alert = [NSAlert alertWithMessageText:errorMessage defaultButton:[self _localizedStringForKey:@"OK" defaultValue:@"OK"] alternateButton:nil otherButton:nil informativeTextWithFormat:informativeText];
			[alert setAlertStyle:NSCriticalAlertStyle];
			[alert runModal];
			
			[_exportManager shouldCancelExport];
			return;
		}
		
		// Schedule the upload to start
		[[self requestController] uploadPhoto:[albumInfo albumID]
									imageName:[picture title]
									imageData:imageData];
		
	}
}

- (void)_incrementUploadProgress:(SInt32)bytesWritten
{
	NSString *exportString = [NSString stringWithFormat:@"Step 2 of 2: Uploading image %d of %d.",
							  ([[self imageList] count] - [_exportedImagePaths count]),
							  [[self imageList] count]];
	
	[self lockProgress];
	exportProgress.indeterminateProgress = NO;
	[exportProgress.message autorelease];
	exportProgress.message = [[self _localizedStringForKey:@"exportingImage" defaultValue:exportString] retain];
	exportProgress.currentValue = ([[self imageList] count] - [_exportedImagePaths count]);
	exportProgress.totalValue = [[self imageList] count];
	[self unlockProgress];
}


#pragma mark -
// Utilities
#pragma mark Utilities

-(void)threadLoadThumbnails
{
	// since this method should be run in a seperate background
	// thread, we need to create our own NSAutoreleasePool, then
	// release it at the end.
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	// loop through each file name at this location
	NSInteger imageCount = [_exportManager imageCount];
	for (NSInteger i = 0; i < imageCount && [self shouldCancelUploadActivity] == NO; i++) {
		NSImage *thumbnail = [_exportManager thumbnailForImageAtIndex:i size: kExportThumbnailSizeThumbnail];
		if ([thumbnail isValid])
		{
			// drawing the entire, full-sized picture every time the table view
			// scrolls is way too slow, so instead will draw a thumbnail version
			// into a separate NSImage, which acts as a cache
			
			// Since performSelectorOnMainThread takes one argument and we need to send two we put our args in a dictionary.
			// The key is the index for the image and the value is the thumbnail
			NSDictionary * dict = [NSDictionary dictionaryWithObject:thumbnail forKey:[NSNumber numberWithInt:i]];
			
			// sync up with the mainnthread and set the thumbnail
			[self performSelectorOnMainThread: @selector(setThumbnailFromDict:)
								   withObject: dict
								waitUntilDone: NO];
		} else {
			NSLog(@"Unable to get thumbnail for image indexed at %d.", i);
		}
	}
	
	[self performSelectorOnMainThread: @selector(setDoneLoadingThumbnails:)
						   withObject: nil
                        waitUntilDone: NO];
	
	// remember to release the pool    
	[pool release];
}

- (void)reloadImageList
{
	// Some size for our placeholder image
	const NSSize kThumbnailSize = {172, 172};
	
	// the list of images we'll loaded from this directory
	NSMutableArray *imageList = [[NSMutableArray alloc] init];
	
	// loop through each file name at this location
	NSInteger imageCount = [_exportManager imageCount];
	
	// We create a placeholder thumbnail. We will replace this with the actual thumbnail
	// from a backgound thread
	NSImage * placeHolderThumbnail = [[NSImage alloc] initWithSize: kThumbnailSize];
	[placeHolderThumbnail setBackgroundColor: [NSColor darkGrayColor]];
	
	for (NSInteger i = 0; i < imageCount && [self shouldCancelUploadActivity] == NO; i++) {
		NSDictionary *image_dict = [_exportManager propertiesWithoutThumbnailForImageAtIndex:i];
		NSDictionary *image_properties = [image_dict objectForKey:kExportKeyIPTCProperties];
		
		if ([placeHolderThumbnail isValid])
		{
			// create a new FacebookPicture
			FacebookPicture *picture = [[FacebookPicture alloc] init];
			
			// set the path of the on-disk picture and our cache instance
			NSString *caption = [image_properties objectForKey:@"Caption/Abstract"];
			
			if (caption && [caption length] > 0) {
				[picture setDescription:caption];
			} else {
				[picture setDescription:[image_dict objectForKey:kExportKeyVersionName]];
			}
			
			[picture setTitle:[image_dict objectForKey:kExportKeyVersionName]];
			
			// Use the project name as a hint for the album name
			if (![self suggestedAlbumName]) {
				[self setSuggestedAlbumName:[[image_dict objectForKey:kExportKeyProjectName] retain]];
			}
			
			[picture setDefaultThumbnail:placeHolderThumbnail];
			
			// add to the FacebookPictures array
			[imageList addObject:picture];
			
			// adding an object to an array retains it, so we can release our reference.
			[picture release];
		} else {
			NSLog(@"Version %@ isn't found an picture", [image_dict objectForKey:kExportKeyVersionName]);
		}      
	}
	
	if ([self shouldCancelUploadActivity] == NO) {
		[self setImageList: imageList];
	}
	
	[placeHolderThumbnail release];
	[imageList release];
}

- (NSURL *)generateURL:(NSString *)baseURL params:(NSDictionary *)params {
	 if (params) {
		 NSMutableArray *pairs = [NSMutableArray array];
		 for (NSString *key in params.keyEnumerator) {
			 NSString *value = [params objectForKey:key];
			 NSString *escaped_value = (NSString *)CFURLCreateStringByAddingPercentEscapes(
																						   NULL, /* allocator */
																						   (CFStringRef)value,
																						   NULL, /* charactersToLeaveUnescaped */
																						   (CFStringRef)@"!*'();:@&=+$,/?%#[]",
																						   kCFStringEncodingUTF8);
			 
			 [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, escaped_value]];
			 [escaped_value release];
		 }
		 
		 NSString *query = [pairs componentsJoinedByString:@"&"];
		 NSString *url = [NSString stringWithFormat:@"%@?%@", baseURL, query];
		 return [NSURL URLWithString:url];
	 } else {
		 return [NSURL URLWithString:baseURL];
	 }
}

- (NSString *)extractParameter:(NSString *)param fromURL:(NSString *)url
{
    NSString *res = nil;
	
    NSRange paramNameRange = [url rangeOfString: param options: NSCaseInsensitiveSearch];
    if (paramNameRange.location != NSNotFound)
    {
        // Search for '&' or end-of-string
        NSRange searchRange = NSMakeRange(paramNameRange.location + paramNameRange.length, [url length] - (paramNameRange.location + paramNameRange.length));
        NSRange ampRange = [url rangeOfString: @"&" options: NSCaseInsensitiveSearch range: searchRange];
        if (ampRange.location == NSNotFound)
            ampRange.location = [url length];
        res = [url substringWithRange: NSMakeRange(searchRange.location, ampRange.location - searchRange.location)];
    }
	
    return res;
}

@end
