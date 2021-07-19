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

func saveImage(image: UIImage, fileNameWithoutExt: String) -> String? {
    guard let data = image.jpegData(compressionQuality: 1) ?? image.pngData() else {
        return nil
    }
    
    guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
        return nil
    }
    
    let fileNameWithExt: String = fileNameWithoutExt + "." + data.format
    
    let imageUrl = directory.appendingPathComponent(fileNameWithExt)
    print(imageUrl.absoluteString.count)
    do {
        try data.write(to: imageUrl)
        print("write: ", imageUrl, data)
        return data.format
    } catch {
        print(error.localizedDescription)
        return nil
    }
}

func saveImageToTempDir(image: UIImage, fileName: String) -> URL? {
    guard let data = image.jpegData(compressionQuality: 1) ?? image.pngData() else {
        return nil
    }
    
    guard let directory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
        return nil
    }
    
    let fileNameWithExt: String = "thumbnail_" + fileName
    
    let imageUrl = directory.appendingPathComponent(fileNameWithExt)
    print(imageUrl.absoluteString)
    do {
        try data.write(to: imageUrl)
        return imageUrl
    } catch {
        print(error.localizedDescription)
        return nil
    }
}

func getImageUrl(fileNameWithExt: String) -> URL? {
    guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else {
        return nil
    }
    
    return URL(fileURLWithPath: directory.absoluteString).appendingPathComponent(fileNameWithExt)
}

func getImage(fileNameWithExt: String) -> UIImage? {
    let imageUrl = getImageUrl(fileNameWithExt: fileNameWithExt)!
    let fileManager = FileManager.default
    if fileManager.fileExists(atPath: imageUrl.path) {
        return UIImage(contentsOfFile: imageUrl.path)
    } else {
        print("image not exist")
        return #imageLiteral(resourceName: "diffuser")
    }
}

func makeImageThumbnail(image: UIImage) -> UIImage? {
    guard let imageData = image.jpegData(compressionQuality: 1) ?? image.pngData() else {
        return nil
    }

    let options = [
        kCGImageSourceCreateThumbnailWithTransform: true,
        kCGImageSourceCreateThumbnailFromImageAlways: true,
        kCGImageSourceThumbnailMaxPixelSize: 100] as CFDictionary // Specify your desired size at kCGImageSourceThumbnailMaxPixelSize. I've specified 100 as per your question

    var thumbnail: UIImage?
    imageData.withUnsafeBytes { ptr in
       guard let bytes = ptr.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
          return
       }
       if let cfData = CFDataCreate(kCFAllocatorDefault, bytes, imageData.count){
          let source = CGImageSourceCreateWithData(cfData, nil)!
          let imageReference = CGImageSourceCreateThumbnailAtIndex(source, 0, options)!
          thumbnail = UIImage(cgImage: imageReference) // You get your thumbail here
       }
    }
    return thumbnail
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

extension String {
    func convertToValidFileName() -> String {
        let invalidFileNameChrRegex = "[^a-zA-Z0-9ㄱ-힣 ]"
        let fullRange = startIndex ..< endIndex
        let validName = replacingOccurrences(of: invalidFileNameChrRegex, with: "-", options: .regularExpression, range: fullRange)
        return validName
    }
}
