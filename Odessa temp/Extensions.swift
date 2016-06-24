//
//  Constants.swift
//  Odessa temp
//
//  Created by Dmitry Kulakov on 23.06.16.
//  Copyright © 2016 kulakoff. All rights reserved.
//

import Foundation

extension NSDate {
    
    func formattedDate() -> String {
        let formatter = NSDateFormatter();
        formatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        let defaultTimeZoneStr = formatter.stringFromDate(self)
        return defaultTimeZoneStr
    }
}