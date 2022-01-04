//
//  BookDetailCell.swift
//  My Google Library
//
//  Created by Elena Moga on 2021-12-17.
//  Copyright © 2021 Elena Narcisa Moga. All rights reserved.
//
import UIKit

class BookDetailCell: UITableViewCell {
    @IBOutlet weak var bookCover: UIImageView!
    @IBOutlet weak var bookTitle: UILabel!
    @IBOutlet weak var bookAuthor: UILabel!
    
    func setCellProperties(googleBook: GoogleBook) {
        bookCover.image = nil
        googleBook.loadCover { [weak self] (coverImage) in
            if let coverImage = coverImage {
                DispatchQueue.main.async {
                    self?.bookCover?.image = coverImage
                }
            }
        }
        bookTitle.text = googleBook.bookDetails.title
        bookAuthor.text = googleBook.bookDetails.authors
    }
}
