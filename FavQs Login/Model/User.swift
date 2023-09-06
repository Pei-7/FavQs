//
//  Login.swift
//  FavQs Login
//
//  Created by 陳佩琪 on 2023/9/5.
//
//
import Foundation

struct User: Encodable {
    var user: SignIn
}

struct SignIn: Encodable {
    var login: String
    var email: String?
    var password: String
    
}
