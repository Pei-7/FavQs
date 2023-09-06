//
//  LoginViewController.swift
//  FavQs Login
//
//  Created by 陳佩琪 on 2023/9/5.
//

import UIKit

class LoginViewController: UIViewController {

    
    @IBOutlet var signInOrUP: UISegmentedControl!
    
    @IBOutlet var signUpView: UIView!
    
    @IBOutlet var userNameLabel: UITextField!
    @IBOutlet var emailLabel: UITextField!
    @IBOutlet var passwordLabel: UITextField!
    
    var user: User?
    
    var message: String?

    
    @IBOutlet var signinView: UIView!
    
    @IBOutlet var signInNameLabel: UITextField!
    @IBOutlet var signInPasswordLabel: UITextField!
    
    let signUpURL = "https://favqs.com/api/users"
    let signInURL = "https://favqs.com/api/session"
    var targetURL : String?
    
    //for segue
    var userToken: String?
    var login: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    
    func updateUser() {
        
        let session = UserSession(rawValue: signInOrUP.selectedSegmentIndex)
        switch session {
        case .signUp:
            if let userName = userNameLabel.text,
                let email = emailLabel.text,
                let password = passwordLabel.text {
                let info = SignIn(login: userName, email: email, password: password)
                user = User(user: info)
            }
        case .signIn:
            if let userID = signInNameLabel.text,
              let password = signInPasswordLabel.text {
                let info = SignIn(login: userID, password: password)
                user = User(user: info)
            }
        case .none:
            print("none")
        }
    }
    
    func sendReuqest(completion: @escaping ([String]?)->Void) {

        if let url = URL(string: targetURL!) {
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            urlRequest.setValue("Token token=\"6f0c8d1ee7b86faab07fd9ee369e3fdf\"", forHTTPHeaderField: "Authorization")
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let encoder = JSONEncoder()
            do {
                let data = try encoder.encode(user)
                urlRequest.httpBody = data
                print("* update content:",String(data: urlRequest.httpBody!, encoding: .utf8) ?? "post error")
            } catch {
                print(error)
            }
            
            URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("* HTTP Status Code: \(httpResponse.statusCode)")
                }
                
                if let data,
                   let response = String(data: data, encoding: .utf8) {
                    print("0",response)
                    let decoder = JSONDecoder()
                    do {
                        let item = try decoder.decode(Response.self, from: data)
                        if let message = item.message {
                            print("0000",item)
                            self.message = message
                            completion([message])
                        } else if let login = item.login, let userToken = item.userToken {
                            print("1111",item)
                            self.login = login
                            self.userToken = userToken
                            completion([login,userToken])
                        } else {
                            completion(nil)
                        }
                    } catch {
                        print(error)
                    }
                    
                } else if let error {
                    print("1",error)
                }
            }.resume()
            
        }

    }

    
    func showAlertOrSegue() {
        if let message {
            let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Return", style: .default))
            present(alert, animated: true)
        } else if let login, let userToken {
            guard let controller = storyboard?.instantiateViewController(withIdentifier: "\(QuotesViewController.self)") as? QuotesViewController else {return}
            controller.modalPresentationStyle = .fullScreen
            controller.loginHeader = login
            controller.userTokenHeader = userToken
            print("1111 ",login,userToken)
            present(controller, animated: true)
            
        }
        
        message = nil

    }

    
    @IBAction func signUp(_ sender: UIButton) {
        print(sender.tag)
        if sender.tag == 0 {
            targetURL = signUpURL
        } else {
            targetURL = signInURL
        }
        
        updateUser()
        sendReuqest { string in
            DispatchQueue.main.async {
                self.showAlertOrSegue()
            }
        }
        
    }
    
    
    @IBAction func switchUserSession(_ sender: UISegmentedControl) {
        let index = UserSession(rawValue: sender.selectedSegmentIndex)!
        switch index {
        case .signUp:
            signinView.isHidden = true
            signUpView.isHidden = false
        case .signIn:
            signinView.isHidden = false
            signUpView.isHidden = true

        }
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
