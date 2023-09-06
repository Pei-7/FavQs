//
//  Response.swift
//  FavQs Login
//
//  Created by 陳佩琪 on 2023/9/5.
//

import Foundation

struct Response: Decodable {
    var userToken: String?
    var login: String?
    var errorCode: Int?
    var message: String?
    
    enum CodingKeys: String,CodingKey {
        case userToken = "User-Token"
        case login
        case errorCode = "error_code"
        case message
    }
}


