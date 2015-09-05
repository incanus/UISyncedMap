import UIKit
import Mapbox

class ViewController: UIViewController, MGLMapViewDelegate {

    var points = [CLLocationCoordinate2D]()
    var map: MGLMapView!
    var path: MGLPolyline!

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
        
        map.setVisibleCoordinates(&self.points, count: UInt(self.points.count), edgePadding: UIEdgeInsetsZero, animated: false)

        path = MGLPolyline(coordinates: &self.points, count: UInt(self.points.count))
        self.map.addAnnotation(path)

        view.addSubview({ [unowned self] in
            let slider = UISlider(frame: CGRect(x: 20, y: self.view.bounds.size.height - 70,
                width: self.view.bounds.size.width - 40, height: 40))
            slider.autoresizingMask = .FlexibleWidth
            slider.addTarget(self, action: "updateMapCenter:", forControlEvents: .ValueChanged)
            return slider
            }())
    }

    func updateMapCenter(slider: UISlider) {
        let start = Int(fminf(slider.value * Float(points.count), Float(points.count - 1)))
        var end: Int? = { [unowned self] in
            if start == self.points.count - 1 {
                return nil
            } else {
                return start + 1
            }
            }()

        map.removeAnnotations(map.annotations!.filter({ [unowned self] in
            return ($0 as! MGLPolyline) != self.path
        }))

        if end != nil {
            var segmentPoints = [ points[start], points[end!] ]
            map.addAnnotation(MGLPolyline(coordinates: &segmentPoints, count: UInt(segmentPoints.count)))
        }

        //map.setCenterCoordinate(points[start], zoomLevel: map.zoomLevel, animated: false)
    }

    func mapView(mapView: MGLMapView, lineWidthForPolylineAnnotation annotation: MGLPolyline) -> CGFloat {
        if annotation == path {
            return 4
        } else {
            return 10
        }
    }

    func mapView(mapView: MGLMapView, strokeColorForShapeAnnotation annotation: MGLShape) -> UIColor {
        if annotation == path {
            return UIColor.blueColor().colorWithAlphaComponent(0.5)
        } else {
            return UIColor.redColor()
        }
    }

}
