//
//	FacebookExporter.h
//	FacebookExporter
//
//	Created by Chris Streeter on 11/4/10.
//	Copyright chrisstreeter.com 2010. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import "ApertureExportManager.h"
#import "ApertureExportPlugIn.h"
#import "FacebookAlbum.h"
#import "FacebookPicture.h"
#import "FacebookRequestController.h"
#import <WebKit/WebKit.h>
#import <Sparkle/Sparkle.h>


@interface FacebookExporter : NSObject <ApertureExportPlugIn>
{
	// The cached API Manager object, as passed to the -initWithAPIManager: method.
	id _apiManager; 
	
	// The cached Aperture Export Manager object - you should fetch this from the API Manager during -initWithAPIManager:
	NSObject<ApertureExportManager, PROAPIObject> *_exportManager; 
	
	// The lock used to protect all access to the ApertureExportProgress structure
	NSLock *_progressLock;
	
	// Top-level objects in the nib are automatically retained - this array
	// tracks those, and releases them
	NSArray *_topLevelNibObjects;
	
	// The structure used to pass all progress information back to Aperture
	ApertureExportProgress exportProgress;

	// Outlets to your plug-ins user interface
	IBOutlet NSView *settingsView;
	IBOutlet NSView *firstView;
	IBOutlet NSView *lastView;
	
	// Outlets to the FB settings view
	IBOutlet NSTextField *loggedInAsTextField;
	IBOutlet NSButton *logOutButton;
	IBOutlet NSButton *preferencesButton;
	
	IBOutlet NSTableView *imageTableView;
	IBOutlet NSTextField *captionTextField;
	
	IBOutlet NSPopUpButton *albumListView;
	
	IBOutlet NSTextFieldCell *versionTextField;
	IBOutlet NSButton *openFacebookOnFinishButton;
	
	// Outlets to the fields on the connection progress sheet
	IBOutlet NSWindow *connectionWindow;
	IBOutlet NSProgressIndicator *connectionProgressIndicator;
	IBOutlet NSTextField *connectionStatusField;
	IBOutlet NSButton *connectionCancelButton;
	
	// Outles of authentication sheet.
	IBOutlet NSWindow *authenticationWindow;
	IBOutlet NSButton *connectButton;
	IBOutlet WebView *embeddedWebView;
	
	// Outlets to the new album sheet
	IBOutlet NSWindow *newAlbumWindow;
	IBOutlet NSTextField *newAlbumName;
	IBOutlet NSTextField *newAlbumDescription;
	
	// List of images being imported.
	NSMutableArray *_imageList;
	
	// For measuring progress - as Aperture writes data to disk, keep count of the bytes we need to upload.
	UInt64 totalBytes;
	
	// Minimum width to fit images + border.
	CGFloat _tableColumnWidth;
	
	// Album state
	NSString *_suggestedAlbumName;
	NSMutableArray *_albumList;
	FacebookAlbum *_selectedAlbum;
	
	// Tracking images that Aperture writes to disk
	NSString *_tempDirectoryPath;
	NSMutableArray *_exportedImagePaths;
	
	// User authentication information
	NSString *_accessToken;
	NSString *_userID;
	NSString *_username;
	
	// Export and user status.
	BOOL _loadingImages;
	BOOL _authenticated;
	BOOL _shouldCancelUploadActivity;
	
	FacebookRequestController *_requestController;
}

@property(nonatomic,assign) FacebookAlbum *selectedAlbum;
@property(nonatomic,assign) FacebookRequestController *requestController;
@property(nonatomic,assign) NSString *suggestedAlbumName;
@property(nonatomic,assign) NSString *userID;
@property(nonatomic,assign) BOOL loadingImages;
@property(nonatomic,assign) BOOL authenticated;
@property(nonatomic,assign) BOOL shouldCancelUploadActivity;

#pragma mark -
// Connection Progress Actions
#pragma mark Connection Progress Actions
- (IBAction)cancelConnectionWindow:(id)sender;

#pragma mark -
// Authentication Actions
#pragma mark Authentication Actions
- (void)finishGetUserInformation:(NSString *)userid username:(NSString *)username error:(NSString *)message;

- (void)cancelAuthenticationWindow;
- (IBAction)connectToFacebook:(id)sender;
- (IBAction)logOut:(id)sender;

#pragma mark -
// Preferences Actions
#pragma mark Preferences Actions
- (IBAction)openPreferencesWindow:(id)sender;

#pragma mark -
// Album Actions
#pragma mark Album Actions
- (void)finishFetchAllAlbums:(NSMutableArray *)albumList error:(NSString *)message;
- (void)finishCreateNewAlbumRequest:(NSString *)albumId error:(NSString *)message;

- (void)openNewAlbumWindow:(id)sender;
- (void)updateSelectedAlbum:(id)sender;

- (IBAction)finishCreateNewAlbumWindow:(id)sender;
- (IBAction)cancelCreateNewAlbumWindow:(id)sender;

#pragma mark -
// Album Accessors
#pragma mark Accessors
- (NSString *)accessToken;
- (void)setAccessToken:(NSString *)aValue;
- (NSString *)username;
- (void)setUsername:(NSString *)aValue;
- (NSMutableArray *)albumList;
- (void)setAlbumList:(NSMutableArray *)albumList;

// the getter returns an NSMutableArray but the setter
// takes a regular NSArray. That allows us to accept
// either kind of array as input.
- (NSMutableArray *)imageList;
- (void)setImageList:(NSArray *)aValue;

#pragma mark -
// TableView Delegate Methods
#pragma mark TableView Delegate Methods
//- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row;
- (void)tableViewSelectionIsChanging:(NSNotification *)aNotification;

#pragma mark -
// WebView Delegate Methods
#pragma mark WebView Delegate Methods
- (NSURLRequest *)webView:(WebView *)sender resource:(id)identifier willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse fromDataSource:(WebDataSource *)dataSource;
- (void)webView:(WebView *)sender didCommitLoadForFrame:(WebFrame *)frame;

#pragma mark -
// Sparkle Delegate Methods
#pragma mark Sparkle Delegate Methods
- (void)updater:(SUUpdater *)updater didFinishLoadingAppcast:(SUAppcast *)appcast;
- (void)updater:(SUUpdater *)updater didFindValidUpdate:(SUAppcastItem *)update;
- (void)updaterDidNotFindUpdate:(SUUpdater *)update;

#pragma mark -
// Private Methods
#pragma mark Private Methods
- (NSString *)_localizedStringForKey:(NSString *)key defaultValue:(NSString *)value;
- (void)_finishCurrentUploadWithSuccess:(BOOL)success;
- (void)_uploadNextImage;
- (void)_incrementUploadProgress:(SInt32)bytesWritten;

@end
