//
//  GoogleBooksNetworkClient.swift
//  My Google Library
//
//  Created by Elena Moga on 2021-12-17.
//  Copyright © 2021 Elena Narcisa Moga. All rights reserved.
//
import Foundation

enum BookSearchResult {
    case success
    case noRecords
    case error
}
class GoogleBooksNetworkClient {
    private var urlSession = URLSession.shared
    static let client = GoogleBooksNetworkClient()
    private init() {}
    func search(_ keyword: String, completionHandler: @escaping (BookSearchResult) -> Void) {
        let parameters = [
            UrlParameters.Query: keyword,
            UrlParameters.MaxResults: UrlParameterValues.MaxResultsvalue,
        ]
        let urlRequest = NSMutableURLRequest(url: buildUrlIncludingParams(parameters))
        urlSession.dataTask(with: urlRequest as URLRequest) { data, response, error in
            guard let jsonResult = self.getJsonResult(data: data, response: response, error: error) else {
                completionHandler(.error)
                return
            }
            guard let itemList = jsonResult[JsonResponseKeys.Items] as? [[String:AnyObject]] else {
                completionHandler(.noRecords)
                return
            }
            CollectionOfBooks.instance.volumes = buildGoogleBooks(itemList)
            completionHandler(.success)
        }.resume()
    }
    func loadBookCover(coverUrl: String, completionHandler: @escaping (_ imageData: Data?) -> Void) {
        guard let coverUrlObject = URL(string: coverUrl) else {
            completionHandler(nil)
            return
        }
        urlSession.dataTask(with: coverUrlObject) {data, _, _ in
            completionHandler(data)
        }.resume()
    }
    private func buildUrlIncludingParams(_ urlParams: [String:String]) -> URL {
        var urlComponents = URLComponents()
        urlComponents.scheme = UrlTokens.Scheme
        urlComponents.host = UrlTokens.Host
        urlComponents.path = UrlTokens.Path
        urlComponents.queryItems = [URLQueryItem]()
        for (key, value) in urlParams {
            let urlQueryItem = URLQueryItem(name: key, value: "\(value)")
            urlComponents.queryItems!.append(urlQueryItem)
        }
        return urlComponents.url!
    }
    private func serializeToJsonObject(_ data: Data?) -> AnyObject? {
        guard let data = data else {
            return nil
        }
        return try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
    }
    private func getJsonResult(data: Data?, response: URLResponse?, error: Error?) -> [String: AnyObject]? {
        guard error == nil else {
            return nil
        }
        guard let responseStatusCode = (response as? HTTPURLResponse)?.statusCode, responseStatusCode >= 200 && responseStatusCode <= 299 else {
            return nil
        }
        guard let jsonResult = serializeToJsonObject(data) as? [String: AnyObject] else {
            return nil
        }
        return jsonResult
    }
}

struct UrlTokens {
    static let Scheme = "https"
    static let Host = "www.googleapis.com"
    static let Path = "/books/v1/volumes"
}
struct UrlParameters {
    static let Query = "q"
    static let Key = "key"
    static let MaxResults = "maxResults"
}
struct UrlParameterValues {
    static let MaxResultsvalue = "25"
}
struct JsonResponseKeys {
    static let Title = "title"
    static let Authors = "authors"
    static let Items = "items"
    static let VolumeInfo = "volumeInfo"
    static let Publisher = "publisher"
    static let PublishedDate = "publishedDate"
    static let ImageLinks = "imageLinks"
    static let SmallThumbnailURL = "smallThumbnail"
    static let Language = "language"
    static let PageCount = "pageCount"
    static let Identifier = "identifier"
    static let IndustryIdentifiers = "industryIdentifiers"
    static let IndustryIdentifierType = "type"
}
struct JsonResponseValues {
    static let ISBN13 = "ISBN_13"
    static let ISBN10 = "ISBN_10"
}
