//
//  NewsViewController.swift
//  test
//
//  Created by Carlos Larrañaga on 10/13/20.
//

import UIKit
import SafariServices

class NewsViewController: UITableViewController {
    
    var articles: [Article] = []
    
    static let relativeDateFormatter = RelativeDateTimeFormatter()
    
    // MARK: UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl?.addTarget(self, action: #selector(reloadData), for: .valueChanged)
        refreshControl?.beginRefreshing()
        reloadData()
        
        // get stored articles
        if  let archivedData = try? Data(contentsOf: Article.filePath),
            let object = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(archivedData) as? [Article]
        {
            articles = object
            
            tableView.reloadData()
        }
    }
    
    // MARK: NewsViewController
    
    @objc func reloadData() {
        refreshControl?.endRefreshing()
        
        WebServices.getArticles { (articles) in
            // there is new articles
            if articles.count > 0 {
                // store new articles
                if let data = try? NSKeyedArchiver.archivedData(withRootObject: articles, requiringSecureCoding: false) {
                    try? data.write(to: Article.filePath)
                }
                
                // show new articles
                self.articles = articles
                
                OperationQueue.main.addOperation {
                    self.tableView.reloadData()
                }
            }
        }
    }

    // MARK: UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let article = articles[indexPath.row]
        
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = article.storyTitle != nil ? article.storyTitle : article.title
        
        var detail = ""
        
        if let author = article.author {
            detail = author
        }
        
        if let createdAt = article.createdAt {
            Article.formatter.dateStyle = .medium
            detail += " - " + NewsViewController.relativeDateFormatter.localizedString(for: createdAt, relativeTo: Date())
        }
        
        cell.detailTextLabel?.numberOfLines = 0
        cell.detailTextLabel?.text = detail

        return cell
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let url = articles[indexPath.row].storyUrl {
            let config = SFSafariViewController.Configuration()
            //config.entersReaderIfAvailable = true
            
            let viewController = SFSafariViewController(url: url, configuration: config)
            present(viewController, animated: true)
        }
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let defaults = UserDefaults.standard
            
            // store deleted articles ids
            if var deleted = defaults.array(forKey: Article.deletedArticles) as? [String] {
                deleted.append(articles[indexPath.row].identifier!)
                
                defaults.setValue(deleted, forKey: Article.deletedArticles)
            } else {
                defaults.setValue([articles[indexPath.row].identifier!], forKey: Article.deletedArticles)
            }
            
            defaults.synchronize()
            
            //remove deleted articles
            articles.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        }    
    }
}
