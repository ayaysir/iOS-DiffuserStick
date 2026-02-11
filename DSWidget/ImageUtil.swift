//
//  ImageUtil.swift
//  DiffuserStick
//
//  Created by 윤범태 on 2/12/26.
//

import UIKit

func getImageFromAppGroupDir(diffuserId: UUID) -> UIImage? {
  guard let imageURL = FileManager.default
    .containerURL(forSecurityApplicationGroupIdentifier: .shdAppGroupIdentifier)?
    .appendingPathComponent("thumbs/\(diffuserId.uuidString).jpg") else {
    return nil
  }

  // let fileManager = FileManager.default
  // print(imageURL.path)
  return UIImage(contentsOfFile: imageURL.path)
}
