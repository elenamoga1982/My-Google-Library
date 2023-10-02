//
//  BookInfoCell.swift
//  My Google Library
//
//  Created by Elena Moga on 2021-12-21.
//  Copyright © 2021 Elena Narcisa Moga. All rights reserved.
//
import UIKit

class BookInfoCell: UITableViewCell {
    
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    
    private enum CellBody: Int {
        case Author = 1
        case Language = 2
        case Publisher = 3
        case PublishedDate = 4
        case ISBN = 5
        case PageCount = 6
    }
    
    func setCellProperties(book: GoogleBook, index: Int) {
        guard let cellBody = CellBody(rawValue: index) else {
            assertionFailure("Could not find cell")
            return
        }
        switch cellBody {
        case .Author:
            let authors = book.bookDetails.authors
            let subject = "Author".appending(authors.contains(", ") ? "s" : "")
            let body = authors.isEmpty ? nil : authors
            setCellProperties(subject: subject, body: body)
        case .Language:
            if let language = book.bookDetails.language {
                setCellProperties(subject: "Language", body: Locale.current.localizedString(forIdentifier: language))
            } else {
                setCellProperties(subject: "Language", body: nil)
            }
        case .Publisher:
            setCellProperties(subject: "Publisher", body: book.bookDetails.publisher)
        case .PublishedDate:
            configureCell(subject: "Publication Date", publishedDate: book.bookDetails.publishedDate)
        case .ISBN:
            setCellProperties(subject: "ISBN", body: book.bookDetails.isbn)
        case .PageCount:
            configureCell(subject: "Page Count", pageCount: book.bookDetails.pages)
        }
    }
    private func setCellProperties(subject: String, body: String?) {
        subjectLabel.text = subject
        bodyLabel.text = body ?? "No data available"
    }
    private func configureCell(subject: String, pageCount: Int?) {
        setCellProperties(subject: subject, body: pageCount?.description)
    }
    private func configureCell(subject: String, publishedDate: PublishedDate?) {
        setCellProperties(subject: subject, body: publishedDate?.description)
    }
}
