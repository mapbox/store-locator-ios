//
//  ThemeViewController.swift
//  mapbox-store-locator
//
//  Created by Nadia Barbosa on 9/12/17.
//  Copyright © 2017 Mapbox. All rights reserved.
//

import Mapbox
import MapboxDirections

class ThemeViewController: UIViewController, MGLMapViewDelegate, CLLocationManagerDelegate {
    
    // Lines 14 is for the example only. Users will want to set the theme on line 38.
    var viewControllerTheme : Theme?
    
    // MARK: Customize these variables to style your map:
    // Use a MBXTheme from Themes.swift, or create a Color object that contains the necessary colors and use it to set the theme.
    //      var viewControllerTheme : Theme? = MBXTheme.purpleTheme
    
    var centerCoordinate = CLLocationCoordinate2D(latitude: 40.7478, longitude: -73.9898) // This will serve as the center coordinate if the user denies location permissions.
    var mapView: MGLMapView!
    var itemView : CustomItemView! // Keeps track of the current CustomItemView.
    
    let userLocationFeature = MGLPointFeature()
    var userLocationCoordinate = CLLocationCoordinate2D() // This can be removed if the user location is being tracked.
    var userLocationSource : MGLShapeSource?
    
    // Properties for the callout.
    var pageViewController : UIPageViewController!
    var features : [MGLPointFeature] = []
    let uniqueIdentifier = "phone" // Replace this with the property key for a value that is unique within your data. Do not use coordinates.
    var customItemViewSize = CGRect()
    var featuresWithRoute : [String : (MGLPointFeature, [CLLocationCoordinate2D])] = [:]
    var selectedFeature : (MGLPointFeature, [CLLocationCoordinate2D])?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = false
        }
        
        mapView = MGLMapView(frame: view.bounds, styleURL: viewControllerTheme?.styleURL) // Set the map's style url.
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.delegate = self
        mapView.zoomLevel = 11
        
        //   mapView.setCenter(centerCoordinate, zoomLevel: 11, animated: false)      // MARK: To center on the user's location, comment this line out and uncomment the following line.
        
        mapView.userTrackingMode = .follow
        
        view.addSubview(mapView)
        
        if CLLocationManager.authorizationStatus() == .denied || CLLocationManager.authorizationStatus() == .notDetermined {
            mapView.setCenter(centerCoordinate, zoomLevel: 11, animated: false)
        }
        mapView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleItemTap(sender:))))
        
        customItemViewSize = CGRect(x: 0, y: mapView.bounds.height * 3 / 4, width: view.bounds.width, height: view.bounds.height / 4)
        
        addPageViewController()
    }
    
    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
        
        DispatchQueue.global().async {

            guard let url = self.viewControllerTheme?.fileURL else { return } // Set the URL containing your store locations.
            let data = try! Data(contentsOf: url)
            DispatchQueue.main.async {
                self.drawPointData(data: data)
            }
        }
        if CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            addUserLocationDot(to: style)
        } else {
            mapView.setCenter(centerCoordinate, zoomLevel: 11, animated: false)
        }
    }
    
    func drawPointData(data: Data) {
        guard let style = mapView.style else { return }
        
        let feature = try! MGLShape(data: data, encoding: String.Encoding.utf8.rawValue) as! MGLShapeCollectionFeature
        
        let source = MGLShapeSource(identifier: "store-locations", shape: feature, options: nil)
        style.addSource(source)
        
        // Set the default item image.
        style.setImage((viewControllerTheme?.defaultMarker)!, forName: "unselected_marker")
        // Set the image for the selected item.
        style.setImage((viewControllerTheme?.selectedMarker)!, forName: "selected_marker")
        
        let symbolLayer = MGLSymbolStyleLayer(identifier: "store-locations", source: source)
        
        symbolLayer.iconImageName = NSExpression(forConstantValue: "unselected_marker")
        symbolLayer.iconAllowsOverlap = NSExpression(forConstantValue: 1)
        
        style.addLayer(symbolLayer)
        
        features = feature.shapes as! [MGLPointFeature]
        if CLLocationManager.authorizationStatus() != .authorizedAlways || CLLocationManager.authorizationStatus() != .authorizedWhenInUse  {
            populateFeaturesWithRoutes()
        }
    }
    
    // MARK: Use a custom user location dot.
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        
        if annotation is MGLUserLocation && mapView.userLocation != nil {
            let annot = CustomUserLocationAnnotationView(frame: CGRect(x: 0, y: 0, width: 25, height: 25), color: (viewControllerTheme?.themeColor.primaryDarkColor)!)
            
            return annot
        }
        return nil
    }
    
    func mapView(_ mapView: MGLMapView, didUpdate userLocation: MGLUserLocation?) {
        if let coord = userLocation?.coordinate {
            userLocationFeature.coordinate = coord
            userLocationSource?.shape = userLocationFeature
            
            mapView.setCenter(coord, animated: false)
            if CLLocationCoordinate2DIsValid(userLocationFeature.coordinate) {
                populateFeaturesWithRoutes()
            }
        }
    }
    
    func addUserLocationDot(to style: MGLStyle) {
        if !CLLocationCoordinate2DIsValid(userLocationFeature.coordinate) {
            userLocationFeature.coordinate = centerCoordinate
        }
        
        userLocationSource = MGLShapeSource(identifier: "user-location", features: [userLocationFeature], options: nil)
        let userLocationStyle = MGLCircleStyleLayer(identifier: "user-location-style", source: userLocationSource!)
        // Set the color for the user location dot, if applicable.
        userLocationStyle.circleColor = NSExpression(forConstantValue: viewControllerTheme?.themeColor.primaryDarkColor)
        userLocationStyle.circleRadius = NSExpression(forConstantValue: 7)
        userLocationStyle.circleStrokeColor = NSExpression(forConstantValue: viewControllerTheme?.themeColor.primaryDarkColor)
        userLocationStyle.circleStrokeWidth = NSExpression(forConstantValue: 4)
        userLocationStyle.circleStrokeOpacity = NSExpression(forConstantValue: 0.5)
        
        style.addSource(userLocationSource!)
        style.addLayer(userLocationStyle)
    }
    
    @objc func handleItemTap(sender: UIGestureRecognizer) {
        if sender.state == .ended {
            
            let point = sender.location(in: sender.view!)
            let layer: Set = ["store-locations"]
            
            if mapView.visibleFeatures(at: point, styleLayerIdentifiers: layer).count > 0 && !UIDevice.current.orientation.isLandscape {
                
                // If there is an item at the tap's location, change the marker to the selected marker.
                for feature in mapView.visibleFeatures(at: point, styleLayerIdentifiers: layer)
                    where feature is MGLPointFeature {
                        changeItemColor(feature: feature)
                        generateItemPages(feature: feature as! MGLPointFeature)
                        
                        let mapViewSize = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height * 3/4)
                        mapView.frame = mapViewSize
                        pageViewController.view.isHidden = false
                }
            } else {
                // If there isn't an item at the tap's location, reset the map.
                changeItemColor(feature: MGLPointFeature())
                
                if let routeLineLayer = mapView.style?.layer(withIdentifier: "route-style") {
                    routeLineLayer.isVisible = false
                }
                
                pageViewController.view.isHidden = true
                mapView.frame = view.bounds
            }
        }
    }
    
    func changeItemColor(feature: MGLFeature) {
        let layer = mapView.style?.layer(withIdentifier: "store-locations") as! MGLSymbolStyleLayer
        if let name = feature.attribute(forKey: "name") as? String {
            
            // Change the icon to the selected icon based on the feature name. If multiple items have the same name, choose an attribute that is unique.
            layer.iconImageName = NSExpression(format: "TERNARY(name = %@, 'selected_marker', 'unselected_marker')", name)
            
        } else {
            // Deselect all items if no feature was selected.
            layer.iconImageName = NSExpression(forConstantValue: "unselected_marker")
        }
    }
    
    // MARK: Directions methods.
    // TODO: Reroute if the user's location has changed. Maybe check distance from origin and draw a new route if it's more that ~1000m?
    // Get the coordinates for the route.
    func getRoute(from origin: CLLocationCoordinate2D,
                  to destination: MGLPointFeature) -> [CLLocationCoordinate2D]{
        
        var routeCoordinates : [CLLocationCoordinate2D] = []
        let originWaypoint = Waypoint(coordinate: origin)
        let destinationWaypoint = Waypoint(coordinate: destination.coordinate)
        
        let options = RouteOptions(waypoints: [originWaypoint, destinationWaypoint], profileIdentifier: .automobileAvoidingTraffic)
        
        _ = Directions.shared.calculate(options) { (waypoints, routes, error) in
            
            guard error == nil else {
                print("Error calculating directions: \(error!)")
                return
            }
            
            guard let route = routes?.first else { return }
            routeCoordinates = route.coordinates!
            self.featuresWithRoute[self.getKeyForFeature(feature: destination)] = (destination, routeCoordinates)
        }
        return routeCoordinates
    }
    
    func populateFeaturesWithRoutes() {
        if CLLocationCoordinate2DIsValid(userLocationFeature.coordinate) {
            for point in features {
                let routeCoordinates = getRoute(from: userLocationFeature.coordinate, to: point)
                featuresWithRoute[getKeyForFeature(feature: point)] = (point, routeCoordinates)
            }
        }
    }
    
    // Draw a route line using the stored route for a feature.
    func drawRouteLine(from route: [CLLocationCoordinate2D]) {
        if route.count > 0 {
            if let routeStyleLayer = self.mapView.style?.layer(withIdentifier: "route-style") {
                routeStyleLayer.isVisible = true
            }
            
            let polyline = MGLPolylineFeature(coordinates: route, count: UInt(route.count))
            
            if let source = self.mapView.style?.source(withIdentifier: "route-source") as? MGLShapeSource {
                source.shape = polyline
            } else {
                let source = MGLShapeSource(identifier: "route-source", features: [polyline], options: nil)
                self.mapView.style?.addSource(source)
                
                let lineStyle = MGLLineStyleLayer(identifier: "route-style", source: source)
                
                // Set the line color to the theme's color.
                lineStyle.lineColor = NSExpression(forConstantValue: self.viewControllerTheme?.themeColor.navigationLineColor)
                lineStyle.lineJoin = NSExpression(forConstantValue: "round")
                lineStyle.lineWidth = NSExpression(forConstantValue: 3)
                
                if let userDot = mapView.style?.layer(withIdentifier: "user-location-style") {
                    self.mapView.style?.insertLayer(lineStyle, below: userDot)
                } else {
                    for layer in (mapView.style?.layers.reversed())! where layer.isKind(of: MGLSymbolStyleLayer.self) {
                        self.mapView.style?.insertLayer(lineStyle, below: layer)
                        break
                    }
                }
            }
        }
    }
    
    // Adds the page view controller that will become the callout.
    func addPageViewController() {
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController.isDoubleSided = false
        pageViewController.delegate = self
        pageViewController.dataSource = self
        pageViewController.view.frame = customItemViewSize
        pageViewController.view.backgroundColor = viewControllerTheme?.themeColor.primaryDarkColor
        pageViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = true
        view.addSubview(pageViewController.view)
        pageViewController.view.isHidden = true
    }
    
    // Determine the feature that was tapped on.
    func generateItemPages(feature: MGLPointFeature) {
        
        mapView.centerCoordinate = feature.coordinate
        selectedFeature = featuresWithRoute[getKeyForFeature(feature: feature)]
        
        if let themeColor = viewControllerTheme?.themeColor, let iconImage = viewControllerTheme?.defaultMarker {
            let vc = UIViewController()
            itemView = CustomItemView(feature: feature, themeColor: themeColor, iconImage: iconImage)
            itemView.frame = customItemViewSize
            if let selectedRoute = selectedFeature?.1 {
                drawRouteLine(from: selectedRoute)
            }
            vc.view = itemView
            vc.view.autoresizingMask =  [ .flexibleHeight, .flexibleWidth ]
            pageViewController.setViewControllers([vc], direction: .forward, animated: false, completion: nil)
        }
    }
    
    // MARK: Functions to lookup features.
    // Get the key for a feature.
    func getKeyForFeature(feature: MGLPointFeature) -> String {
        if let selectFeature = feature.attribute(forKey: uniqueIdentifier) as? String {
            return selectFeature
        }
        return ""
    }
    
    // Get the index for a feature in the array of features.
    func getIndexForFeature(feature: MGLPointFeature) -> Int {
        // Filter the features based on a unique attribute. In this case, the location's phone number is used.
        let selectFeature = features.filter({ $0.attribute(forKey: uniqueIdentifier) as! String == feature.attribute(forKey: uniqueIdentifier) as! String })
        if let index = features.firstIndex(of: selectFeature.first!) {
            return index
        }
        return 0
    }
    
    // Hide callout when device is in landscape mode.
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation.isPortrait {
            pageViewController.view.layoutSubviews()
            if let viewController = pageViewController.viewControllers?.first {
                viewController.view.layoutSubviews()
            }
        } else if UIDevice.current.orientation.isLandscape {
            changeItemColor(feature: MGLPointFeature())
            pageViewController.view.isHidden = true
            mapView.frame = view.bounds
            if let routeLineLayer = mapView.style?.layer(withIdentifier: "route-style") {
                routeLineLayer.isVisible = false
            }
        }
    }
}

