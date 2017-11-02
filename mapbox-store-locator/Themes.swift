//
//  ThemeColors.swift
//  mapbox-store-locator
//
//  Created by Jordan Kiley on 9/12/17.
//  Copyright © 2017 Mapbox. All rights reserved.
//

import Mapbox

// Themes with markers, map styles, and color schemes.
class MBXTheme : NSObject {
    
    static let purpleTheme = Theme(defaultMarker: UIImage(named: "purple_unselected_burger")!,
                                   selectedMarker: UIImage(named: "purple_selected_burger")!,
                                   styleURL: URL(string: "mapbox://styles/mapbox/cj7bww7is2f4i2rnwyxkzpwu7")!,
                                   themeColor: ThemeColor.purpleTheme,
                                   fileURL: Bundle.main.url(forResource: "stores", withExtension: "geojson")!)
    
    static let blueTheme = Theme(defaultMarker: UIImage(named: "blue_unselected_ice_cream")!,
                                 selectedMarker: UIImage(named: "blue_selected_ice_cream")!,
                                 styleURL: URL(string: "mapbox://styles/mapbox/cj7bwwv3caf7l2spgukxm8bwv")!,
                                 themeColor: ThemeColor.blueTheme,
                                 fileURL: Bundle.main.url(forResource: "stores", withExtension: "geojson")!)
    static let greenTheme = Theme(defaultMarker: UIImage(named: "green_unselected_money")!,
                                  selectedMarker: UIImage(named: "green_selected_money")!,
                                  styleURL: URL(string: "mapbox://styles/mapbox/cj62n87yx3mvi2rp93sfp2w9z")!,
                                  themeColor: ThemeColor.greenTheme,
                                  fileURL: Bundle.main.url(forResource: "stores", withExtension: "geojson")!)
    static let grayTheme = Theme(defaultMarker: UIImage(named: "white_unselected_bike")!,
                                 selectedMarker: UIImage(named: "gray_selected_bike")!,
                                 styleURL: MGLStyle.lightStyleURL(),
                                 themeColor: ThemeColor.grayTheme,
                                 fileURL: Bundle.main.url(forResource: "stores", withExtension: "geojson")!)
    static let neutralTheme = Theme(defaultMarker: UIImage(named: "blue_unselected_house")!,
                                    selectedMarker: UIImage(named: "blue_selected_house")!,
                                    styleURL: MGLStyle.streetsStyleURL(),
                                    themeColor: ThemeColor.neutralTheme,
                                    fileURL: Bundle.main.url(forResource: "stores", withExtension: "geojson")!)
    static let themes: [Theme] = [
        purpleTheme,
        blueTheme,
        greenTheme,
        grayTheme,
        neutralTheme
    ]
    

}

// Colors that match the provided themes.
class ThemeColor: NSObject {
    static let purpleTheme = Color(primaryColor: UIColor(red:0.64, green:0.36, blue:0.80, alpha:1.0),
                                   primaryDarkColor: UIColor(red:0.36, green:0.22, blue:0.73, alpha:1.0),
                                   navigationLineColor: UIColor(red:0.60, green:0.49, blue:0.87, alpha:1.0),
                                   lowerCardTextColor: UIColor(red:0.42, green:0.08, blue:0.61, alpha:1.0),
                                   accentColor: UIColor(red:0.78, green:0.66, blue:0.85, alpha:1.0))
    
    static let blueTheme = Color(primaryColor: UIColor(red:0.27, green:0.67, blue:0.91, alpha:1.0),
                                 primaryDarkColor: UIColor(red:0.15, green:0.55, blue:0.73, alpha:1.0),
                                 navigationLineColor: UIColor(red:0.43, green:0.79, blue:0.95, alpha:1.0),
                                 lowerCardTextColor: UIColor(red:0.06, green:0.51, blue:0.70, alpha:1.0),
                                 accentColor: UIColor(red:0.62, green:0.80, blue:0.88, alpha:1.0))
    
    static let greenTheme = Color(primaryColor: UIColor(red:0.35, green:0.89, blue:0.14, alpha:1.0),
                                  primaryDarkColor: UIColor(red:0.23, green:0.78, blue:0.01, alpha:1.0),
                                  navigationLineColor: UIColor(red:0.23, green:0.78, blue:0.01, alpha:1.0),
                                  lowerCardTextColor: UIColor.black,
                                  accentColor: UIColor(red:0.47, green:0.96, blue:0.27, alpha:1.0))
    
    static let neutralTheme = Color(primaryColor: UIColor(red:0.91, green:0.90, blue:0.88, alpha:1.0),
                                    primaryDarkColor: UIColor(red:0.70, green:0.69, blue:0.67, alpha:1.0),
                                    navigationLineColor: UIColor(red:0.00, green:0.73, blue:1.00, alpha:1.0),
                                    lowerCardTextColor: UIColor.black,
                                    accentColor: UIColor.white)
    
    static let grayTheme = Color(primaryColor: UIColor(red:0.93, green:0.94, blue:0.94, alpha:1.0),
                                 primaryDarkColor: UIColor(red:0.41, green:0.41, blue:0.41, alpha:1.0),
                                 navigationLineColor: UIColor(red:0.41, green:0.41, blue:0.41, alpha:1.0),
                                 lowerCardTextColor: UIColor(red:0.41, green:0.41, blue:0.41, alpha:1.0),
                                 accentColor: UIColor(red:0.62, green:0.62, blue:0.62, alpha:1.0))
    
}

// MARK: Structs for Theme and Color objects.
struct Color {
    let primaryColor : UIColor
    let navigationLineColor: UIColor
    let lowerCardTextColor: UIColor
    let primaryDarkColor: UIColor
    let accentColor: UIColor
    
    init(primaryColor: UIColor, primaryDarkColor: UIColor, navigationLineColor: UIColor, lowerCardTextColor: UIColor, accentColor: UIColor) {
        self.primaryColor = primaryColor
        self.primaryDarkColor = primaryDarkColor
        self.lowerCardTextColor = lowerCardTextColor
        self.accentColor = accentColor
        self.navigationLineColor = navigationLineColor
    }
}

struct Theme {
    var styleURL: URL
    var defaultMarker: UIImage
    var selectedMarker: UIImage
    var themeColor: Color
    var fileURL: URL
    init(defaultMarker: UIImage, selectedMarker: UIImage, styleURL: URL, themeColor: Color, fileURL: URL) {
        self.defaultMarker = defaultMarker
        self.selectedMarker = selectedMarker
        self.styleURL = styleURL
        self.themeColor = themeColor
        self.fileURL = fileURL
    }
}
