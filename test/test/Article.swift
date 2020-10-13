//
//  Article.swift
//  test
//
//  Created by Carlos Larrañaga on 10/13/20.
//

import Foundation

extension DateFormatter {

    func dateFromJSONString(_ string: String) -> Date? {
        self.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        if let date = self.date(from: string) {
            return date
        } else {
            self.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            
            return self.date(from: string)
        }
    }
}

struct Article {
/*
 Dictionary.Keys(["url", "story_url", "num_comments", "points", "parent_id", "created_at_i", "_highlightResult", "created_at", "story_title", "title", "objectID", "story_id", "author", "comment_text", "story_text", "_tags"])
 */
    static let urlKey = "url"
    static let storyUrlKey = "story_url"
    static let numCommentsKey = "num_comments"
    static let pointsKey = "points"
    static let parentIdKey = "parent_id"
    static let createdAtIKey = "created_at_i"
    static let highlightResultKey = "_highlightResult"
    static let createdAtKey = "created_at"
    static let storyTitleKey = "story_title"
    static let titleKey = "title"
    static let objectIdKey = "objectID"
    static let storyIdKey = "story_id"
    static let authorKey = "author"
    static let commentTextKey = "comment_text"
    static let storyTextKey = "story_text"
    static let tagsKey = "_tags"
    
    static let deletedArticles = "deletedArticles"
    
    var identifier: String?
    var title: String?
    var storyTitle: String?
    var author: String?
    var createdAt: Date?
    var storyURL: URL?
    
    static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.doesRelativeDateFormatting = true
        
        return formatter
    } ()
    
    init?(dictionary: [String: Any]) {
        if let identifier = dictionary[Article.objectIdKey] as? String {
            if  let deleted = UserDefaults.standard.array(forKey: Article.deletedArticles) as? [String],
                deleted.contains(identifier)
            {
                return nil
            }
            
            self.identifier = identifier
        } else {
            return nil
        }
        
        if let storyTitle = dictionary[Article.storyTitleKey] as? String {
            self.storyTitle = storyTitle
        }
        
        if let title = dictionary[Article.titleKey] as? String {
            self.title = title
        }
        
        if let author = dictionary[Article.authorKey] as? String {
            self.author = author
        }
         
        if let createdAt = dictionary[Article.createdAtKey] as? String {
            self.createdAt = Article.formatter.dateFromJSONString(createdAt)
        }
        
        if  let storyUrl = dictionary[Article.storyUrlKey] as? String,
            let url = URL(string: storyUrl)
        {
            self.storyURL = url
        }
    }
}