// MARK: UIPageViewControllerDelegate and UIPageViewControllerDataSource methods.
extension ThemeViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        if let view = pendingViewControllers.first?.view as? CustomItemView {
            selectedFeature = featuresWithRoute[getKeyForFeature(feature: view.selectedFeature)]
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let view = pageViewController.viewControllers?.first?.view as? CustomItemView {
            if let currentFeature = featuresWithRoute[getKeyForFeature(feature: view.selectedFeature)] {
                selectedFeature = currentFeature
                mapView.centerCoordinate = (selectedFeature?.0.coordinate)!
                drawRouteLine(from: (selectedFeature?.1)!)
                changeItemColor(feature: (selectedFeature?.0)!)
            }
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let currentFeature = selectedFeature?.0 {
            let index = getIndexForFeature(feature: currentFeature)
            let nextVC = UIViewController()
            var nextFeature = MGLPointFeature()
            
            if let themeColor = viewControllerTheme?.themeColor, let iconImage = viewControllerTheme?.defaultMarker {
                if index - 1 < 0 {
                    nextFeature = features.last!
                } else {
                    nextFeature = features[index-1]
                }
                nextVC.view = CustomItemView(feature: nextFeature, themeColor: themeColor, iconImage: iconImage)
                itemView = nextVC.view as! CustomItemView?
            }
            return nextVC
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let currentFeature = selectedFeature?.0 {
            
            let index = getIndexForFeature(feature: currentFeature)
            let nextVC = UIViewController()
            var nextFeature = MGLPointFeature()
            
            
            if let themeColor = viewControllerTheme?.themeColor, let iconImage = viewControllerTheme?.defaultMarker {
                if index != (features.count - 1) {
                    nextFeature = features[index+1]
                } else {
                    nextFeature = features[0]
                }
                print(nextFeature)
                selectedFeature = featuresWithRoute[getKeyForFeature(feature: nextFeature)]
                nextVC.view = CustomItemView(feature: nextFeature, themeColor: themeColor, iconImage: iconImage)
                itemView = nextVC.view as! CustomItemView?
            }
            return nextVC
            
        }
        return nil
    }
}

// MARK: CustomItemView - The callout for the map.
// Creates a custom item that displays information about the selected feature.
class CustomItemView : UIView {
    var selectedFeature = MGLPointFeature()
    
