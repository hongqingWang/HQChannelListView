//
//  HQChannelListViewController.swift
//  HQChannelListView
//
//  Created by 王红庆 on 2017/6/1.
//  Copyright © 2017年 王红庆. All rights reserved.
//

import UIKit

private let SCREEN_WIDTH = UIScreen.main.bounds.size.width
private let SCREEN_HEIGHT = UIScreen.main.bounds.size.height
private let HQChannelListCellIdentifier = "HQChannelListCellIdentifier"
private let HQChannelListHeaderViewIdentifier = "HQChannelListHeaderViewIdentifier"
private let itemW: CGFloat = (SCREEN_WIDTH - 60) / 4

class HQChannelListViewController: UIViewController {

    // 选择一个频道后的回调
    var selectCallBack: ((_ myChannel: [String], _ moreChannel: [String], _ selectIndex: Int) -> ())?
    let headerTitle = [["我的频道", "更多频道"], ["拖动频道排序", "点击添加频道"]]
    var array1 = ["推荐"]
    var array2 = ["有声"]
    var isEdit = false
    
    init(myChannel: [String], moreChannel: [String]) {
        
        array1 = myChannel
        array2 = moreChannel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "频道管理"
        view.addSubview(collectionView)
    }
    
    // MARK: - longPress
    func longPress(tap: UILongPressGestureRecognizer) -> () {
        
        if !isEdit {
            isEdit = !isEdit
            collectionView.reloadData()
            return
        }
        let point = tap.location(in: tap.view)
        let sourceIndexPath = collectionView.indexPathForItem(at: point)
        
        switch tap.state {
        case UIGestureRecognizerState.began:
            collectionView.beginInteractiveMovementForItem(at: sourceIndexPath!)
            
        case UIGestureRecognizerState.changed:
            collectionView.updateInteractiveMovementTargetPosition(point)
            
        case UIGestureRecognizerState.ended:
            collectionView.endInteractiveMovement()
            
        case UIGestureRecognizerState.cancelled:
            collectionView.cancelInteractiveMovement()
        default:
            break
        }
    }
    
    // MARK: - lazy
    private lazy var collectionView: UICollectionView = {

        let collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: HQChannelListViewLayout())
        collectionView.backgroundColor = UIColor.groupTableViewBackground
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(HQChannelListCell.classForCoder(), forCellWithReuseIdentifier: HQChannelListCellIdentifier)
        collectionView.register(HQChannelListHeaderView.classForCoder(), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: HQChannelListHeaderViewIdentifier)
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(longPress))
        collectionView.addGestureRecognizer(gesture)
        return collectionView
    }()
}

// MARK: - UICollectionViewDataSource
extension HQChannelListViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? array1.count : array2.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HQChannelListCellIdentifier, for: indexPath) as! HQChannelListCell
        cell.text = indexPath.section == 0 ? array1[indexPath.item] : array2[indexPath.item]
        cell.edit = (indexPath.section == 0 && indexPath.item == 0 || indexPath.section == 1) ? false : isEdit
        if !isEdit {
            cell.textColor = (indexPath.section == 0 && indexPath.item == 0) ? UIColor.init(colorLiteralRed: 255 / 255.0, green: 0 / 255.0, blue: 0 / 255.0, alpha: 0.7) : UIColor.darkGray
        } else {
            cell.textColor = (indexPath.section == 0 && indexPath.item == 0) ? UIColor.lightGray : UIColor.darkGray
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: HQChannelListHeaderViewIdentifier, for: indexPath) as! HQChannelListHeaderView
        headerView.text = isEdit ? headerTitle[1][indexPath.section] : headerTitle[0][indexPath.section]
        headerView.button.isSelected = isEdit
        
        if indexPath.section > 0 {
            headerView.button.isHidden = true
        } else {
            headerView.button.isHidden = false
        }
        
        headerView.editCallBack = { [weak self] in
            self?.isEdit = !(self?.isEdit)!
            collectionView.reloadData()
        }
        
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 && indexPath.item == 0 {
            return false
        }
        return true
    }
}

