//
//  Article.swift
//  test
//
//  Created by Carlos Larrañaga on 10/13/20.
//

import Foundation

//MARK: DateFormatter extension

extension DateFormatter {

    // returns a Date object from the given string witn 2 possible formats
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


// MARK: Article

class Article: NSObject, NSCoding {
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
    var storyUrl: URL?
    
    static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.doesRelativeDateFormatting = true
        
        return formatter
    } ()
    
    // path to store articles for offline use
    static let filePath: URL = {
        let path = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
        
        return path.appendingPathComponent("articles.data")
    } ()
    
    init?(dictionary: [String: Any]) {
        if let identifier = dictionary[Article.objectIdKey] as? String {
            // discard deleted articles
            if  let deleted = UserDefaults.standard.array(forKey: Article.deletedArticles) as? [String],
                deleted.contains(identifier)
            {
                return nil
            }
            
            self.identifier = identifier
        } else { // discard articles without id
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
            self.storyUrl = url
        }
    }
    
    required convenience init?(coder: NSCoder) {
        var dictionary: [String: Any] = [:]
        
        dictionary[Article.objectIdKey] = coder.decodeObject(forKey: Article.objectIdKey)
        dictionary[Article.titleKey] = coder.decodeObject(forKey: Article.titleKey)
        dictionary[Article.storyTitleKey] = coder.decodeObject(forKey: Article.storyTitleKey)
        dictionary[Article.authorKey] = coder.decodeObject(forKey: Article.authorKey)
        dictionary[Article.createdAtKey] = coder.decodeObject(forKey: Article.createdAtKey)
        dictionary[Article.storyUrlKey] = coder.decodeObject(forKey: Article.storyUrlKey)
        
        self.init(dictionary: dictionary)
    }
    
    func encode(with coder: NSCoder) {
        if let identifier = self.identifier {
            coder.encode(identifier, forKey: Article.objectIdKey)
        }
        
        if let title = self.title {
            coder.encode(title, forKey: Article.titleKey)
        }
        
        if let storyTitle = self.storyTitle {
            coder.encode(storyTitle, forKey: Article.storyTitleKey)
        }
        
        if let author = self.author {
            coder.encode(author, forKey: Article.authorKey)
        }
        
        if let createdAt = self.createdAt {
            coder.encode(createdAt, forKey: Article.createdAtKey)
        }
        
        if let storyUrl = self.storyUrl {
            coder.encode(storyUrl, forKey: Article.storyUrlKey)
        }
    }
}
