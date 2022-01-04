//
//  GoogleBook.swift
//  My Google Library
//
//  Created by Elena Moga on 2021-12-17.
//  Copyright © 2021 Elena Narcisa Moga. All rights reserved.
//
import UIKit

protocol GoogleBook {
    var bookDetails: VolumeData { get }
    var storedCover: UIImage? { get }
    func loadCover(completion: @escaping (_ coverImage: UIImage?) -> Void)
}
class StoreBookImage: GoogleBook {
    let bookDetails: VolumeData
    var storedCover: UIImage?
    init(bookInformation: VolumeData) {
        self.bookDetails = bookInformation
        self.storedCover = nil
    }
    func loadCover(completion: @escaping (_ coverImage: UIImage?) -> Void) {
        if let coverThumbnail = self.storedCover {
            completion(coverThumbnail)
        } else {
            if let coverThumbnailAddress = bookDetails.coverURL {
                GoogleBooksNetworkClient.client.loadBookCover(coverUrl: coverThumbnailAddress, completionHandler: { (data) in
                    guard let pictureData = data else {
                        completion(nil)
                        return
                    }
                    self.storedCover = UIImage(data: pictureData)
                    completion(self.storedCover)
                })
            } else {
                completion(nil)
            }
        }
    }
}
class CollectionOfBooks {
    var volumes = [GoogleBook]()
    static let instance = CollectionOfBooks()
    private init() {}
}

struct VolumeData {
    let title: String
    let authors: String
    let publisher: String?
    let publishedDate: PublishedDate?
    let pages: Int?
    let language: String?
    let isbn: String?
    let coverURL: String?
    
    static func convertToVolumeData(json: [String:AnyObject]) -> VolumeData? {
            guard let title = json[JsonResponseKeys.Title] as? String else {
                return nil
            }
            let authorsList = json[JsonResponseKeys.Authors] as? [String] ?? []
            let authors = authorsList.joined(separator: ", ")
            let publisher = json[JsonResponseKeys.Publisher] as? String
            let publishedDate = PublishedDate.convertStringToDate(dateAsString: json[JsonResponseKeys.PublishedDate] as? String)
            let pageCount = json[JsonResponseKeys.PageCount] as? Int
            let language = json[JsonResponseKeys.Language] as? String
            var isbn: String?
            if let industryIdentifiers = json[JsonResponseKeys.IndustryIdentifiers] as? [[String:AnyObject]] {
                for industryIdentifier in industryIdentifiers {
                    if let type = industryIdentifier[JsonResponseKeys.IndustryIdentifierType] as? String, let identifier = industryIdentifier[JsonResponseKeys.Identifier] as? String {
                        if type == JsonResponseValues.ISBN13 {
                            isbn = identifier
                            break
                        }
                        if type == JsonResponseValues.ISBN10 {
                            isbn = identifier
                        }
                    }
                }
            }
            var frontPageLink: String? = nil
            if let imageLinks = json[JsonResponseKeys.ImageLinks] as? [String:AnyObject], let imageURL =  imageLinks[JsonResponseKeys.SmallThumbnailURL] as? String {
                frontPageLink = convertUrl(url: imageURL)
            }
            return VolumeData(title: title, authors: authors, publisher: publisher, publishedDate: publishedDate, pages: pageCount, language: language, isbn: isbn, coverURL: frontPageLink)
        }
    }
func buildGoogleBooks(_ searchResult: [[String:AnyObject]]) -> [GoogleBook] {
    var googleBooks = [GoogleBook]()
    for element in searchResult {
        guard let volumeInfo = element[JsonResponseKeys.VolumeInfo] as? [String:AnyObject] else {
            return []
        }
        if let volumeData = VolumeData.convertToVolumeData(json: volumeInfo) {
            googleBooks.append(StoreBookImage(bookInformation: volumeData))
        }
    }
    return googleBooks
}
func convertUrl(url: String) -> String {
    return url.replacingOccurrences(of: "http://", with: "https://")
}
struct PublishedDate: CustomStringConvertible {
    var date: Date
    var dateFormat: DateFormat
    enum DateFormat: String {
        case Year = "yyyy"
        case YearMonth = "yyyy-MM"
        case YearMonthDay = "yyyy-MM-dd"
        static let fullDate = [Year, YearMonth, YearMonthDay]
    }
    var description: String {
        let dateFormatter = DateFormatter()
        switch dateFormat {
        case .Year:
            dateFormatter.dateFormat = "yyyy"
        case .YearMonth:
            dateFormatter.dateFormat = "MMMM yyyy"
        case .YearMonthDay:
            dateFormatter.dateStyle = DateFormatter.Style.long
        }
        return dateFormatter.string(from: date)
    }
    static func convertStringToDate(dateAsString: String?) -> PublishedDate?{
        guard let dateAsString = dateAsString else {
            return nil
        }
        let dateFormatter = DateFormatter()
        for dateFormat in DateFormat.fullDate {
            dateFormatter.dateFormat = dateFormat.rawValue
            if let date = dateFormatter.date(from: dateAsString) {
                return PublishedDate(date: date, dateFormat: dateFormat)
            }
        }
        return nil
    }
}
