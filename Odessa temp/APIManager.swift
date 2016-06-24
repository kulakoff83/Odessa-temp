//
//  APIManager.swift
//  Odessa temp
//
//  Created by Dmitry Kulakov on 23.06.16.
//  Copyright © 2016 kulakoff. All rights reserved.
//

import Foundation
import UIKit

public class APIManager : NSObject {
    
    static let sharedInstance = APIManager()

    let apiUrl = "http://api.openweathermap.org/data/2.5/weather?q=Odessa&APPID=84021df1516d4be5c5e5a5827ea2c198&units=metric"
    let defaultSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    var dataTask: NSURLSessionDataTask?
    
    func getTemperatureData(success : (date : NSDate, value : NSNumber) -> Void, failure: (errorDescription : String) -> Void) {
        if dataTask != nil {
            dataTask?.cancel()
        }
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        dataTask = defaultSession.dataTaskWithURL(NSURL(string: apiUrl)!) {
            data, response, error in
            dispatch_async(dispatch_get_main_queue()) {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            }
            if let error = error {
                //print(error.localizedDescription)
                failure(errorDescription: error.localizedDescription)
            } else if let httpResponse = response as? NSHTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    self.getTemperatureAttributes(data, success: success, failure: failure)
                } else {
                    failure(errorDescription: "Http Error")
                }
            }
        }
        dataTask?.resume()
    }
    
    private func getTemperatureAttributes(data: NSData?, success : (date : NSDate, value : NSNumber) -> Void, failure: (errorDescription : String) -> Void) {
        do {
            if let data = data, response = try NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions(rawValue:0)) as? [String: AnyObject] {
                // Get the result dict
                if let tempDictonary: AnyObject = response["main"] {
                    let tempValue = tempDictonary["temp"] as! NSNumber
                    let date = NSDate()
                    success(date: date, value: tempValue)
                } else {
                    failure(errorDescription: "Results key not found in dictionary")
                }
            } else {
                failure(errorDescription: "JSON Error")
            }
        } catch let error as NSError {
            failure(errorDescription: "Error parsing results: \(error.localizedDescription)")
        }
    }
}

