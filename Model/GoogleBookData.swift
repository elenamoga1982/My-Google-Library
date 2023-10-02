//
//  GoogleBookData.swift
//  My Google Library
//
//  Created by Elena Moga on 2021-12-20.
//  Copyright © 2021 Elena Narcisa Moga. All rights reserved.
//
import Foundation
import CoreData
import UIKit

public class GoogleBookData: NSManagedObject, GoogleBook {
    var bookDetails: VolumeData {
        return VolumeData(title: title, authors: authors, publisher: publisher, publishedDate: dateOfPublication, pages: pageCount, language: language, isbn: isbn, coverURL: coverURL)
    }
    var storedCover: UIImage? {
        return coverImage
    }
    func loadCover(completion: @escaping (_ coverImage: UIImage?) -> Void) {
        if let cover = coverImage {
            completion(cover)
        } else {
            if let coverUrl = coverURL {
                GoogleBooksNetworkClient.client.loadBookCover(coverUrl: coverUrl, completionHandler: { (data) in
                    guard let image = data else {
                        completion(nil)
                        return
                    }
                    DispatchQueue.main.async {
                        self.coverImage = UIImage(data: image)
                        ((try? self.managedObjectContext?.save()) as ()??)
                    }
                    completion(self.coverImage)
                })
            } else {
                completion(nil)
            }
        }
    }
    var dateOfPublication: PublishedDate? {
        guard let date = publishedDateAttr, let type = publishedDateTypeAttr else {
            return nil
        }
        guard let dateType = PublishedDate.DateFormat(rawValue: type) else {
            return nil
        }
        return PublishedDate(date: date, dateFormat: dateType)
    }
    var pageCount: Int? {
        return pagesAttr > 0 ? Int(pagesAttr) : nil
    }
    private func loadDate(dateOfPublication: PublishedDate) -> (date: Date, type: String) {
           return (dateOfPublication.date, dateOfPublication.dateFormat.rawValue)
       }
    convenience init(googleBook: GoogleBook, context: NSManagedObjectContext) {
        if let entity = NSEntityDescription.entity(forEntityName: "GoogleBook", in: context) {
            self.init(entity: entity, insertInto: context)
            title = googleBook.bookDetails.title
            authors = googleBook.bookDetails.authors
            publisher = googleBook.bookDetails.publisher
            if let publicationDate = googleBook.bookDetails.publishedDate {
                publishedDateAttr = loadDate(dateOfPublication: publicationDate).date
                publishedDateTypeAttr = loadDate(dateOfPublication: publicationDate).type
            }
            pagesAttr = Int16(googleBook.bookDetails.pages ?? 0)
            language = googleBook.bookDetails.language
            isbn = googleBook.bookDetails.isbn
            coverURL = googleBook.bookDetails.coverURL
            coverImage = googleBook.storedCover
        } else {
            fatalError("Could not retrieve entity")
        }
    }
    @nonobjc public class func fetchRequest() -> NSFetchRequest<GoogleBookData> {
        return NSFetchRequest<GoogleBookData>(entityName: "GoogleBook");
    }
    @NSManaged public var title: String
    @NSManaged public var authors: String
    @NSManaged public var publisher: String?
    @NSManaged public var publishedDateAttr: Date?
    @NSManaged public var publishedDateTypeAttr: String?
    @NSManaged public var pagesAttr: Int16
    @NSManaged public var language: String?
    @NSManaged public var isbn: String?
    @NSManaged public var coverURL: String?
    @NSManaged public var coverImage: UIImage?
}
