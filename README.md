# Mapbox iOS Store Locator Kit

The iOS Store Locator Kit is a downloadable project for you to add beautiful plug-and-play Store Locators to your iOS applications. Use the Kit to allow your users to find and browse store locations, view additional info for each store, and preview the distance and route to the store. Not building for a store owner or a business? You can use this project to locate anything from bike share hubs to ATMs to your neighborhood parks. See [this tutorial](https://www.mapbox.com/help/ios-store-locator/) to help you get started!

#### Included in the Kit:
+ Source files for the app
+ Five UI themes
+ A sample dataset in the form of a GeoJSON file
+ Code for retrieving directions to store locations with the [Mapbox Directions API](https://www.mapbox.com/help/define-directions-api/)


### Get started by [downloading](https://github.com/mapbox/store-locator-ios/archive/master.zip) the project and walking through the [step-by-step tutorial](https://www.mapbox.com/help/ios-store-locator/). Don't forget your [access token](https://www.mapbox.com/help/define-access-token/).

# What can I customize?

We built this Kit to cut down on the set-up and development time needed to add a Store Locator into your app. Use our starter themes and features as a plug-and-play solution, or further customize your Store Locator with our flexible build.

### Add custom markers

Use our pre-built markers, or add in your own by creating your own icon, using your company’s logo, or another open source image.

### Card icons

Customize the style of the interactive scrolling cards (i.e. pop-ups) included in your Store Locator.

### Bringing your own data

Add as many store locations as you wish as a GeoJSON file. Remember that you could use this Kit to locate not just stores, but anything else like bike share hubs, ATMs, parks, or even your friends!

### Map

The Kit comes with five UI starter themes, but you can further customize these themes as you see fit. Or create your own custom map styles by using Mapbox Studio to build a style that fits your brand.

### Routing profile

The Kit includes the use of the Mapbox Directions API to display estimated travel distances and display driving routes to store locations.

# Mapbox Kits

This is the first of several plug-and-play Kits that Mapbox will be releasing to reduce set-up time and make it easy for developers to get up and running with common mapping & location builds. If you have any feedback, questions, or suggestions for future iOS Kits, open an [issue](https://github.com/mapbox/store-locator-ios/issues) for us!

# Getting started

This project was built using Swift 4, Xcode 9, and Mapbox iOS SDK v3.7.0-beta.3. Minimum deployment target is iOS 9. The Mapbox Store Locator currently supports portrait mode.

Steps to run:

1. Install the project's dependencies by using CocoaPods: http://guides.cocoapods.org/using/getting-started.html#installation

2. Add your access token to the project. For more information about access tokens, see: https://www.mapbox.com/ios-sdk/#access_tokens

3. To use one of the provided themes, select a theme from Theme.swift. You can also create your own theme by creating a Theme object.

To draw a route line from the "user's location" to a destination, tap on a store. This uses the Mapbox Directions API. Routes are cached.
