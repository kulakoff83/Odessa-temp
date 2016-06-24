//
//  ViewController.swift
//  Odessa temp
//
//  Created by Dmitry Kulakov on 23.06.16.
//  Copyright © 2016 kulakoff. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,NSFetchedResultsControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tempInfoLabel: UILabel!
    
    let cellIdentifire = "temperatureCell"
    var fetchedResultsController: NSFetchedResultsController?
    var currentTemperatureInfo : [String : AnyObject]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subscribeToNotifications()
        configureFetchResultController()
        configureTableView()
        //loadData()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func subscribeToNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.loadData), name: "UpdateDataNotification", object: nil)
    }
    
    //MARK: Data
    func loadData() {
        APIManager.sharedInstance.getTemperatureData({ (date, value) in
            let formatedDate = date.formattedDate()
            let formatedValue = String(format:"%.f", value.doubleValue)
            self.currentTemperatureInfo = ["date" : date, "value" : value]
            dispatch_async(dispatch_get_main_queue()) {
                self.tempInfoLabel.text = "\(formatedDate)\n t : \(formatedValue)°"
            }
            }) { (errorDescription) in
                dispatch_async(dispatch_get_main_queue()) {
                    let alert = UIAlertController(title: "Error", message: errorDescription, preferredStyle: UIAlertControllerStyle.Alert)
                    let okAction = UIAlertAction(title: "ОK", style: UIAlertActionStyle.Cancel, handler: nil)
                    alert.addAction(okAction)
                    self.presentViewController(alert, animated: true, completion: nil)
                }
        }
    }
    
    func saveCurrentData() {
        if let temperatureInfo = currentTemperatureInfo {
            let date = temperatureInfo["date"] as? NSDate
            let value = temperatureInfo["value"] as? NSNumber

            if let _ = CoreDataStack.sharedInstance.findTemperatureByDate(date!) {
                let alert = UIAlertController(title: "Error", message: "This temperature is already saved", preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction(title: "ОK", style: UIAlertActionStyle.Cancel, handler: nil)
                alert.addAction(okAction)
                self.presentViewController(alert, animated: true, completion: nil)
            } else {
                let temperature = CoreDataStack.sharedInstance.createTemperature()
                temperature.date = date
                temperature.value = value
            }
            CoreDataStack.sharedInstance.saveContext()
        } else {
            let alert = UIAlertController(title: "Error", message: "No Data From Save", preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title: "ОK", style: UIAlertActionStyle.Cancel, handler: nil)
            alert.addAction(okAction)
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    //MARK: Configure
    
    func configureFetchResultController() {
        fetchedResultsController = CoreDataStack.sharedInstance.fetchedResultsController
        fetchedResultsController?.delegate = self
        do {
            try self.fetchedResultsController!.performFetch()
        } catch {
            let fetchError = error as NSError
            print("\(fetchError), \(fetchError.userInfo)")
        }
    }
    
    func configureTableView() {
        tableView.registerNib(UINib(nibName: "TemperatureTableViewCell", bundle: nil), forCellReuseIdentifier: cellIdentifire)
        tableView.tableFooterView = UIView(frame: CGRectZero)
    }
    
    func configureCell(cell: TemperatureTableViewCell, atIndexPath indexPath: NSIndexPath) {
        // Fetch Record
        let record = fetchedResultsController!.objectAtIndexPath(indexPath)
        
        // Update Cell
        if let value = record.valueForKey("value") as? NSNumber {
            let formatedValue = String(format:"%.f", value.doubleValue)
            cell.valueLabel.text = "t : \(formatedValue)°"
        }
        
        if let date = record.valueForKey("date") as? NSDate {
            cell.dateLabel.text = "\(date.formattedDate())"
        }
    }
    
    //MARK: TableView DataSource    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifire, forIndexPath: indexPath) as!  TemperatureTableViewCell
        configureCell(cell, atIndexPath: indexPath)
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController!.sections {
            let sectionInfo = sections[section]
            return sectionInfo.numberOfObjects
        }
        
        return 0
    }
    
    // MARK: Fetched Results Controller Delegate Methods
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch (type) {
        case .Insert:
            if let indexPath = newIndexPath {
                tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            break;
        case .Delete:
            if let indexPath = indexPath {
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            break;
        case .Update:
            if let indexPath = indexPath {
                let cell = tableView.cellForRowAtIndexPath(indexPath) as! TemperatureTableViewCell
                configureCell(cell, atIndexPath: indexPath)
            }
            break;
        case .Move:
            if let indexPath = indexPath {
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            
            if let newIndexPath = newIndexPath {
                tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
            }
            break;
        }
    }
    
    //MARK: Actions
    
    @IBAction func reloadButtonPressed(sender: AnyObject) {
        loadData()
    }
    
    @IBAction func saveButtonPressed(sender: AnyObject) {
        saveCurrentData()
    }
}

