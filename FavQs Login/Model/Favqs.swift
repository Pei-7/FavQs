//
//  Quotes.swift
//  FavQs Login
//
//  Created by 陳佩琪 on 2023/9/6.
//

import Foundation

struct Favqs: Codable {
    var quotes: [Quotes]

}

struct Quotes: Codable {
    var id: Int
    var url: String?
    var author: String?
    var body: String?
    var userDetails: Details?
    
    enum CodingKeys: String, CodingKey {
        case id
        case url
        case author
        case body
        case userDetails = "user_details"
    }
}

struct Details: Codable {
    var favorite: Bool?
}
