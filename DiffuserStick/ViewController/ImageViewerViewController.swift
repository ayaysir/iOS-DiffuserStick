//
//  ImageViewerViewController.swift
//  DiffuserStick
//
//  Created by 윤범태 on 2/9/26.
//

import UIKit

final class ImageViewerViewController: UIViewController {

  private let image: UIImage

  private let scrollView = UIScrollView()
  private let imageView = UIImageView()
  private let closeButton = UIButton(type: .system)

  init(image: UIImage) {
    self.image = image
    super.init(nibName: nil, bundle: nil)
    modalPresentationStyle = .fullScreen
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .black
    setupScrollView()
    setupImageView()
    setupCloseButton()
    setupGestures()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    scrollView.frame = view.bounds
    updateImageViewFrame()
  }

  // MARK: - Setup

  private func setupScrollView() {
    scrollView.minimumZoomScale = 1.0
    scrollView.maximumZoomScale = 3.0
    scrollView.delegate = self
    scrollView.showsHorizontalScrollIndicator = false
    scrollView.showsVerticalScrollIndicator = false
    view.addSubview(scrollView)
  }

  private func setupImageView() {
    imageView.image = image
    imageView.contentMode = .scaleAspectFit
    scrollView.addSubview(imageView)
  }

  private func setupCloseButton() {
    closeButton.setTitle("닫기", for: .normal)
    closeButton.tintColor = .white
    closeButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)

    closeButton.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(closeButton)

    NSLayoutConstraint.activate([
      closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
      closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
    ])
  }

  private func setupGestures() {
    let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
    doubleTap.numberOfTapsRequired = 2
    scrollView.addGestureRecognizer(doubleTap)
  }

  // MARK: - Layout

  private func updateImageViewFrame() {
    guard let image = imageView.image else { return }

    let viewSize = scrollView.bounds.size
    let imageRatio = image.size.width / image.size.height
    let viewRatio = viewSize.width / viewSize.height

    let imageSize: CGSize
    if imageRatio > viewRatio {
      imageSize = CGSize(
        width: viewSize.width,
        height: viewSize.width / imageRatio
      )
    } else {
      imageSize = CGSize(
        width: viewSize.height * imageRatio,
        height: viewSize.height
      )
    }

    imageView.frame = CGRect(
      origin: .zero,
      size: imageSize
    )

    scrollView.contentSize = imageSize

    let offsetX = max((viewSize.width - imageSize.width) / 2, 0)
    let offsetY = max((viewSize.height - imageSize.height) / 2, 0)
    imageView.center = CGPoint(
      x: imageSize.width / 2 + offsetX,
      y: imageSize.height / 2 + offsetY
    )
  }

  // MARK: - Actions

  @objc private func didTapClose() {
    dismiss(animated: true)
  }

  @objc private func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
    if scrollView.zoomScale > 1.0 {
      scrollView.setZoomScale(1.0, animated: true)
    } else {
      let location = gesture.location(in: imageView)
      let zoomRect = zoomRectForScale(scale: 2.5, center: location)
      scrollView.zoom(to: zoomRect, animated: true)
    }
  }

  private func zoomRectForScale(scale: CGFloat, center: CGPoint) -> CGRect {
    let size = CGSize(
      width: scrollView.bounds.width / scale,
      height: scrollView.bounds.height / scale
    )

    let origin = CGPoint(
      x: center.x - size.width / 2,
      y: center.y - size.height / 2
    )

    return CGRect(origin: origin, size: size)
  }
}

extension ImageViewerViewController: UIScrollViewDelegate {
  func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    return imageView
  }

  func scrollViewDidZoom(_ scrollView: UIScrollView) {
    let viewSize = scrollView.bounds.size
    let contentSize = scrollView.contentSize

    let offsetX = max((viewSize.width - contentSize.width) / 2, 0)
    let offsetY = max((viewSize.height - contentSize.height) / 2, 0)

    imageView.center = CGPoint(
      x: contentSize.width / 2 + offsetX,
      y: contentSize.height / 2 + offsetY
    )
  }
}
