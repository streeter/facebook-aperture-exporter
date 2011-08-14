//
//  PlugInUpdateCheck.h
//  FacebookExporter
//
//  Created by Alex Brand on 18.06.11.
//  Copyright 2011 Alex Brand. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PlugInSUStandardVersionComparator.h"
#import "TouchXML.h"


@interface PlugInUpdateCheck : NSObject {

}

+ (BOOL)isUpdateAvailable:(NSString **)newVersion;

@end
