//
//  MapViewController.swift
//  WeatherBuddy
//
//  Created by Max Walsh on 4/6/16.
//  Copyright © 2016 Katie Kuenster. All rights reserved.
//

import UIKit
import MapKit


class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var i:Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // http://stackoverflow.com/questions/24467408/swift-add-mkannotationview-to-mkmapview
        //var i:Int = 0
        
        while i < cities.cityCount() {
            let city = cities.cityAtIndex(i)
            let tempPin = MKPointAnnotation()
            tempPin.coordinate = city.coordinates.coordinate
            tempPin.title = city.name
            self.mapView.addAnnotation(tempPin)
            let annotationTestView = MKAnnotationView()
            annotationTestView.annotation = tempPin
            //annotationTestView.image = UIImage(named: "Sun")
            annotationTestView.canShowCallout = true
            annotationTestView.enabled = true
            
            i += 1
            
            
        }
        i = 0
        /*
        let tempPin = MKPointAnnotation()
        tempPin.coordinate = cities.cityAtIndex(1).coordinates.coordinate
        
        tempPin.title = cities.cityAtIndex(1).name
        self.mapView.addAnnotation(tempPin)
        */
        
        /*
        let annotationTestView = MKAnnotationView()
        annotationTestView.annotation = testPin
        //annotationTestView.image = UIImage(named: "Sun")
        annotationTestView.canShowCallout = true
        annotationTestView.enabled = true
        */
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func mapView(mapview: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        // http://stackoverflow.com/questions/24467408/swift-add-mkannotationview-to-mkmapview
        
        if (annotation is MKUserLocation) {
            //if annotation is not an MKPointAnnotation (eg. MKUserLocation),
            //return nil so map draws default view for it (eg. blue dot)...
            return nil
        }

        
        let reuseId = "test"
        
        var anView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
        if anView == nil {
            anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            //let imgName = cities.cityAtIndex(i).icon
            //anView!.image = UIImage(named:imgName)
            anView!.image = cities.cityAtIndex(i).icon
            anView!.canShowCallout = true
        }
        else {
            //we are re-using a view, update its annotation reference...
            anView!.annotation = annotation
        }
        print("finished viewforannotation")
        i += 1
        return anView
   
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