// MARK: - UICollectionViewDelegate
extension HQChannelListViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            if isEdit {
                if indexPath.item == 0 {
                    return
                }
                let obj = array1[indexPath.item]
                array1.remove(at: indexPath.item)
                array2.insert(obj, at: 0)
                collectionView.moveItem(at: indexPath, to: NSIndexPath(item: 0, section: 1) as IndexPath)
            } else {
                if selectCallBack != nil {
                    selectCallBack!(array1, array2, indexPath.item)
                    _ = navigationController?.popViewController(animated: true)
                }
            }
        } else {
            
            let obj = array2[indexPath.item]
            array2.remove(at: indexPath.item)
            array1.append(obj)
            collectionView.moveItem(at: indexPath, to: NSIndexPath(item: array1.count - 1, section: 0) as IndexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        if sourceIndexPath.section == 0 && destinationIndexPath.section == 0 {
            let obj = array1[sourceIndexPath.item]
            array1.remove(at: sourceIndexPath.item)
            array1.insert(obj, at: destinationIndexPath.item)
        }
        if sourceIndexPath.section == 0 && destinationIndexPath.section == 1 {
            let obj = array1[sourceIndexPath.item]
            array1.remove(at: sourceIndexPath.item)
            array2.insert(obj, at: destinationIndexPath.item)
        }
        if sourceIndexPath.section == 1 && destinationIndexPath.section == 0 {
            let obj = array2[sourceIndexPath.item]
            array2.remove(at: sourceIndexPath.item)
            array1.insert(obj, at: destinationIndexPath.item)
        }
        if sourceIndexPath.section == 1 && destinationIndexPath.section == 1 {
            let obj = array2[sourceIndexPath.item]
            array2.remove(at: sourceIndexPath.item)
            array2.insert(obj, at: destinationIndexPath.item)
        }
    }
}

// MARK: - 自定义Cell
class HQChannelListCell: UICollectionViewCell {
    
    var edit = true {
        didSet {
            imageView.isHidden = !edit
        }
    }
    
    var text: String? {
        didSet {
            label.text = text
        }
    }
    var textColor: UIColor = UIColor.darkGray {
        didSet {
            label.textColor = textColor
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.white
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        
        self.addSubview(label)
        label.addSubview(imageView)
    }
    
    private lazy var label: UILabel = {
        
        let label = UILabel(frame: self.bounds)
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    private lazy var imageView: UIImageView = {
       
        let imageView = UIImageView(frame: CGRect(x: self.bounds.size.width - 12, y: -3, width: 15, height: 15))
        imageView.image = UIImage(named: "close")
        imageView.isHidden = true
        return imageView
    }()
}

// MARK: - CollectionHeaderView
class HQChannelListHeaderView: UICollectionReusableView {
    
    var editCallBack: (() -> ())?
    var text: String? {
        didSet {
            label.text = text
        }
    }
    
    func edit() -> () {
        
        if editCallBack != nil {
            editCallBack!()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        
        addSubview(label)
        addSubview(button)
        backgroundColor = UIColor.groupTableViewBackground
    }
    
    private lazy var label: UILabel = {
       
        let label = UILabel(frame: self.bounds)
        label.frame.origin.x = 20
        return label
    }()
    
    lazy var button: UIButton = {
       
        let btn = UIButton(type: .custom)
        btn.setTitle("编辑", for: .normal)
        btn.setTitle("完成", for: .selected)
        btn.setTitleColor(UIColor.init(colorLiteralRed: 255 / 255.0, green: 0 / 255.0, blue: 0 / 255.0, alpha: 0.7), for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        btn.frame = CGRect(x: SCREEN_WIDTH - 65, y: 10, width: 50, height: 25)
        btn.addTarget(self, action: #selector(edit), for: .touchUpInside)
        
        btn.layer.cornerRadius = 12.5
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.init(colorLiteralRed: 255 / 255.0, green: 0 / 255.0, blue: 0 / 255.0, alpha: 0.7).cgColor
        return btn
    }()
}

// MARK: - 自定义布局属性
class HQChannelListViewLayout: UICollectionViewFlowLayout {
    
    override func prepare() {
        super.prepare()
        
        headerReferenceSize = CGSize(width: SCREEN_WIDTH, height: 40)
        itemSize = CGSize(width: itemW, height: itemW * 0.5)
        minimumInteritemSpacing = 5
        minimumLineSpacing = 5
        sectionInset = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
    }
}
