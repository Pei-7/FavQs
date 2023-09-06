//
//  QuotesViewController.swift
//  FavQs Login
//
//  Created by 陳佩琪 on 2023/9/5.
//

import UIKit

class QuotesViewController: UIViewController {
    
    var loginHeader: String!
    var userTokenHeader: String!
    
    @IBOutlet var quoteBody: UITextView!
    @IBOutlet var quoteAuthor: UILabel!
    var theQuoteBody = "quote"
    var theQuoteAuthor = "author"
    
    var quotes: [Quotes]?
    var index = 0
    
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet var bookmarkButton: UIButton!
    
    var backgroundIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingIndicator.startAnimating()
        print("quotesController",loginHeader,userTokenHeader)
        getQuote { quotes in
            self.quotes = quotes
            self.updateUI()
        }
    }
    
    
    func getQuote(completion: @escaping ([Quotes]?) -> Void) {
        let urlString = "https://favqs.com/api/quotes"
        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("Token token=\"6f0c8d1ee7b86faab07fd9ee369e3fdf\"", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        urlRequest.setValue(userTokenHeader, forHTTPHeaderField: "User-Token")
        
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            
            if let data, let response = String(data: data, encoding: .utf8) {
                let decoder = JSONDecoder()
                do {
                    let quote = try decoder.decode(Favqs.self, from: data)

                    completion(quote.quotes)
                    
                } catch {
                    print("decoder error",error)
                    completion(nil)
                }
                
            }
        }.resume()
    }
    
    fileprivate func updateText() {
        if let quotes {
            print(quotes[index].body.count)
            if quotes[index].body.count > 400 {
                index += 1
            }
            
            DispatchQueue.main.async {
                self.loadingIndicator.stopAnimating()
                self.loadingIndicator.isHidden = true
                
                self.quoteBody.text = quotes[self.index].body
                self.quoteAuthor.text = quotes[self.index].author
                
                if quotes[self.index].userDetails.favorite == true {
                    self.bookmarkButton.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)
                } else {
                    self.bookmarkButton.setImage(UIImage(systemName: "bookmark"), for: .normal)
                }
                
                
                self.index += 1
            }
        }
    }
    
    func updateUI() {
        if index < 24 {
            updateText()
        } else {
            getQuote { quotes in
                self.quotes = quotes
            }
            index = 0
            updateText()
        }
//        print(index)
    }

    @IBAction func shuffle(_ sender: Any) {
        updateUI()
    }
    
    @IBAction func markFavorite(_ sender: UIButton) {
        
        sender.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)
        if let quotes {
            let id = String(quotes[index-1].id)
            let urlString = "https://favqs.com/api/quotes/\(id)/fav"
            var urlRequest = URLRequest(url: URL(string: urlString)!)
            urlRequest.httpMethod = "PUT"
            urlRequest.setValue("Token token=\"6f0c8d1ee7b86faab07fd9ee369e3fdf\"", forHTTPHeaderField: "Authorization")
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.setValue(userTokenHeader, forHTTPHeaderField: "User-Token")
            URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                if let data, let response = String(data: data, encoding: .utf8) {
                    print(response)
                }
            }.resume()
            
            
        }
    }
    
    
    @IBSegueAction func showFavList(_ coder: NSCoder) -> FavQuotesTableViewController? {
        let controller = FavQuotesTableViewController(coder: coder)
        controller?.login = loginHeader
        controller?.userToken = userTokenHeader
        
        return controller
    }
    
    @IBAction func changeBackground(_ sender: Any) {
        backgroundIndex += 1
        
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
