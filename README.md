# Facebook Aperture Exporter

## About
This is a simple exporter plugin for [Apple's Aperture][aperture]. I wasn't happy with the built-in syncing Aperture 3 has, and the existing export plugin for Facebook wouldn't work for me. Plus, that author wasn't returning my emails to try and get it to work. So I wrote my own.

This repository hosts the source code, documentation and is the place to report issues. The [downloads are located at Bitbucket][downloads]

## Current Features
* Logging in and out of a Facebook account
* Album creation with privacy and selection (where to upload the photos to)
* High resolution photo uploads to Facebook
* Enabled by uploading large versions to Facebook (choose an export preset that will create 2048 pixels along the largest side)
* Option to use IPTC headline instead of caption as photo title ([Issue #9][issue-9])
* Sparkle updating
* Growl notifications

## Known Limitations and Issues
* The export progress information in the Activity panel is pretty much broken. At least you know it is still exporting.
* The caption for a created Facebook album is not set. Still figuring out why that is the case.

## Nice Features to Have
* Choose whether to use the Title or Description from each photo to use as the photo's caption on Facebook (currently uses the title).
* Add a tag to all uploaded photos

## Usage and Installation
1. You need OS X 10.7 (Lion) to use the latest plugin.
2. Download the [plugin from the downloads page][downloads].
3. After downloading, put the plugin in the directory `~/Library/Application Support/Aperture/Plug-Ins/Export`. If the `Plug-Ins` and / or `Export` directories do not exist, create them.
4. If Aperture is running, restart it.
5. Select the versions to export, choose `File -> Export -> FacebookExporter...`

## Screenshot

![Screenshot][screenshot]

## Authors
* [Chris Streeter][chris-streeter]
* [Alex Brand][alex-brand] (contributor)
* Some code is taken from [Facebook's iOS Library][facebook-sdk] (why don't they have a desktop SDK!)
* Inspiration from the [Aperture to Picasa Plugin][aperture-picasa]


[aperture]: http://www.apple.com/aperture/
[gh-repo]: https://github.com/streeter/facebook-aperture-exporter
[downloads]: https://bitbucket.org/streeter/facebook-aperture-exporter/downloads
[issue-9]: https://github.com/streeter/facebook-aperture-exporter/issues/9
[screenshot]: https://github.com/streeter/facebook-aperture-exporter/raw/master/screenshot.png
[chris-streeter]: http://www.chrisstreeter.com
[alex-brand]: https://github.com/alinx
[facebook-sdk]: https://github.com/facebook/facebook-ios-sdk
[aperture-picasa]: http://code.google.com/p/aperture-picasa-plugin/