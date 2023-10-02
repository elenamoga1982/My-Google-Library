//
//  ImageAndTitleCell.swift
//  My Google Library
//
//  Created by Elena Moga on 2021-12-27.
//  Copyright © 2021 Elena Narcisa Moga. All rights reserved.
//
import UIKit

class ImageAndTitleCell: UITableViewCell {
    @IBOutlet weak var bookImage: UIImageView!
    @IBOutlet weak var bookTitle: UILabel!
    
    func configureCell(book: GoogleBook) {
        book.loadCover { (coverImage) in
            if let coverImage = coverImage {
                DispatchQueue.main.async {
                    self.bookImage.image = coverImage
                }
            }
        }
        bookTitle.text = book.bookDetails.title
    }
}
