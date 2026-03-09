//
//  AlertUtil.swift
//  DiffuserStick
//
//  Created by yoonbumtae on 2021/07/15.
//

import UIKit

private let CAUTION = "loc.alert.caution".localized
private let YES = "loc.alert.yes".localized
private let NO = "loc.alert.no".localized
private let OK = "loc.alert.ok".localized
private let CANCEL = "loc.common.cancel".localized

func simpleAlert(_ controller: UIViewController, message: String) {
  let alertController = UIAlertController(title: CAUTION, message: message, preferredStyle: .alert)
  let alertAction = UIAlertAction(title: OK, style: .default, handler: nil)
  alertController.addAction(alertAction)
  controller.present(alertController, animated: true, completion: nil)
}

func simpleAlert(_ controller: UIViewController, message: String, title: String, handler: ((UIAlertAction) -> Void)?) {
  let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
  let alertAction = UIAlertAction(title: OK, style: .default, handler: handler)
  alertController.addAction(alertAction)
  controller.present(alertController, animated: true, completion: nil)
}

func simpleConfirmAlert(
  _ controller: UIViewController,
  message: String,
  title: String,
  cancelText: String = CANCEL,
  okText: String = OK,
  okHandler: ((UIAlertAction) -> Void)?
) {
  let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
  let alertActionNo = UIAlertAction(title: cancelText, style: .cancel, handler: nil)
  let alertActionYes = UIAlertAction(title: okText, style: .default, handler: okHandler)
  alertController.addAction(alertActionNo)
  alertController.addAction(alertActionYes)
  controller.present(alertController, animated: true, completion: nil)
}

func simpleDestructiveYesAndNo(_ controller: UIViewController, message: String, title: String, yesHandler: ((UIAlertAction) -> Void)?) {
  let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
  let alertActionNo = UIAlertAction(title: NO, style: .cancel, handler: nil)
  let alertActionYes = UIAlertAction(title: YES, style: .destructive, handler: yesHandler)
  alertController.addAction(alertActionNo)
  alertController.addAction(alertActionYes)
  controller.present(alertController, animated: true, completion: nil)
}


