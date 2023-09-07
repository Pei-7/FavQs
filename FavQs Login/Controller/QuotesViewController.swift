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
    
    var fontIndex = 0
    var fontSize = 18.0
    
    @IBOutlet var buttons: [UIButton]!
    
    @IBOutlet var quoteView: UIView!
    
    
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
            print(quotes[index].body?.count)
            if quotes[index].body?.count ?? 0 > 400 {
                index += 1
            }
            
            DispatchQueue.main.async {
                self.loadingIndicator.stopAnimating()
                self.loadingIndicator.isHidden = true
                
                self.quoteBody.text = quotes[self.index].body
                self.quoteAuthor.text = quotes[self.index].author
                
                if quotes[self.index].userDetails?.favorite == true {
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
    
    @IBAction func logOut(_ sender: Any) {
        
        let alertController = UIAlertController(title: "Logout Confirmation", message: "This action will log you out of your account. Continue?", preferredStyle: .alert)
        
        let logOutAction = UIAlertAction(title: "Confirm", style: .default) { [weak self]_ in
            print("logging out!")
            let urlString = "https://favqs.com/api/session"
            var urlRequest = URLRequest(url: URL(string: urlString)!)
            urlRequest.httpMethod = "DELETE"
            urlRequest.setValue("Token token=\"6f0c8d1ee7b86faab07fd9ee369e3fdf\"", forHTTPHeaderField: "Authorization")
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.setValue(self?.userTokenHeader, forHTTPHeaderField: "User-Token")
            
            URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                
                if let data, let response = String(data: data, encoding: .utf8) {
                    print("logged out",response)
                }
            }.resume()
            
            if let controller = self?.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") {
                controller.modalPresentationStyle = .fullScreen
                self?.present(controller, animated: false)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(logOutAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    
    
    @IBAction func share(_ sender: Any) {
        
        for button in buttons {
            button.isHidden = true
        }
        
        let renderer = UIGraphicsImageRenderer(size: quoteView.bounds.size)
        let image = renderer.image { context in
            quoteView.drawHierarchy(in: quoteView.bounds, afterScreenUpdates: true)
        }
        let controller = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(controller, animated: true)
        
        for button in buttons {
            button.isHidden = false
        }
        
    }
    
    
    @IBAction func changeFont(_ sender: UISwipeGestureRecognizer) {
        print("swiped")
        
        let fontNames = ["Helvetica","American Typewriter","Bradley Hand","Gill Sans","Kailasa","Marker Felt","Snell Roundhand"]
        
        if sender.direction == .left {
            fontIndex = (fontIndex + 1) % fontNames.count
        } else if sender.direction == .right {
            fontIndex = (fontIndex + fontNames.count - 1) % fontNames.count
        } else if sender.direction == .up {
            fontSize += 2.0
        } else if sender.direction == .down {
            fontSize -= 2.0
        }
        
        fontSize = max(12.0, min(36.0, fontSize))
        
        let fontName = fontNames[fontIndex]
        let font = UIFont(name: fontName, size: fontSize)
        quoteBody.font = font
        quoteAuthor.font = font
        
        
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
