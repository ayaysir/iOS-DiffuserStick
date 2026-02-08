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
  guard let data = image.jpegData(compressionQuality: 0.95) else {
    return nil
  }
  
  guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
    return nil
  }
  
  let fileNameWithExt: String = fileNameWithoutExt + "." + data.format
  
  let imageUrl = directory.appendingPathComponent(fileNameWithExt)

  do {
    try data.write(to: imageUrl)
    print(#function, "write: ", imageUrl, data)
    return data.format
  } catch {
    print(#function, error.localizedDescription)
    return nil
  }
}

func saveImageToAppSupportDir(image: UIImage, fileName: String) -> URL? {
  guard let data = image.jpegData(compressionQuality: 1) ?? image.pngData() else {
    return nil
  }

  guard let baseDirectory = FileManager.default
    .urls(for: .applicationSupportDirectory, in: .userDomainMask)
    .first else {
    return nil
  }

  let thumbsDirectory = baseDirectory.appendingPathComponent("thumbs", isDirectory: true)

  if !FileManager.default.fileExists(atPath: thumbsDirectory.path) {
    do {
      try FileManager.default.createDirectory(
        at: thumbsDirectory,
        withIntermediateDirectories: true
      )
    } catch {
      print(#function, "createDirectory Error:", error.localizedDescription)
      return nil
    }
  }

  let fileNameWithExt = "thumbnail_" + fileName
  let imageUrl = thumbsDirectory.appendingPathComponent(fileNameWithExt)

  do {
    try data.write(to: imageUrl)
    print(#function, "write:", imageUrl.path)
    return imageUrl
  } catch {
    print(#function, "Error:", error.localizedDescription)
    return nil
  }
}

func getImageUrl(fileNameWithExt: String) -> URL? {
  guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else {
    return nil
  }
  
  return directory.appendingPathComponent(fileNameWithExt)
}

func getImage(fileNameWithExt: String) -> UIImage? {
  let imageUrl = getImageUrl(fileNameWithExt: fileNameWithExt)!
  let fileManager = FileManager.default

  if fileManager.fileExists(atPath: imageUrl.path) {
    return UIImage(contentsOfFile: imageUrl.path)
  } else {
    print("image not exist:", imageUrl.path)
    return #imageLiteral(resourceName: "diffuser")
  }
}

func makeImageThumbnail(image: UIImage, maxPixelSize: CGFloat = 100) -> UIImage? {
  guard let imageData = image.jpegData(compressionQuality: 1) ?? image.pngData() else {
    return nil
  }
  
  let options = [
    kCGImageSourceCreateThumbnailWithTransform: true,
    kCGImageSourceCreateThumbnailFromImageAlways: true,
    kCGImageSourceThumbnailMaxPixelSize: maxPixelSize
  ] as CFDictionary // Specify your desired size at kCGImageSourceThumbnailMaxPixelSize. I've specified 100 as per your question
  
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

enum ImageFormat {
  case gif, jpg, png, webp, unknown
}

func removeFile(from url: URL) {
  do {
    try FileManager.default.removeItem(at: url)
  } catch {
    print(#function, error)
  }
}

func removeImageFileFromDocument(fileNameIncludesExtension: String) {
  let fileManager = FileManager.default
  let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
  let nsUserDomainMask = FileManager.SearchPathDomainMask.userDomainMask
  let paths = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
  
  guard let dirPath = paths.first else {
    return
  }
  
  let filePath = "\(dirPath)/\(fileNameIncludesExtension)"
  do {
    try fileManager.removeItem(atPath: filePath)
  } catch let error as NSError {
    print(error.debugDescription)
  }
}

extension String {
  func contains(_ string: String) -> Bool {
    return range(of: string, options: [.literal, .caseInsensitive, .diacriticInsensitive]) != nil
  }
  
  // Checks if every element in `strings` is contained.
  func contains(_ strings: [String]) -> Bool {
    guard strings.count > 0 else {
      return false
    }
    var allContained = true
    for string in strings {
      allContained = allContained && contains(string)
    }
    return allContained
  }
  
  func convertToValidFileName() -> String {
    let invalidFileNameChrRegex = "[^a-zA-Z0-9ㄱ-힣 ]"
    let fullRange = startIndex ..< endIndex
    let validName = replacingOccurrences(of: invalidFileNameChrRegex, with: "-", options: .regularExpression, range: fullRange)
    return validName
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
  
  func imageFormat() -> ImageFormat {
    if let string = String(data: self, encoding: .isoLatin1) {
      let prefix = String(string.prefix(30))
      if
        prefix.contains("ÿØÿÛ") ||
          prefix.contains(["ÿØÿà", "JFIF"]) ||
          prefix.contains(["ÿØÿá", "Exif"])
      {
        return .jpg
      } else if prefix.contains("PNG") {
        return .png
      } else if
        prefix.contains("GIF87a") ||
          prefix.contains("GIF89a")
      {
        return .gif
      } else if prefix.contains(["RIFF", "WEBP"]) {
        return .webp
      } else {
        print ("prefix \(prefix) is unknown")
        return .unknown
      }
    }
    return .unknown
  }
}

extension UIImage {
  func toData (options: NSDictionary, type: CFString) -> Data? {
    guard let cgImage = cgImage else { return nil }
    return autoreleasepool { () -> Data? in
      let data = NSMutableData()
      guard let imageDestination = CGImageDestinationCreateWithData(data as CFMutableData, type, 1, nil) else { return nil }
      CGImageDestinationAddImage(imageDestination, cgImage, options)
      CGImageDestinationFinalize(imageDestination)
      return data as Data
    }
  }
}
