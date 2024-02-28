//
//  ArchiveViewController.swift
//  DiffuserStick
//
//  Created by yoonbumtae on 2021/07/22.
//

import UIKit
import GoogleMobileAds

class SendToArchive {
    static let sharedInstance = SendToArchive()
    // List 탭에서 보관함으로 넘어온 경우 새로고침 필요
    var isNeedReloadCDData = false
}

class ArchiveViewController: UIViewController {
    
    // AdMob
    private var bannerView: GADBannerView!
    
    let archiveViewModel = DiffuserViewModel()
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var constraintBottom: NSLayoutConstraint!
    
    var currentSelectedDiffuser: DiffuserVO? = nil
    var currentArrayIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Core Data를 view model에 fetch
        do {
            archiveViewModel.diffuserInfoList = try readCoreData(isArchive: true)!
        } catch {
            print(error)
        }
        
        if Bundle.main.object(forInfoDictionaryKey: "ShowAd") as! Bool {
            setupBannerView()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("SAC: ", SendToArchive.sharedInstance.isNeedReloadCDData)
        if SendToArchive.sharedInstance.isNeedReloadCDData {
            do {
                archiveViewModel.diffuserInfoList = try readCoreData(isArchive: true)!
                collectionView.reloadData()
                SendToArchive.sharedInstance.isNeedReloadCDData = false
            } catch {
                print(error)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "archiveDetailView" {
            guard let detailViewController = segue.destination as? DiffuserDetailViewController else { return }
            detailViewController.selectedDiffuser = currentSelectedDiffuser
            detailViewController.currentArrayIndex = currentArrayIndex
            detailViewController.archiveDelegate = self
        }
    }
}

extension ArchiveViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if archiveViewModel.numOfDiffuserInfoList == 0 {
            collectionView.displayBackgroundMessage("""
            🫙 아카이브 리스트가 비어있어요.
            
            디퓨저 리스트에서 더 이상 사용하지
            않는 디퓨저가 있는 경우 [보관] 기능을
            이용하면 아카이브에 추가할 수 있어요!
            """)
        } else {
            collectionView.dismissBackgroundMessage()
        }
        
        return archiveViewModel.numOfDiffuserInfoList
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? ArchiveCell else {
            return UICollectionViewCell()
        }
        cell.update(info: archiveViewModel.getDiffuserInfo(at: indexPath.row))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currentSelectedDiffuser = archiveViewModel.getDiffuserInfo(at: indexPath.row)
        currentArrayIndex = indexPath.row
        performSegue(withIdentifier: "archiveDetailView", sender: nil)
    }
    
    // 사이즈 결정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let itemSpacing: CGFloat = 10
        let textAreaHeight: CGFloat = 65
        
        let width: CGFloat = (collectionView.bounds.width - itemSpacing) / 2
        let height: CGFloat = width * 10/7 + textAreaHeight
        return CGSize(width: width, height: height)
    }
}

class ArchiveCell: UICollectionViewCell {
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
        func update(info: DiffuserVO) {
            imgView.image = getImage(fileNameWithExt: info.photoName)
            nameLabel.text = info.title
            
            // 사이즈가 텍스트에 맞게 조절.
            
            // 텍스트에 맞게 조절된 사이즈를 가져와 height만 fit하게 값을 조절.
            let newSize = nameLabel.sizeThatFits( CGSize(width: nameLabel.frame.width, height: CGFloat.greatestFiniteMagnitude))
            nameLabel.frame.size.height = newSize.height
            
            imgView.layer.cornerRadius = 12
            imgView.clipsToBounds = true
        }
}

extension ArchiveViewController: ArchiveDetailViewDelegate {
    func deleteFromList(_ controller: DiffuserDetailViewController, diffuser: DiffuserVO, index: Int) {
        archiveViewModel.diffuserInfoList.remove(at: index)
        collectionView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            simpleAlert(self, message: "삭제 완료되었습니다.", title: "삭제 완료", handler: nil)
        }
    }
}


// ============ 애드몹 셋업 ============
extension ArchiveViewController: GADBannerViewDelegate {
    // 본 클래스에 다음 선언 추가
    // // AdMob
    // private var bannerView: GADBannerView!
    
    // viewDidLoad()에 다음 추가
    // setupBannerView()
    
    private func setupBannerView() {
        let adSize = GADAdSizeFromCGSize(CGSize(width: self.view.frame.width, height: 50))
        bannerView = GADBannerView(adSize: adSize)
//        bannerView.backgroundColor = UIColor(named: "notissuWhite1000s")!
        addBannerViewToView(bannerView)
        bannerView.adUnitID = Bundle.main.object(forInfoDictionaryKey: "GADArchive") as? String
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
        constraintBottom.constant = 50
    }
    private func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints( [NSLayoutConstraint(item: bannerView, attribute: .bottom, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0), NSLayoutConstraint(item: bannerView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0) ])
    }
    
    // GADBannerViewDelegate
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("GAD: \(#function)")
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        print("GAD: \(#function)")
    }
    
    func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("GAD: \(#function)")
    }
    
    func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("GAD: \(#function)")
    }
    
    func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("GAD: \(#function)")
    }
}
