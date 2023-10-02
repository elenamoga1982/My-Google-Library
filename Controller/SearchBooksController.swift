//
//  SearchBooksController.swift
//  My Google Library
//
//  Created by Elena Moga on 2021-12-17.
//  Copyright © 2021 Elena Narcisa Moga. All rights reserved.
//
import UIKit

class SearchBooksController: UIViewController, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var displayResult: UITableView!
    @IBOutlet weak var searchDisplayResult: UITableView!
    @IBOutlet weak var noBooksFound: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        displayResult.register(UINib(nibName: "BookDetailCell", bundle: nil), forCellReuseIdentifier: "BookDetailCell")
        displayResult.estimatedRowHeight = 100;
        displayResult.rowHeight = UITableView.automaticDimension;
        searchBar.becomeFirstResponder()
        searchBar.delegate = self
        searchDisplayResult.isHidden = true
        activityIndicator.isHidden = true
        noBooksFound.isHidden = true
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchDisplayResult.isHidden = true
        activityIndicator.isHidden = false
        noBooksFound.isHidden = true
        activityIndicator.startAnimating()
        guard let bookText = searchBar.text else {
            fatalError("Please enter a book detail")
        }
        let keyword = bookText.replacingOccurrences(of: " ", with: "+")
        GoogleBooksNetworkClient.client.search(keyword) { (result) in
            DispatchQueue.main.async {
                self.activityIndicator.isHidden = true
            }
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.searchDisplayResult.isHidden = false
                    self.searchDisplayResult.reloadData()
                }
            case .noRecords:
                DispatchQueue.main.async {
                    self.noBooksFound.text = "No records found for \"\(bookText)\""
                    self.noBooksFound.isHidden = false
                }
            case .error:
                DispatchQueue.main.async {
                    let uiAlertController = UIAlertController(title: "Connection error", message: "Connection error occurred", preferredStyle: .alert)
                    let uiAlertAction = UIAlertAction(title: "Denied", style: .cancel, handler: nil)
                    uiAlertController.addAction(uiAlertAction)
                    self.present(uiAlertController, animated: true, completion: nil)
                }
            }
        }
    }
}
extension SearchBooksController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "BookDetailCell"
        let bookDetailCell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! BookDetailCell
        bookDetailCell.setCellProperties(googleBook: CollectionOfBooks.instance.volumes[indexPath.row])
        return bookDetailCell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CollectionOfBooks.instance.volumes.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let bookInfoController = storyboard?.instantiateViewController(withIdentifier: "BookInfoView") as! BookInfoController
        bookInfoController.googleBook = CollectionOfBooks.instance.volumes[indexPath.row]
        bookInfoController.canSaveBook = true
        navigationController?.pushViewController(bookInfoController, animated: true)
    }
}
