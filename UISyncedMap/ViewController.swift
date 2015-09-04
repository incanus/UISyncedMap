import UIKit
import Mapbox

class ViewController: UIViewController, MGLMapViewDelegate {

    var points = [CLLocationCoordinate2D]()
    var map: MGLMapView!

    override func viewDidLoad() {
        super.viewDidLoad()

        if let path = NSBundle.mainBundle().pathForResource("polyline", ofType: "geojson"),
           let geojson = NSData(contentsOfFile: path),
           let waypoints = NSJSONSerialization.JSONObjectWithData(geojson, options: nil, error: nil) as? NSDictionary,
           let features = waypoints["features"] as? [NSDictionary] {
            for feature in features {
                if let geometry = feature["geometry"] as? NSDictionary,
                   let coordinates = geometry["coordinates"] as? [[Double]] {
                    for coordinate in coordinates {
                        points.append(CLLocationCoordinate2D(latitude: coordinate[1], longitude: coordinate[0]))
                    }
                }
            }
        }

        map = MGLMapView(frame: view.bounds, styleURL: NSURL(string: "asset://styles/emerald-v8.json"))
        map.delegate = self
        map.userInteractionEnabled = false
        map.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        map.setCenterCoordinate(points[0], zoomLevel: 16, animated: false)
        view.addSubview(map)

        map.addAnnotation(MGLPolyline(coordinates: &points, count: UInt(points.count)))

        view.addSubview({ [unowned self] in
            let size: CGFloat = 40
            let dot = UIView(frame: CGRect(x: 0, y: 0, width: size, height: size))
            dot.backgroundColor = UIColor.redColor().colorWithAlphaComponent(0.5)
            dot.layer.cornerRadius = size / 2
            dot.layer.borderColor = UIColor.redColor().colorWithAlphaComponent(0.75).CGColor
            dot.layer.borderWidth = 2
            dot.center = self.view.center
            return dot
            }())

        view.addSubview({ [unowned self] in
            let slider = UISlider(frame: CGRect(x: 20, y: self.view.bounds.size.height - 70,
                width: self.view.bounds.size.width - 40, height: 40))
            slider.autoresizingMask = .FlexibleWidth
            slider.addTarget(self, action: "updateMapCenter:", forControlEvents: .ValueChanged)
            return slider
            }())
    }

    func updateMapCenter(slider: UISlider) {
        let index = fminf(slider.value * Float(points.count), Float(points.count - 1))
        map.setCenterCoordinate(points[Int(index)], zoomLevel: map.zoomLevel, animated: false)
    }

    func mapView(mapView: MGLMapView, lineWidthForPolylineAnnotation annotation: MGLPolyline) -> CGFloat {
        return 8
    }

    func mapView(mapView: MGLMapView, strokeColorForShapeAnnotation annotation: MGLShape) -> UIColor {
        return UIColor.blueColor().colorWithAlphaComponent(0.5)
    }

}
