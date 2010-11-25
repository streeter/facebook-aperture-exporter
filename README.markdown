# Facebook Aperture Exporter

## About
This is a sinmple exporter plugin for Apple's Aperture. I wasn't happy with the built-in syncing Aperture 3 has, and the existing export plugin for Facebook wouldn't work for me. Plus, that author wasn't returning my emails to try and get it to work. So I wrote me own.

## Current Features
* logging in and out of a Facebook account
* album creation and selection (where to upload the photos to)
* high resolution uploads to Facebook

## Known Limitations and Issues
* The preferences button does nothing. Eventually it will show the preferences window.
* The export progress information in the Activity panel is pretty much broken. At least you know it is still exporting.
* The caption for a created Facebook album is not set. Still figuring out why that is the case.
* When starting the plugin, a sheet displays for a moment while we check that we have the Facebook access token. This shouldn't be displayed until we need the user to login.


## Usage and Installation
After downloading, this plugin should be put in the directory `~/Library/Application Support/Aperture/Plug-Ins/Export`. If the `Plug-Ins` and / or `Export` directories do not exist, create them.  If Aperture is running, restart it.  Then select the versions to export, choose `File -> Export -> FacebookExporter...`

## Screenshot

<a href="https://github.com/streeter/facebook-aperture-exporter/raw/master/screenshot.png"><img width="600" style="width: 600px" src="https://github.com/streeter/facebook-aperture-exporter/raw/master/screenshot.png" /></a>

## Authors
* <a href="http://www.chrisstreeter.com">Chris Streeter</a>
* Some code is taken from <a href="https://github.com/facebook/facebook-ios-sdk">Facebook's iOS Library</a> (why don't they have a desktop SDK!)
* Inspiration from the <a href="http://code.google.com/p/aperture-picasa-plugin/">Aperture to Picasa Plugin</a>