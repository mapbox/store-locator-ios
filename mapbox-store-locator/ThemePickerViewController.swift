//
//  ThemePickerViewController.swift
//  mapbox-store-locator
//
//  Created by Nadia Barbosa on 9/12/17.
//  Copyright © 2017 Mapbox. All rights reserved.
//

import Mapbox

class ThemeTableViewCell: UITableViewCell {
    @IBOutlet weak var themeImageView: UIImageView!
    @IBOutlet weak var themeMarkerImageView: UIImageView!

    var snapshotter: MGLMapSnapshotter?
}

class ThemePickerViewController: UITableViewController {
    
    @IBOutlet weak var themeImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
        
        tableView.tableFooterView = UIView()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MBXTheme.themes.count
    }
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let theme = MBXTheme.themes[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "example", for: indexPath) as! ThemeTableViewCell
        
        let center = CLLocationCoordinate2D(latitude: 40.72234, longitude:  -73.99223)
        let camera = MGLMapCamera(lookingAtCenter: center, fromDistance: 0, pitch: 0, heading: 0)
        
        // Takes a snapshot of each map with its style and marker, then uses those to create the cell.

        let snapshotOptions = MGLMapSnapshotOptions(styleURL: theme.styleURL, camera: camera, size: cell.themeImageView.bounds.size)
        snapshotOptions.zoomLevel = 12.5
        let snapshotter = MGLMapSnapshotter(options: snapshotOptions)
        
        snapshotter.start { (snapshot, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            guard let snapshot = snapshot else { return }

            cell.themeImageView.image = snapshot.image
        }

        cell.snapshotter = snapshotter
        cell.themeMarkerImageView.image = theme.defaultMarker
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ThemeViewController()
        vc.viewControllerTheme = MBXTheme.themes[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
