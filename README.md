![](http://upload-images.jianshu.io/upload_images/2069062-71f45a10b6969e90.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

## 前言：先看下效果

![低仿搜狐新闻标签列表页.gif](https://github.com/hongqingWang/HQChannelListView/blob/master/低仿搜狐新闻标签列表页.gif)

> Tips：
> 
> 1. 这是用`Swfit`写的一个小Demo，用`UICollectionView`实现的拖拽排序，点击排序的效果。
> 2. 我所用的`UICollectionView`的排序方法是系统默认的方法，优点是比较简单，不用自己去计算太多。缺点是只支持`iOS 9.0`以后的版本。
> 3. 此Demo仅供参考，还有很多地方不完善，抽空我会再修改完善的，也欢迎各位给我提出缺点，并指正！

## 🌎用法简单介绍

- `ViewController`就是一个首页的普通控制器，当点击`+`的时候，就会`push`到**频道管理**（也就是标签列表）页面。
- 在`ViewController`里自定义了两个数组，**我的频道**(`myChannels`)和更多频道(`moreChannels`)
- 在点击`+`跳转到**频道管理**页面的点击方法里面有一个回调方法，即：将选中的频道、以及自定义后的频道回传到此页面。

```swfit
var myChannels = ["推荐", "热点", "北京", "视频",
                  "社会", "娱乐", "问答", "汽车",
                  "财经", "军事", "体育", "段子",
                  "美女", "时尚", "国际", "趣图",
                  "健康", "特卖", "房产", "养生",
                  "历史", "育儿", "小说", "教育",
                  "搞笑"]
var moreChannels = ["科技", "直播", "数码", "美食",
                    "电影", "手机", "旅游", "股票",
                    "科学", "动漫", "故事", "收藏",
                    "精选", "语录", "星座", "美图",
                    "政务", "辟谣", "火山直播", "中国新唱将",
                    "彩票", "快乐男生", "正能量"]

override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.title = "王红庆"
    view.backgroundColor = UIColor.white
    
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(popToChannelListViewController))
}

func popToChannelListViewController() -> () {
    
    let channelVC = HQChannelListViewController(myChannel: myChannels, moreChannel: moreChannels)
    channelVC.selectCallBack = { (myChannel, moreChannel, selectIndex) -> () in
        self.navigationItem.title = myChannel[selectIndex]
        self.myChannels = myChannel
        self.moreChannels = moreChannel
    }
    navigationController?.pushViewController(channelVC, animated: true)
}
```

## 🌎所有的事情都交给`HQChannelListViewController`来处理

- 首先定义一些可能用到的常量

```swift
private let SCREEN_WIDTH = UIScreen.main.bounds.size.width
private let SCREEN_HEIGHT = UIScreen.main.bounds.size.height
private let HQChannelListCellIdentifier = "HQChannelListCellIdentifier"
private let HQChannelListHeaderViewIdentifier = "HQChannelListHeaderViewIdentifier"
private let itemW: CGFloat = (SCREEN_WIDTH - 60) / 4
```

- 自定义流水布局，设置布局的一些属性

```swfit
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
```

- 自定义`CollectionHeaderView`

```swift
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
```

- 自定义Cell

```swift
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
```

- 定义回调方法、给`Item`添加长按手势，并处理长按的一些状态（方法均为`UICollectionView`提供的方法，只支持`iOS 9.0`以后的版本）

```swift
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
```

- 实现`CollectionView`的数据源方法

```swift
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
        // 设置第一组的第一个不能被移动
        if indexPath.section == 0 && indexPath.item == 0 {
            return false
        }
        return true
    }
}
```

- 实现`CollectionView`的代理方法，在将**选中的`Item`**移动到**目标的`Item`**上的时候，我的方法处理的不是太好。但是想不到什么好法子，欢迎大家给我提思路，提建议。

```swift
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
        
        /*
         1.以下方法是处理移动后的数组中的元素'删除'或'新增'问题.
         2.不这样处理,就会崩溃.自己算法水平有限,也是真的没想到什么比较好的办法.
         3.可能有人比较较真,提到如果真的像搜狐那么多'section'如何处理.个人感觉,目前市面上比较火的几家新闻,只有搜狐分的比较多,其它像'头条'或者'网易'也就都只有两组而已.
         4.如果大家有什么好的方法,欢迎拍砖.我愿意像各位前辈学习.
         */
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
```

## 🌎总结

用`Swift`造的第一个轮子，主要是给自己增加点积累，也练练`Swift`的一些用法。
现在还存在的一些不尽人意的地方：

1. 长按之后是变成编辑状态，不像《头条》或者《搜狐》那样长按之后变成编辑也可以继续拖动。
2. 选中`Item`没有放大的效果，确实影响用户体验。
3. 如果将`Item`从**我的频道**移动到**更多频道**里面，删除的`x(小叉叉)`依然存在。
4. **我的频道**里面第一个`Item`本意上我是不希望他可以被移动的，但是如果将其它的`Item`移动到第一个位置依然可以，背离了我的初衷。
5. 仔细观察了一下，《头条》或者《搜狐》的**更多频道**里，如果将**我的频道**中的`Item`移动到**更多频道**里，《搜狐》只是放在**更多频道**里面的最后一个位置，《头条》是放在第一个的位置，并没有放哪里都行，我突然又感觉我自己的又有点多此一举了。看来有个好的产品经理还是很重要的。

> 以上是我个人的一些总结，我相信一定还有我自己没有注意到的地方存在问题。欢迎各位给我提宝贵意见。我会积极改正的！！！

**简书地址：[Swift-低仿搜狐新闻标签页效果](http://www.jianshu.com/p/49cf4cece53c)**