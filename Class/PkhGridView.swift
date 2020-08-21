//
//  GridView.swift
//  ssg
//
//  Created by pkh on 29/08/2019.
//  Copyright © 2019 emart. All rights reserved.
//

import UIKit

public let UISCREEN_WIDTH = UIScreen.main.bounds.width
public let UISCREEN_HEIGHT = UIScreen.main.bounds.height


class GridViewData {
    var itemList = [Any]()
    var showLineCount: Int = 1
    
    init(itemList: [Any]) {
        self.itemList = itemList
    }
}

typealias OnActionClosure = (_ name: String, _ object: Any?) -> Void
typealias PkhGridViewSelectClosure = (_ view: PkhGridView, _ index: Int, _ data: Any?) -> Void

protocol PkhGridViewCellProtocol: UICollectionViewCell {
    var actionClosure: OnActionClosure? { get set }
    
    static func getGridViewHeight(data: Any?, width: CGFloat) -> CGFloat
    func configure(_ data: Any?)
}


class PkhGridView: UIView {
    var collectionView: UICollectionView!
    var actionClosure: OnActionClosure?
    var cellType: PkhGridViewCellProtocol.Type!
    
    private var isCellRegistered: Bool = false
    @IBInspectable var cellName: String {
        get {
            return cellType.className
        }
        set {
            cellType = (swiftClassFromString(newValue).self as! PkhGridViewCellProtocol.Type)
        }
    }
    @IBInspectable var columnCount: Int = 0 {
        didSet {
            if let layout = self.collectionView.collectionViewLayout as? GridViewFlowLayout {
                layout.columnCount = columnCount
            }
        }
    }
    @IBInspectable var columnSpacing: CGFloat {
        get {
            if let layout = self.collectionView.collectionViewLayout as? GridViewFlowLayout {
                return layout.minimumColumnSpacing
            }
            return 0
        }
        set {
            if let layout = self.collectionView.collectionViewLayout as? GridViewFlowLayout {
                layout.minimumColumnSpacing = newValue
            }
        }
    }
    @IBInspectable var lineSpacing: CGFloat {
        get {
            if let layout = self.collectionView.collectionViewLayout as? GridViewFlowLayout {
                return layout.minimumInteritemSpacing
            }
            return 0
        }
        set {
            if let layout = self.collectionView.collectionViewLayout as? GridViewFlowLayout {
                layout.minimumInteritemSpacing = newValue
            }
        }
    }
    @IBInspectable var showLineCount: Int = 1 {
        didSet {
            guard let data = self.data, data.itemList.count > 0 else { return }
            if let layout = self.collectionView.collectionViewLayout as? GridViewFlowLayout {
                layout.invalidateLayout()
                self.frame.size.height = self.showLineHeight
            }
        }
    }
    
    @IBInspectable var heightFit: Bool = true
    
    @IBInspectable var isShowBottomLine: Bool {
        get {
            if let layout = self.collectionView.collectionViewLayout as? GridViewFlowLayout {
                return layout.isShowBottomLine
            }
            return false
        }
        set {
            if let layout = self.collectionView.collectionViewLayout as? GridViewFlowLayout {
                layout.isShowBottomLine = newValue
            }
        }
    }
    
    @IBInspectable var bottomLineColor: UIColor {
        get {
            if let layout = self.collectionView.collectionViewLayout as? GridViewFlowLayout {
                return layout.bottomLineColor
            }
            return UIColor.gray
        }
        set {
            if let layout = self.collectionView.collectionViewLayout as? GridViewFlowLayout {
                layout.bottomLineColor = newValue
            }
        }
    }
    
    
    @IBInspectable public var topInset: CGFloat {
        get { return sectionInset.top }
        set { sectionInset.top = newValue }
    }
    
    @IBInspectable public var bottomInset: CGFloat {
        get { return sectionInset.bottom }
        set { sectionInset.bottom = newValue }
    }
    
    @IBInspectable public var leftInset: CGFloat {
        get { return sectionInset.left }
        set { sectionInset.left = newValue }
    }
    
