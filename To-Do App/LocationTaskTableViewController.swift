//
//  LocationTaskTableViewController.swift
//  To-Do App
//
//  Created by Wismin Effendi on 8/24/17.
//  Copyright © 2017 Wismin Effendi. All rights reserved.
//

import UIKit
import CoreData
import os.log
import MGSwipeTableCell
import Mixpanel
import ToDoCoreDataCloudKit


class LocationTaskTableViewController: TaskTableViewController {
    
    var addBarButton: UIBarButtonItem!
    
    // MARK: - Properties
    override var cellIdentifier: String { return CellIdentifier.LocationTaskCell }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
        tabBarController?.navigationItem.title = NavBarTitle.TaskByLocation
        addBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(LocationTaskTableViewController.addNewTaskTapped))
        tabBarController?.navigationItem.rightBarButtonItem = addBarButton
        addBarButton.isEnabled = true
        
        // select the first navigationItem
        selectFirstItemIfExist(archivedView: false)
    }
    
    func selectFirstItemIfExist(archivedView: Bool) {
        if let split = self.splitViewController, split.viewControllers.count == 2 {
            let nc = split.viewControllers.last as! UINavigationController
            self.detailViewController = nc.topViewController as? TaskEditTableViewController
            
            self.delegate.isArchivedView = archivedView
            if let section = fetchedResultsController.sections,
                section.count > 0 {
                self.detailViewController.task = fetchedResultsController.object(at: IndexPath(item: 0, section: 0))
            } else {
                self.detailViewController.task = nil
            }
        }
    }

    override func initializeFetchResultsController() {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        fetchRequest.predicate = Predicates.TaskNotInArchivedAndNotPendingDeletion
        let locationTitleSort = NSSortDescriptor(key: #keyPath(Task.location.title), ascending: true, selector: #selector(NSString.localizedCompare(_:)))
        let dueDateSort = NSSortDescriptor(key: #keyPath(Task.dueDate), ascending: true)
        let titleSort = NSSortDescriptor(key: #keyPath(Task.title), ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))
        fetchRequest.sortDescriptors = [locationTitleSort, dueDateSort, titleSort]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                              managedObjectContext: coreDataStack.managedContext,
                                                              sectionNameKeyPath: #keyPath(Task.location.title),
                                                              cacheName: nil)
        
        fetchedResultsController.delegate = self
    }
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
    func addNewTaskTapped() {
        // save any pending edit on detail view
        self.coreDataStack.saveContext()
        
        if isFullVersion || withinFreeVersionLimit() {
            let childContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            childContext.parent = coreDataStack.managedContext
            self.detailViewController?.addTask(managedContext: childContext)
            
            if let detailViewController = self.detailViewController {
                splitViewController?.showDetailViewController(detailViewController.navigationController!, sender: nil)
            }
        } else {
            self.segueToInAppPurchase()
        }
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionInfo = fetchedResultsController.sections?[section]
        let headerText = "\(sectionInfo!.name)"
        return headerText
    }
    
    // Override row selection, we want to automatically save the editing / new task into coredata
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("We are in row selected")
        // save any pending edit on detail view
        self.coreDataStack.saveContext()
        
        let managedContext = coreDataStack.managedContext
        let selectedTask = fetchedResultsController.object(at: indexPath)
        self.delegate?.isArchivedView = false
        let childContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        childContext.parent = managedContext
        let childTask = childContext.object(with: selectedTask.objectID) as? Task
        self.delegate?.taskSelected(task: childTask, managedContext: childContext)
        
        if let detailViewController = self.delegate as? TaskEditTableViewController {
            splitViewController?.showDetailViewController(detailViewController.navigationController!, sender: nil)
        }
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            
            let taskToDelete = fetchedResultsController.object(at: indexPath)
            taskToDelete.setForLocalDeletion()
            coreDataStack.saveContext()
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
        
        selectFirstItemIfExist(archivedView: false)
    }

    
    // hide the Editing button when not in editing mode. Need longPress to initiate to editing Mode
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        if editing {
            tabBarController?.navigationItem.rightBarButtonItems = [editButtonItem, addBarButton]
            addBarButton.isEnabled = false
        }
        else {
            tabBarController?.navigationItem.rightBarButtonItems = [addBarButton]
            addBarButton.isEnabled = true
        }
    }
    
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        os_log("Source indexPath: %@", log: OSLog.default, type: OSLogType.debug, sourceIndexPath as CVarArg)
        os_log("Destination indexPath: %@", log: OSLog.default, type: OSLogType.debug, destinationIndexPath as CVarArg)
        
        guard sourceIndexPath != destinationIndexPath else { return }   // same, nothing to move
        
        // Need to stop live update during moving cells around
        self.fetchedResultsController.delegate = nil
        
        handleLocationCellMove(source: sourceIndexPath, destination: destinationIndexPath)
        
        // Now we could re-initiate fetchResultsController
        initializeFetchResultsController()
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
        }
        // reload tableView
        tableView.reloadData()
    }
    
    private func handleLocationCellMove(source: IndexPath, destination: IndexPath) {
        
        let lastRowIndex = fetchedResultsController.sections![destination.section].numberOfObjects - 1
        let taskObject: Task = fetchedResultsController.object(at: source)
        let movingLocation = destination.section != source.section
        
        // only need to find the row before and after destination.row if exist
        // then update the dueDate, save to coreData and let the fetchResultsController do it's work
        if destination.row >= lastRowIndex { // more to the last row
            let lastObjectInSection = fetchedResultsController.object(at: IndexPath(row: lastRowIndex,
                                                                                    section: destination.section))
            let dueDateRowBefore = lastObjectInSection.dueDate as Date
            let newDueDate = DateUtil.getDueDateAfterMove(dueDateRowBefore: dueDateRowBefore, dueDateRowAfter: nil)
            taskObject.dueDate = newDueDate as NSDate
            taskObject.needsUpload = true
            if movingLocation { taskObject.location = lastObjectInSection.location }
        } else if destination.row == 0 { // more to the first row
            let firstObjectInSection = fetchedResultsController.object(at: IndexPath(row: 0,
                                                                                     section: destination.section))
            let dueDateRowAfter = firstObjectInSection.dueDate as Date
            let newDueDate = DateUtil.getDueDateAfterMove(dueDateRowBefore: nil, dueDateRowAfter: dueDateRowAfter)
            taskObject.dueDate = newDueDate as NSDate
            taskObject.needsUpload = true
            if movingLocation { taskObject.location = firstObjectInSection.location }
        } else if source.row > destination.row { // move down
            let beforeObject = fetchedResultsController.object(at: IndexPath(row: destination.row,
                                                                             section: destination.section))
            let afterObject = fetchedResultsController.object(at: IndexPath(row: destination.row + 1,
                                                                            section: destination.section))
            let dueDateRowBefore = beforeObject.dueDate as Date
            let dueDateRowAfter = afterObject.dueDate as Date
            let newDueDate = DateUtil.getDueDateAfterMove(dueDateRowBefore: dueDateRowBefore, dueDateRowAfter: dueDateRowAfter)
            taskObject.dueDate = newDueDate as NSDate
            taskObject.needsUpload = true
            if movingLocation { taskObject.location = beforeObject.location }
        } else { // move up
            let beforeObject = fetchedResultsController.object(at: IndexPath(row: destination.row - 1,
                                                                             section: destination.section))
            let afterObject = fetchedResultsController.object(at: IndexPath(row: destination.row,
                                                                            section: destination.section))
            let dueDateRowBefore = beforeObject.dueDate as Date
            let dueDateRowAfter = afterObject.dueDate as Date
            let newDueDate = DateUtil.getDueDateAfterMove(dueDateRowBefore: dueDateRowBefore, dueDateRowAfter: dueDateRowAfter)
            taskObject.dueDate = newDueDate as NSDate
            taskObject.needsUpload = true 
            if movingLocation { taskObject.location = beforeObject.location }
        }
        
        do {
            try coreDataStack.managedContext.save()
        } catch {
            print(error)
        }
    }
}
