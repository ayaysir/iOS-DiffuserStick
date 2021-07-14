//
//  ParsePlist.swift
//  DiffuserStick
//
//  Created by yoonbumtae on 2021/07/14.
//

struct Root: Decodable {
    let animals: [Animal]
}

struct Animal: Decodable {
    let name, picture: String
}

import Foundation

func parsePlistExample() throws -> [Animal] {
    let url = Bundle.main.url(forResource: "testprops", withExtension: "plist")!
    do {
        let data = try Data(contentsOf: url)
        let result = try PropertyListDecoder().decode(Root.self, from: data)
        return result.animals as [Animal]
    } catch {
        throw error
    }
}