    @IBInspectable public var rightInset: CGFloat {
        get { return sectionInset.right }
        set { sectionInset.right = newValue }
    }
    
    var sectionInset: UIEdgeInsets = .zero
    
    var showLineHeight: CGFloat {
        guard self.columnHeights.count > 0 else { return 0 }
        if showLineCount == 0 {
            return maxLineHeight
        }
       
        var height: CGFloat = 0
        height += sectionInset.top
        for (i,h) in self.columnHeights.enumerated() {
            height += h
            height += lineSpacing
            if i >= showLineCount - 1 {
                break
            }
        }
        height -= lineSpacing // 마지막줄 lineSpacing는 삭제한다.
        height += sectionInset.bottom
        
        return height
    }
    var maxLineHeight: CGFloat {
        var height: CGFloat = 0
        height += sectionInset.top
        for h in self.columnHeights {
            height += h
            height += lineSpacing
        }
        height -= lineSpacing // 마지막줄 lineSpacing는 삭제한다.
        height += sectionInset.bottom
        
        return height
        
    }
    func getItemSize(data: Any?) -> CGSize {
        let width = self.frame.size.width - self.sectionInset.left - self.sectionInset.right
        let unitWidth = (width - (columnSpacing * (CGFloat(self.columnCount) - 1))) / CGFloat(self.columnCount)
        return CGSize(width: unitWidth, height: self.cellType.getGridViewHeight(data: data, width: unitWidth))
    }
    
    var selectClosure: PkhGridViewSelectClosure?
    var data: GridViewData?
    var columnHeights : [CGFloat] = []
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        UIInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        UIInit()
    }
    
    func UIInit() {
//        clipsToBounds = true
        let flowlayout = GridViewFlowLayout()
        collectionView = UICollectionView(frame: bounds, collectionViewLayout: flowlayout)
        collectionView.frame = bounds
        collectionView.isScrollEnabled = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.delegate = self
        collectionView.dataSource = self
        addSubview(collectionView)
    }
    
    func configure(data: GridViewData?, actionClosure: OnActionClosure?) {
        guard let data = data else { return }
        if isCellRegistered == false {
            isCellRegistered = true
            collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: UICollectionViewCell.className)
            collectionView.register(UINib(nibName: self.cellType.className, bundle: nil), forCellWithReuseIdentifier: self.cellType.className)
        }
        
        self.data = data
        self.actionClosure = actionClosure
        
        if let layout = self.collectionView.collectionViewLayout as? GridViewFlowLayout {
            layout.sectionInset = self.sectionInset
        }
        
        self.setColumnHeights()
        self.collectionView.reloadData()
        
        self.frame.size.height = self.showLineHeight
    }
    
    func reloadData() {
        self.collectionView.reloadData()
    }
    
    
    func getAutoColumnCount() -> Int {
        let itemWidth =  self.cellType.fromNib(cache: true).frame.size.width
        let ViewWidth = self.frame.size.width - self.sectionInset.left - self.sectionInset.right
        
        var maxX: CGFloat = itemWidth
        var displayAbleCount = 0
        
        while maxX <= ViewWidth {
            displayAbleCount += 1
            maxX += itemWidth + columnSpacing
        }
        
        return displayAbleCount
    }
    
    func setColumnHeights() {
        guard let data = self.data else { return }
        
        if columnCount == 0 {
            columnCount = self.getAutoColumnCount()
        }
                
        self.columnHeights.removeAll()
        var itemHegihts = [CGFloat]()
        for item in data.itemList {
            let heigth = self.getItemSize(data: item).height
            itemHegihts.append(heigth)
        }
        
        let maxLineCount: Int = Int(ceil(CGFloat(itemHegihts.count) / CGFloat(columnCount)))
        self.columnHeights.reserveCapacity(maxLineCount)
        var maxHeight: CGFloat = 0
        var itemIndex: Int = 1
        for h in itemHegihts {
            maxHeight = max(maxHeight, h)
            itemIndex += 1
            if itemIndex > columnCount {
                self.columnHeights.append(maxHeight)
                maxHeight = 0
                itemIndex = 1
            }
        }
        if maxHeight > 0 {
            self.columnHeights.append(maxHeight)
        }
        
        
        if heightFit == false {
            var maxHeight: CGFloat = 0
            self.columnHeights.forEach({ maxHeight = max($0,maxHeight) })
            for i in 0..<self.columnHeights.count {
                self.columnHeights[i] = maxHeight
            }
        }
        
     
        if let layout = self.collectionView.collectionViewLayout as? GridViewFlowLayout {
            layout.columnHeights = columnHeights
        }
    }
    
}

