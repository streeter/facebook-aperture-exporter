//
//  PlugInDefaults.h
//  FacebookExporter
//
//  Created by Alex Brand on 18.06.11.
//  Copyright 2011 Alex Brand. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BundleUserDefaults.h"

@interface PlugInDefaults : NSObject {

}

+ (BOOL)isUserAuthenticated;
+ (void)setUserAuthenticated:(BOOL)defaultAuthenticated;
+ (void)removeUserAuthenticated;
+ (BOOL)isOpenFacebookOnFinish;
+ (void)setOpenFacebookOnFinish:(BOOL)openOnFinish;

@end
