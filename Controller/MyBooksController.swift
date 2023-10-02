//
//  MyBooksController.swift
//  My Google Library
//
//  Created by Elena Moga on 2021-12-19.
//  Copyright © 2021 Elena Narcisa Moga. All rights reserved.
//
import UIKit
import CoreData

class MyBooksController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sortBooks: UISegmentedControl!
    @IBAction func orderBooks(_ orderBooksAction: UISegmentedControl) {
        if orderBooksAction == sortBooks {
            UserDefaults.standard.set(orderBooksAction.selectedSegmentIndex, forKey: orderCriteria)
            googleBookOrder = orderBooksAction.selectedSegmentIndex
        }
    }
    fileprivate var uiSearchBar: UISearchBar!
    private let orderCriteria = "Order by"
    private let orderByAuthor = NSSortDescriptor(key: "authors", ascending: true)
    private let orderByTitle = NSSortDescriptor(key: "title", ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))
    fileprivate var coreDataHelper: CoreDataHelper {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.coreDataHelper
    }
    fileprivate var fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "GoogleBook")
    fileprivate var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>? {
        didSet {
            fetchedResultsController?.delegate = self
            if let fetchedResultsController = fetchedResultsController {
                try? fetchedResultsController.performFetch()
            }
            tableView.reloadData()
        }
    }
    private enum GoogleBookOrderType: Int {
        case Author = 0
        case Title = 1
    }
    fileprivate var googleBookOrder: Int! {
        didSet {
            guard let googleBookOrderType = GoogleBookOrderType(rawValue: googleBookOrder) else {
                assertionFailure("Could not find order type")
                return
            }
            switch googleBookOrderType {
            case .Author:
                fetchRequest.sortDescriptors = [orderByAuthor, orderByTitle]
                fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: coreDataHelper.objectContext, sectionNameKeyPath: #keyPath(GoogleBookData.authors), cacheName: nil)
            case .Title:
                fetchRequest.sortDescriptors = [orderByTitle]
                fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: coreDataHelper.objectContext, sectionNameKeyPath: #keyPath(GoogleBookData.title), cacheName: nil)
            }
        }
    }
    fileprivate var searchEnabled: Bool = false {
        didSet {
            sortBooks.isEnabled = !searchEnabled
            if searchEnabled {
                fetchRequest.sortDescriptors = [orderByTitle]
            } else {
                fetchRequest.predicate = nil
                googleBookOrder = sortBooks.selectedSegmentIndex
            }
        }
        
    }
    fileprivate var emptyList: Bool! {
        didSet {
            if emptyList {
                UIView.animate(withDuration: 0.3, animations: {
                    self.tableView.alpha = 0
                    self.sortBooks.alpha = 0
                })
            } else {
                tableView.alpha = 1
                sortBooks.alpha = 1
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchRequest.fetchBatchSize = 35
        sortBooks.selectedSegmentIndex = UserDefaults.standard.integer(forKey: orderCriteria)
        googleBookOrder = sortBooks.selectedSegmentIndex
        uiSearchBar = UISearchBar()
        uiSearchBar.delegate = self
        uiSearchBar.sizeToFit()
        
        tableView.register(UINib(nibName: "BookDetailCell", bundle: nil), forCellReuseIdentifier: "BookDetailCell")
        tableView.rowHeight = UITableView.automaticDimension;
        tableView.estimatedRowHeight = 90.0;
        tableView.tableHeaderView = uiSearchBar
        tableView.setContentOffset(CGPoint(x: 0, y: uiSearchBar.frame.height), animated: false)
    
        if !(tableView.visibleCells.count > 0) {
            tableView.alpha = 0
            sortBooks.alpha = 0
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        if let index = tableView.indexPathForSelectedRow{
            tableView.deselectRow(at: index, animated: true)
        }
    }
}

extension MyBooksController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let bookInfoController = storyboard?.instantiateViewController(withIdentifier: "BookInfoView") as! BookInfoController
        bookInfoController.googleBook = fetchedResultsController?.object(at: indexPath) as? GoogleBook
        navigationController?.pushViewController(bookInfoController, animated: true)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let objectSection = fetchedResultsController?.sections?[section] else { fatalError("Section not found") }
        return objectSection.numberOfObjects
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard !searchEnabled else { return nil }
        guard let objectSection = fetchedResultsController?.sections?[section] else { fatalError("Section not found") }
        return objectSection.name.isEmpty ? "Empty" : objectSection.name
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            coreDataHelper.objectContext.delete(fetchedResultsController?.object(at: indexPath) as! NSManagedObject)
            coreDataHelper.objectContextSave()
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let bookDetailCell = tableView.dequeueReusableCell(withIdentifier: "BookDetailCell", for: indexPath) as! BookDetailCell
        bookDetailCell.setCellProperties(googleBook: fetchedResultsController?.object(at: indexPath) as! GoogleBook)
        return bookDetailCell
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        guard !searchEnabled else { return 1 }
        guard let sections = fetchedResultsController?.sections else { return 0 }
        return sections.count
    }
}
extension MyBooksController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        emptyList = !searchEnabled && !(tableView.visibleCells.count > 0)
        tableView.endUpdates()
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
           switch(type) {
           case .insert:
               tableView.insertRows(at: [newIndexPath!], with: .fade)
           case .update:
               tableView.reloadRows(at: [indexPath!], with: .fade)
           case .delete:
               tableView.deleteRows(at: [indexPath!], with: .fade)
           default:
               assertionFailure("Type \(type) unknown")
           }
       }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        let indexSet = IndexSet(integer: sectionIndex)
        switch (type) {
        case .delete:
            tableView.deleteSections(indexSet, with: .fade)
        case .insert:
            tableView.insertSections(indexSet, with: .fade)
        default:
            assertionFailure("Type \(type) unknown")
        }
    }
}
extension MyBooksController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
           searchBar.setShowsCancelButton(true, animated: true)
       }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        tableView.setContentOffset(CGPoint(x: 0, y: searchBar.frame.height), animated: true)
        searchBar.setShowsCancelButton(false, animated: false)
        searchBar.resignFirstResponder()
        searchBar.text = nil
        searchEnabled = false
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchEnabled = true
        let predicate = NSPredicate(format: "(authors contains[c] $text) OR (isbn contains[c] $text) OR (title contains[c] $text)").withSubstitutionVariables(["text" : searchText])
        fetchRequest.predicate = searchText.isEmpty ? nil : predicate
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: coreDataHelper.objectContext, sectionNameKeyPath: nil, cacheName: nil)
    }
}