    @IBOutlet var containerView: CustomItemView!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var itemHourLabel: UILabel!
    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var itemDescriptionLabel: UILabel!
    @IBOutlet weak var itemPhoneNumberLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    var iconImage = UIImage()
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var headerView: UIView!
    var routeDistance = ""
    var themeColor : Color!
    
    override init(frame: CGRect) {
        super.init(frame: CGRect())
        
        Bundle.main.loadNibNamed("CustomItemView", owner: self, options: nil)
        backgroundColor = .purple
        
        self.frame = bounds
        addSubview(containerView)
        
        containerView.frame = bounds
        containerView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        containerView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        if containerView.headerView != nil {
            containerView.headerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            containerView.headerView.translatesAutoresizingMaskIntoConstraints = false
            containerView.headerView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height * 0.25)
        }
        
        if containerView.iconImageView != nil {
            containerView.iconImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            containerView.iconImageView.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    required convenience init(feature: MGLPointFeature, themeColor: Color, iconImage: UIImage) {
        
        self.init(frame: CGRect())
        self.themeColor = themeColor
        self.iconImage = iconImage
        self.selectedFeature = feature
        
        createItemView()
        
        updateLabels()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK: Update the attribute keys based on your data's format.
    public func updateLabels() {
        if let name : String = selectedFeature.attribute(forKey: "name") as? String {
            containerView.itemNameLabel.text = name
        }
        if let hours : String = selectedFeature.attribute(forKey: "hours") as? String {
            containerView.itemHourLabel.text = hours
        }
        if let description : String = selectedFeature.attribute(forKey: "description") as? String  {
            containerView.itemDescriptionLabel.text = description
        }
        
        if let number : String = selectedFeature.attribute(forKey: "phone") as? String  {
            containerView.itemPhoneNumberLabel.text = number
        }
    }
    
    func createItemView() {
        
        containerView.headerView.backgroundColor = themeColor.primaryDarkColor
        
        // Create the icon image for the logo.
        containerView.iconImageView.image = iconImage
        
        // Create item name label.
        containerView.itemNameLabel.textColor = .white
        
        // Create description label.
        containerView.itemDescriptionLabel.textColor = .white
        
        // Create hours open label.
        containerView.itemHourLabel.textColor = themeColor.lowerCardTextColor
        
        //Create phone number label.
        containerView.itemPhoneNumberLabel.textColor = themeColor.lowerCardTextColor
        
        // Static labels for attributes.
        containerView.hoursLabel.textColor = themeColor.lowerCardTextColor
        
        containerView.phoneNumberLabel.textColor = themeColor.lowerCardTextColor
    }
}

class CustomUserLocationAnnotationView: MGLUserLocationAnnotationView {
    var border: CALayer!
    var dot: CALayer!
    let size = 5
    var color : UIColor!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = frame
    }
    
    convenience init(frame: CGRect, color: UIColor) {
        self.init(frame: frame)
        self.color = color
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func update() {
        if frame.isNull {
            frame = CGRect(x: 0, y: 0, width: size, height: size)
            return setNeedsLayout()
        }
        if CLLocationCoordinate2DIsValid(self.userLocation!.coordinate) {
            setupDot()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    func setupDot() {
        if dot == nil || border == nil {
            border = CALayer()
            border.bounds = bounds
            border.cornerRadius = border.bounds.width / 2
            border.backgroundColor = color.cgColor
            border.opacity = 0.0
            dot = CALayer()
            dot.bounds = CGRect(x: 0, y: 0, width: size * 2 / 3, height: size * 2 / 3)
            dot.cornerRadius = dot.bounds.width / 2
            dot.backgroundColor = color.cgColor
            dot.opacity = 0.0
            layer.addSublayer(border)
            layer.addSublayer(dot)
        }
    }
}
