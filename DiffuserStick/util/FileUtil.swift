//
//  FileUtil.swift
//  DiffuserStick
//
//  Created by yoonbumtae on 2021/07/15.
//

import UIKit
import ImageIO

struct ImageHeaderData{
    static var PNG: [UInt8] = [0x89]
    static var JPEG: [UInt8] = [0xFF]
    static var GIF: [UInt8] = [0x47]
    static var TIFF_01: [UInt8] = [0x49]
    static var TIFF_02: [UInt8] = [0x4D]
}

func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let documentsDirectory = paths[0]
    return documentsDirectory
}

func saveImage(image: UIImage, fileName: String) -> Bool {
    
    guard let data = image.jpegData(compressionQuality: 1) ?? image.pngData() else {
        return false
    }
    
    guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else {
        return false
    }
    
    do {
        try data.write(to: directory.appendingPathComponent(fileName + "." + data.format))
        return true
    } catch {
        print(error.localizedDescription)
        return false
    }
}

func getImage(fileName: String) -> UIImage? {
    // 이미지 표시
    guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else {
        return #imageLiteral(resourceName: "diffuser")
    }
    
    let imageUrl = URL(fileURLWithPath: directory.absoluteString).appendingPathComponent(fileName + ".jpg")
    let fileManager = FileManager.default
    if fileManager.fileExists(atPath: imageUrl.path) {
        return UIImage(contentsOfFile: imageUrl.path)
    } else {
        return #imageLiteral(resourceName: "diffuser")
    }
}

extension Data {
    var format: String {
        let array = [UInt8](self)
        let ext: String
        switch (array[0]) {
        case 0xFF:
            ext = "jpg"
        case 0x89:
            ext = "png"
        case 0x47:
            ext = "gif"
        case 0x49, 0x4D :
            ext = "tiff"
        default:
            ext = "unknown"
        }
        return ext
    }
}
