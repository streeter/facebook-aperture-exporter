# Facebook Aperture Exporter

## About
This is a sinmple exporter plugin for <a href="http://www.apple.com/aperture/">Apple's Aperture</a>. I wasn't happy with the built-in syncing Aperture 3 has, and the existing export plugin for Facebook wouldn't work for me. Plus, that author wasn't returning my emails to try and get it to work. So I wrote my own.

## Current Features
* Logging in and out of a Facebook account
* Album creation and selection (where to upload the photos to)
* High resolution photo uploads to Facebook
  * Enabled by uploading large versions to Facebook (choose an export preset that will create 2048 pixels along the largest side)

## Known Limitations and Issues
* The preferences button does nothing. Eventually it will show the preferences window.
* The export progress information in the Activity panel is pretty much broken. At least you know it is still exporting.
* The caption for a created Facebook album is not set. Still figuring out why that is the case.
* The open album when upload is complete checkbox does not work
* When starting the plugin, a sheet displays for a moment while we check that we have the Facebook access token. This shouldn't be displayed until we need the user to login.

## Nice Features to Have
* Growl notifications
* Choose whether to use the Title or Description from each photo to use as the photo's caption on Facebook (currently uses the title).
* Add a tag to all uploaded photos

## Usage and Installation
1. Download the <a href="https://github.com/downloads/streeter/facebook-aperture-exporter/FacebookExporter.ApertureExport.zip">plugin from github</a>.
2. After downloading, put the plugin in the directory `~/Library/Application Support/Aperture/Plug-Ins/Export`. If the `Plug-Ins` and / or `Export` directories do not exist, create them.
3. If Aperture is running, restart it.
4. Select the versions to export, choose `File -> Export -> FacebookExporter...`

## Screenshot

<a href="https://github.com/streeter/facebook-aperture-exporter/raw/master/screenshot.png"><img width="600" style="width: 600px" src="https://github.com/streeter/facebook-aperture-exporter/raw/master/screenshot.png" /></a>

## Authors
* <a href="http://www.chrisstreeter.com">Chris Streeter</a>
* Some code is taken from <a href="https://github.com/facebook/facebook-ios-sdk">Facebook's iOS Library</a> (why don't they have a desktop SDK!)
* Inspiration from the <a href="http://code.google.com/p/aperture-picasa-plugin/">Aperture to Picasa Plugin</a>