//
//  FavQuotesTableViewController.swift
//  FavQs Login
//
//  Created by 陳佩琪 on 2023/9/6.
//

import UIKit

class FavQuotesTableViewController: UITableViewController {

    var login: String!
    var userToken: String!
    
    var totalCount = 1
    var quotes: [Quotes] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("favTable",login,userToken)
        getFavList()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    /*
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }
     */

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return quotes.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FaveListCell", for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = quotes[indexPath.row].body
        cell.detailTextLabel?.text = quotes[indexPath.row].author
        
        return cell
    }
    
    
    func getFavList() {
        if let login, let userToken  {
            print("0000")
            let urlString = "https://favqs.com/api/quotes/?filter=\(login)&type=user"
            var urlRequest = URLRequest(url: URL(string: urlString)!)
            urlRequest.httpMethod = "GET"
            urlRequest.setValue("Token token=\"6f0c8d1ee7b86faab07fd9ee369e3fdf\"", forHTTPHeaderField: "Authorization")
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.setValue(userToken, forHTTPHeaderField: "User-Token")
            
            URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                if let data {
                    let decoder = JSONDecoder()
                    do {
                        let item = try decoder.decode(Favqs.self, from: data)
                        self.quotes = item.quotes
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                        
                    } catch {
                        print("decoder error",error)
                    }
                }
            }.resume()
        }

    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
            
        let id = String(quotes[indexPath.row].id)
        let urlString = "https://favqs.com/api/quotes/\(id)/unfav"
        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.httpMethod = "PUT"
        urlRequest.setValue("Token token=\"6f0c8d1ee7b86faab07fd9ee369e3fdf\"", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(userToken, forHTTPHeaderField: "User-Token")
        
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let data, let response = String(data: data, encoding: .utf8) {
                print("response",response)
            }
        }.resume()
        
        getFavList()
        
    }
    
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