extension PkhGridView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let data = self.data else { return 0 }
        return data.itemList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        func defaultReturn() -> UICollectionViewCell {
            return collectionView.dequeueReusableCell(withReuseIdentifier: UICollectionViewCell.className, for: indexPath)
        }
        
        guard let data = self.data else { return defaultReturn() }
        let dataItem = data.itemList[indexPath.row]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellType.className, for: indexPath)
        if let cell = cell as? PkhGridViewCellProtocol {
            cell.actionClosure = actionClosure
            cell.configure(dataItem)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let data = self.data else { return .zero }
        
        let dataItem = data.itemList[indexPath.row]
        return getItemSize(data: dataItem)
    }
}


class GridViewFlowLayout : UICollectionViewLayout {
    
    var columnCount : Int {
        didSet{
            invalidateLayout()
        }}
    
    var minimumColumnSpacing : CGFloat {
        didSet{
            invalidateLayout()
        }}
    
    var minimumInteritemSpacing : CGFloat {
        didSet{
            invalidateLayout()
        }}
    
    var sectionInset : UIEdgeInsets {
        didSet{
            invalidateLayout()
        }}
    
    var isShowBottomLine: Bool = false
    var bottomLineColor: UIColor = UIColor.gray
    
    var columnHeights : [CGFloat] = []
    var sectionItemAttributes : [[UICollectionViewLayoutAttributes]] = []
    var allItemAttributes : [UICollectionViewLayoutAttributes] = []
    var unionRects : [CGRect] = []
    let unionSize = 20
    var lineViews = [UIView]()
    
    
    override init(){
        self.columnCount = 2
        self.minimumInteritemSpacing = 10
        self.minimumColumnSpacing = 10
        self.sectionInset = UIEdgeInsets.zero
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func itemWidth() -> CGFloat {
        let width:CGFloat = self.collectionView!.frame.size.width - sectionInset.left - sectionInset.right
        let spaceColumCount:CGFloat = CGFloat(self.columnCount-1)
        return (width - (spaceColumCount*self.minimumColumnSpacing)) / CGFloat(self.columnCount)
    }
    
    override func prepare(){
        super.prepare()
        
        guard let collectionView = self.collectionView else { return }
        guard self.columnHeights.count > 0 else { return }
        let numberOfSections = collectionView.numberOfSections
        if numberOfSections == 0 {
            return
        }
        
        self.unionRects.removeAll()
        self.allItemAttributes.removeAll()
        self.sectionItemAttributes.removeAll()
        
        let itemCount = collectionView.numberOfItems(inSection: 0)
        let itemSizeWidth: CGFloat = itemWidth()
        
        var maxY: CGFloat = sectionInset.top
        var attributes = UICollectionViewLayoutAttributes()
        var itemAttributes: [UICollectionViewLayoutAttributes] = []
        for idx in 0 ..< itemCount {
            let indexPath = IndexPath(item: idx, section: 0)
            
            var itemIndex: Int = 0
            if idx != 0 {
                itemIndex = idx % columnCount
            }
            let lineCount: Int = (idx / columnCount)
            let itemHieght = self.columnHeights[lineCount]
            
            let xOffset = sectionInset.left + ((itemSizeWidth + self.minimumColumnSpacing) * CGFloat(itemIndex))
            let yOffset = maxY
            
            attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = CGRect(x: xOffset, y: yOffset, width: itemSizeWidth, height: itemHieght)
            itemAttributes.append(attributes)
            self.allItemAttributes.append(attributes)
            if itemIndex == (columnCount - 1) {
                maxY = attributes.frame.maxY + self.minimumInteritemSpacing
            }
            
        }
        self.sectionItemAttributes.append(itemAttributes)
        
        
        var idx = 0
        let itemCounts = self.allItemAttributes.count
        while(idx < itemCounts){
            let rect1 = self.allItemAttributes[idx].frame
            idx = min(idx + unionSize, itemCounts) - 1
            let rect2 = self.allItemAttributes[idx].frame
            self.unionRects.append(rect1.union(rect2))
            idx += 1
        }
        
        lineViews.forEach({ $0.isHidden = true })
        if isShowBottomLine {
            showLineView()
        }
    }
    
    func getLineView(index: Int) -> UIView {
        guard let collectionView = self.collectionView else { return UIView() }
        
        let lineView: UIView
        if index < lineViews.count {
            lineView = lineViews[index]
        }
        else {
            lineView = UIView(frame: CGRect(x: 0, y: 0, width: collectionView.frame.size.width, height: 1))
            lineView.autoresizingMask = [.flexibleWidth]
            lineViews.append(lineView)
            collectionView.addSubview(lineView)
        }
        lineView.backgroundColor = bottomLineColor
        lineView.isHidden = false
        return lineView
    }
    
    
    func showLineView() {
        
        var lineYs = [CGFloat]()
        for att in allItemAttributes {
            if lineYs.last != att.frame.maxY {
                lineYs.append(att.frame.maxY)
            }
        }
        lineYs.removeLast() // 마지막줄을 표시하지 않는다.
        
        for (i,y) in lineYs.enumerated() {
            let lineView = getLineView(index: i)
            lineView.frame.origin.y = y - 1
        }
    }
    
    override var collectionViewContentSize : CGSize {
        guard let collectionView = self.collectionView else { return CGSize.zero }
        let numberOfSections = collectionView.numberOfSections
        if numberOfSections == 0{
            return CGSize.zero
        }
        
        var contentSize = collectionView.bounds.size
        let height = self.allItemAttributes.last?.frame.maxY ?? 0
        contentSize.height = CGFloat(height)
        return  contentSize
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes?{
        if indexPath.section >= self.sectionItemAttributes.count {
            return nil
        }
        if indexPath.item >= (self.sectionItemAttributes[indexPath.section]).count {
            return nil;
        }
        let list = self.sectionItemAttributes[indexPath.section]
        return list[indexPath.item]
    }
    
    override func layoutAttributesForElements (in rect : CGRect) -> [UICollectionViewLayoutAttributes] {
        var begin = 0, end = self.unionRects.count
        var attrs: [UICollectionViewLayoutAttributes] = []
        
        for i in 0 ..< end {
            if rect.intersects(self.unionRects[i]) {
                begin = i * unionSize;
                break
            }
        }
        var i = self.unionRects.count - 1
        while i>=0 {
            if rect.intersects(self.unionRects[i]){
                end = min((i+1)*unionSize, self.allItemAttributes.count)
                break
            }
            i -= 1
        }
        for i in begin ..< end {
            let attr = self.allItemAttributes[i]
            if rect.intersects(attr.frame) {
                attrs.append(attr)
            }
        }
        
        return attrs
    }
    
    override func shouldInvalidateLayout (forBoundsChange newBounds : CGRect) -> Bool {
        let oldBounds = self.collectionView!.bounds
        if newBounds.width != oldBounds.width{
            return true
        }
        return false
    }
    
}
 
fileprivate var CacheViewNibs = NSCache<NSString, UIView>()
extension UIView {
    
    class func fromNib(cache: Bool = false) -> Self {
        return fromNib(cache: cache, as: self)
    }
    
    private class func fromNib<T>(cache: Bool = false, as type: T.Type) -> T {
        if cache, let view = CacheViewNibs.object(forKey: self.className as NSString) {
            return view as! T
        }
        let view: UIView = Bundle.main.loadNibNamed(self.className, owner: nil, options: nil)!.first as! UIView
        if cache {
            CacheViewNibs.setObject(view, forKey: self.className as NSString)
        }
        return view as! T
    }
    
    class func fromNibSize() -> CGSize {
        return fromNib(cache: true).frame.size
    }
}
