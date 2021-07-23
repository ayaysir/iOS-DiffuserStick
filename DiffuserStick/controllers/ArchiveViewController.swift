//
//  ArchiveViewController.swift
//  DiffuserStick
//
//  Created by yoonbumtae on 2021/07/22.
//

import UIKit

class ArchiveViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    let archiveViewModel = DiffuserViewModel()
    
    @IBOutlet weak var collectionView: UICollectionView!
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
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
