//
//  BookInfoController.swift
//  My Google Library
//
//  Created by Elena Moga on 2021-12-19.
//  Copyright © 2021 Elena Narcisa Moga. All rights reserved.
//
import UIKit

class BookInfoController: UITableViewController {
    private let numberOfCells = 7
    var canSaveBook: Bool = false
    var coreDataHelper: CoreDataHelper {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.coreDataHelper
    }
    var googleBook: GoogleBook!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableView.automaticDimension;
        tableView.estimatedRowHeight = 50;
        if canSaveBook {
            navigationItem.rightBarButtonItem = makeRightNavigationBarButtonItem()
        }
    }
    @objc func saveBook(saveButton: UIBarButtonItem) {
        _ = GoogleBookData(googleBook: googleBook, context: coreDataHelper.objectContext)
        coreDataHelper.objectContextSave()
        _ = navigationController?.popViewController(animated: true)
    }
    private func makeRightNavigationBarButtonItem() -> UIBarButtonItem? {
        return UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.save, target: self, action: #selector(saveBook(saveButton:)))
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
           return nil
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfCells
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let uiTableViewCell: UITableViewCell
        if indexPath.row == 0 {
            let imageAndTitleCell = tableView.dequeueReusableCell(withIdentifier: "ImageAndTitleCell", for: indexPath) as! ImageAndTitleCell
            imageAndTitleCell.configureCell(book: googleBook)
            uiTableViewCell = imageAndTitleCell
        } else {
            let bookInfoCell = tableView.dequeueReusableCell(withIdentifier: "BookInfoCell", for: indexPath) as! BookInfoCell
            bookInfoCell.setCellProperties(book: googleBook, index: indexPath.row)
            uiTableViewCell = bookInfoCell
        }
        uiTableViewCell.selectionStyle = .none
        return uiTableViewCell
    }
}
