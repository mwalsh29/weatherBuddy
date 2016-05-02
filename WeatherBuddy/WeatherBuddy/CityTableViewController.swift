//
//  CityTableViewController.swift
//  WeatherBuddy
//
//  Created by Katie Kuenster on 4/3/16.
//  Copyright © 2016 Katie Kuenster. All rights reserved.
//

import UIKit
import CoreLocation

// global variables to keep track of favorite cities and settings
var cities = FavoriteCities()
var settings = Settings()


class CityTableViewController: UITableViewController, CLLocationManagerDelegate {
    //var cities = FavoriteCities()
    let defaults = NSUserDefaults.standardUserDefaults()
    //var cities = FavoriteCities()
    var city1=[City]()
    //var cities = [City]()
    let locManager = CLLocationManager()
    let ows = OpenWeatherService()
    let tbc = TabBarController()
    
    var canRefresh = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("city table view did load")
        // https://www.andrewcbancroft.com/2015/03/17/basics-of-pull-to-refresh-for-swift-developers/#table-view-controller
        
        self.refreshControl?.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        
        locManager.delegate = self
        locManager.requestWhenInUseAuthorization()
        locManager.startUpdatingLocation()
        
        tableView.separatorStyle = .None
        self.tableView.backgroundColor = UIColor.whiteColor()

   
            self.tableView.backgroundColor = UIColor.init(red: 214/255, green: 238/255, blue: 255/255, alpha: 1.0)
    
        
        if (defaults.objectForKey("savedCityNames") == nil) {
            cities.addCity("", state: "", zip: "")
            cities.addCity("New York City", state: "NY", zip: "10001")
            cities.addCity("Chicago", state: "IL", zip: "60290")
            cities.addCity("Los Angeles", state: "CA", zip: "90001")
            cities.addCity("Gann Valley", state: "SD", zip: "57341")
            //print("no cities")
        } else {
            //cities = defaults.objectForKey("savedCities")! as! FavoriteCities
            let cityNames = defaults.objectForKey("savedCityNames") as! [String]
            let cityStates = defaults.objectForKey("savedCityStates") as! [String]
            let cityZips = defaults.objectForKey("savedCityZips") as! [String]
            
            var i:Int = 0
            while (i < cityNames.count) {
                cities.addCity(cityNames[i], state: cityStates[i], zip: cityZips[i])
                i += 1
            }
            
            //print("already cities")
        }
        
        
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        self.canRefresh = false
    
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            self.canRefresh = false
            var i:Int = 0
            self.city1.removeAll()
            while (i < cities.cityCount() ) {
                self.ows.cityWeatherByZipcode(cities.cityAtIndex(i)) {
                    (cities) in
                    self.city1.append(cities)
                    //print("name: \(cities.name)     temp: \(cities.zipcode)")
                    self.tableView.reloadData()
                }
                i += 1
            }
            self.canRefresh = true
        }
        
        cities.changeWeather(self.city1)
        canRefresh = true
        //defaults.setObject(cities, forKey: "savedCities")
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        if (canRefresh) {
            canRefresh = false
            print("refreshed:")
            cities.printCities()
            let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
            //dispatch_async(dispatch_get_global_queue(priority, 0)) {
                var i:Int = 0
                print("in dispatch_async:")
                cities.printCities()
                self.city1.removeAll()
                while (i < cities.cityCount() ) {
                    print("while:")
                    cities.printCities()
                    //print("callback: \(cities.cityAtIndex(i).name)")
                    self.ows.cityWeatherByZipcode(cities.cityAtIndex(i)) {
                        (city) in
                        self.city1.append(city)
                        self.tableView.reloadData()
                        //print("name: \(city.name)     temp: \(city.zipcode)")
                        //self.tableView.reloadData()
                    }
                    i += 1
                }
            //}
            cities.changeWeather(self.city1)
            canRefresh = true
            self.tableView.reloadData()
            print("end of refresh")
            cities.printCities()
            refreshControl.endRefreshing()
        }
        else {
            refreshControl.endRefreshing()
        }

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController!.navigationBar.topItem!.title = "WeatherBuddy"
        tableView.reloadData() // comment if doing async call
        
        //print("viewWillAppear")
        
        /*
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        self.canRefresh = false
        
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            self.canRefresh = false
            var i:Int = 0
            self.city1.removeAll()
            while (i < cities.cityCount() ) {
                self.ows.cityWeatherByZipcode(cities.cityAtIndex(i)) {
                    (cities) in
                    self.city1.append(cities)
                    //print("name: \(cities.name)     temp: \(cities.zipcode)")
                    self.tableView.reloadData()
                }
                i += 1
            }
            self.canRefresh = true
        }
        */
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities.cityCount()
    }

 
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
       
        let cell = tableView.dequeueReusableCellWithIdentifier("cityCell", forIndexPath: indexPath)

        if let cityCell = cell as? CityTableViewCell {
            cityCell.nameLabel.text = cities.cityAtIndex(indexPath.row).name
            if (cities.cityAtIndex(indexPath.row).description == "Clouds" || cities.cityAtIndex(indexPath.row).description == "Rain") {
                cityCell.gradientView.clouds = 1
                cityCell.gradientView.setNeedsDisplay()
            }
            if (settings.units == .Kelvin) {
                cityCell.degreesLabel.text = "\(Int(cities.cityAtIndex(indexPath.row).currentTemp_K))\u{00B0}"
            }
            else if (settings.units == .Celsius) {
                cityCell.degreesLabel.text = "\(Int(cities.cityAtIndex(indexPath.row).currentTemp_C))\u{00B0}"
            }
            else {
                cityCell.degreesLabel.text = "\(Int(cities.cityAtIndex(indexPath.row).currentTemp_F))\u{00B0}"
            }
            
            cityCell.detailLabel.text = cities.cityAtIndex(indexPath.row).detail
            cityCell.iconImage.image = cities.cityAtIndex(indexPath.row).icon
            if (indexPath.row == 0) {
                cityCell.locationImage.image = UIImage(named: "Location")
            }
            cityCell.gradientView.leftToRight = (indexPath.row)%2
        }
        return cell
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let currentLocation = locations.last
        cities.cityAtIndex(0).updateUserLocation(currentLocation!)
        // Update weather at new current location
        var tempCity = [City]()
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            self.ows.cityWeatherByZipcode(cities.cityAtIndex(0)) {
                (cities) in
                tempCity.append(cities)
                //print("name: \(cities.name)     temp: \(cities.currentTemp_F)")
                //self.tableView.reloadData()
            }
        }
        
        cities.changeWeather(tempCity)
        self.tableView.reloadData()
        
        //locManager.stopUpdatingLocation() // stop looking at location
    }
    
    

    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        if indexPath.item != 0 {
            return true
        } else {
            return false
        }
    }
    

    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            print("before delete:")
            cities.printCities()
            cities.removeCityAtIndex(indexPath.item)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            print("after delete:")
            cities.printCities()
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

    
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        print("rearrange")
        cities.printCities()
        cities.rearrangeCities(fromIndexPath.row, toIndex: toIndexPath.row)
        print("after")
        cities.printCities()
    }
    

    
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        if indexPath.item != 0 {
            return true
        } else {
            return false
        }
    }



    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "detailSegue" {
            if let detailVC = segue.destinationViewController as? CityDetailViewController,
                indexPath = tableView.indexPathForSelectedRow {
                    detailVC.city = cities.cityAtIndex(indexPath.row)
            }
        }
        if segue.identifier == "addSegue" {
            if let addVC = segue.destinationViewController as? AddCityViewController {
                addVC.cities = cities
            }
        }
    }


}
