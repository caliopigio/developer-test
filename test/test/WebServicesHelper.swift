//
//  WebServicesHelper.swift
//  test
//
//  Created by Carlos Larrañaga on 10/13/20.
//

import Foundation

// MARK: WebServices

class WebServices {
    // endpoints
    
    static private let baseUrl = "http://hn.algolia.com/api/v1/search_by_date?query=ios"
    
    // get the most recent articles
    class func getArticles(_ completion: @escaping ([Article]) -> Void) {
        if let url = URL(string: baseUrl) {
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if  data != nil,
                    let model = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments),
                    let dictionary = model as? [String: Any],
                    let hits = dictionary["hits"] as? [[String: Any]]
                {
                    var articles: [Article] = []
                    
                    for hit in hits {
                        if let article = Article(dictionary: hit) {
                            articles.append(article)
                        }
                    }
                    
                    completion(articles)
                }
            }.resume()
        }
    }
}
