//
//  GridView.swift
//  ssg
//
//  Created by pkh on 29/08/2019.
//  Copyright © 2019 emart. All rights reserved.
//

import UIKit

private let PadRatio: CGFloat = 1.4

public class GridViewData: NSObject {

    /// 그리드뷰에 전달될 데ㅐ이타
    public var contentObj: Any?

    /// 그리드뷰에 전달된 서브 데이타
    public var subData: [String: Any]?

    /// 그리뷰에 그려질  커스텀 뷰타입( nil일 경우 그리드뷰에 셋팅된 뷰가 불림)
    public var cellType: PkhGridViewProtocol.Type?

    /// 버튼이벤트나 기타 이벤트를 전달할 클로져
    public var actionClosure: OnActionClosure?

    override public init() {}
    public init(contentObj: Any? = nil, subData: [String : Any]? = nil, cellType: PkhGridViewProtocol.Type? = nil, actionClosure: OnActionClosure? = nil) {
        self.contentObj = contentObj
        self.subData = subData
        self.cellType = cellType
        self.actionClosure = actionClosure
    }

    public func setContentObj(_ contentObj: Any?) -> Self {
        self.contentObj = contentObj
        return self
    }

    public func setSubData(_ subData: [String: Any]?) -> Self {
        self.subData = subData
        return self
    }

    public func setCellType(_ cellType: PkhGridViewProtocol.Type?) -> Self {
        self.cellType = cellType
        return self
    }

    public func setActionClosure(_ actionClosure: OnActionClosure?) -> Self {
        self.actionClosure = actionClosure
        return self
    }
}

public class GridViewListData: NSObject {
    public var itemList = [GridViewData]()

    override public init() {}
    public init(itemList: [GridViewData]) {
        self.itemList = itemList
    }

    public func setItmeList(_ itemList: [GridViewData]) -> Self {
        self.itemList = itemList
        return self
    }
}

/// 버튼이벤트나 기타 이벤트를 전달할 클로져
///  - Parameters:
///     - name: 발생한 이벤트 키
///     - object: 전달해야할 데이타
public typealias OnActionClosure = (_ name: String, _ object: Any?) -> Void

public protocol PkhGridViewProtocol: UIView {
    var actionClosure: OnActionClosure? { get set }

    /// override 가능으로 높이 커스텀 가능 Default는 Xib width의 비율로 결정됨
    static func getWidthByHeight(gridView: PkhGridView, data: Any?, subData: [String: Any]?, width: CGFloat) -> CGFloat

    /// GridView에 데이가 들어오는 이벤트
    /// - Parameters:
    ///   - gridView: GridViewData
    ///   - data: GridViewData.contentObj
    ///   - subData: contentObj.subData
    ///   - indexPath: indexPath
    ///   - width: width
    func configure(gridView: PkhGridView, data: Any?, subData: [String: Any]?, indexPath: IndexPath, width: CGFloat)

}

public extension PkhGridViewProtocol {
    static func getWidthByHeight(gridView: PkhGridView, data: Any?, subData: [String: Any]?, width: CGFloat) -> CGFloat {
        return self.fromXibSize().ratioHeight(setWidth: width)
    }
}


public class PkhGridView: UIView {

    /// 그리드뷰에 그려질 공통 뷰
    public var cellType: PkhGridViewProtocol.Type!
    @IBInspectable public var cellName: String {
        get {
            return cellType.className
        }
        set {
            cellType = swiftClassFromString(newValue).self as? PkhGridViewProtocol.Type
        }
    }
    /// 가로에 표시될 아이템 수
    @IBInspectable public var columnCount: Int = 0
    /// 아이팀 좌우 간격
    @IBInspectable public var columnSpacing: CGFloat = 0.0
    /// 아이템 상하 간격
    @IBInspectable public var lineSpacing: CGFloat = 0.0
    /// 보여질 최대 줄 수
    @IBInspectable public var showLineCount: Int = 1 {
        didSet {
            guard let data = self.data, data.itemList.count > 0 else { return }
            if self.isHeightConstraint {
                self.updateHeightConstraint(to: showLineHeight)
            }
            else {
                self.frame.size.height = self.showLineHeight
            }
        }
    }
    /// 모든 아이템뷰의 높이를 같이 만들기
    @IBInspectable public var allItemHeightSame: Bool = false
    @IBInspectable public var isVertical: Bool = false

    @IBInspectable  public var topInset: CGFloat {
        get { return sectionInset.top }
        set { sectionInset.top = newValue }
    }
    @IBInspectable  public var bottomInset: CGFloat {
        get { return sectionInset.bottom }
        set { sectionInset.bottom = newValue }
    }
    @IBInspectable  public var leftInset: CGFloat {
        get { return sectionInset.left }
        set { sectionInset.left = newValue }
    }
    @IBInspectable  public var rightInset: CGFloat {
        get { return sectionInset.right }
        set { sectionInset.right = newValue }
    }
    public var sectionInset: UIEdgeInsets = .zero
    public var showLineHeight: CGFloat {
        guard self.columnHeights.count > 0 else { return 0 }
        if showLineCount == 0 {
            return maxLineHeight
        }

        var height: CGFloat = 0
        height += sectionInset.top
        for (i, h) in self.columnHeights.enumerated() {
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
    public var maxLineHeight: CGFloat {
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

    private func getItemSize(data: GridViewData) -> CGSize {
        if columnCount == 0 {
            columnCount = getAutoColumnCount()
            isAutoCount = true
        }
        let unitWidth = (getViewWidth() - (columnSpacing * (CGFloat(columnCount) - 1))) / CGFloat(columnCount)
        let cellType: PkhGridViewProtocol.Type = data.cellType ?? self.cellType
        let unitHeight = cellType.getWidthByHeight(gridView: self, data: data.contentObj, subData: data.subData, width: unitWidth)
        return CGSize(width: unitWidth, height: unitHeight)
    }

    private var beforeRect: CGRect = .zero
    private var cells = [PkhGridViewProtocol]()
    private var columnHeights: [CGFloat] = []
    private var isAutoCount: Bool = false

    // 펼쳐진 라인 이외에 보여줄 수 있는 셀들이 존재
    var isExistMoreline = false
    var data: GridViewListData?

    public override func layoutSubviews() {
        super.layoutSubviews()
        self.reset()
        self.updateUI()
    }

    public func maxLineCount() -> Int {
        guard let data else { return 0 }
        if showLineCount > 0 {
            return showLineCount
        }
        return Int(ceil(CGFloat(data.itemList.count) / CGFloat(columnCount)))
    }

    public func reset() {
        cells.forEach { $0.isHidden = true }
    }

    private func getView(_ item: GridViewData) -> PkhGridViewProtocol {
        func isXibFileExists(_ fileName: String) -> Bool {
            if let path: String = Bundle.main.path(forResource: fileName, ofType: "nib") {
                if FileManager.default.fileExists(atPath: path) {
                    return true
                }
            }
            return false
        }

        var view: PkhGridViewProtocol?
        for item in cells {
            if item.isHidden {
                item.isHidden = false
                view = item
                break
            }
        }

        if view == nil {
            let cellType: PkhGridViewProtocol.Type! = item.cellType ?? self.cellType
            if isXibFileExists(cellType.className) {
                view = cellType.fromXib()
            }
            else {
                view = cellType.init()
            }

            cells.append(view!)
            self.addSubview(view!)
        }

        return view!
    }

    private func getViewWidth() -> CGFloat {
        return self.frame.size.width - self.sectionInset.left - self.sectionInset.right
    }

    private func itemWidth() -> CGFloat {
        let unitWidth = (getViewWidth() - (columnSpacing * (CGFloat(self.columnCount) - 1))) / CGFloat(self.columnCount)
        return unitWidth
    }

    private func updateUI() {
        guard (self.beforeRect != self.frame) || self.isHeightConstraint else { return }
        guard let itemList = self.data?.itemList else { return }
        self.beforeRect = self.frame

        setColumnHeights()

        let itemSizeWidth: CGFloat = itemWidth()
        let maxLineCount: Int = self.maxLineCount()
        var itemIndex: Int = 0
        var lineCount: Int = 0
        var itemHieght: CGFloat = 0
        var xOffset: CGFloat = 0
        var yOffset: CGFloat = 0

        var maxY: CGFloat = sectionInset.top
        self.isExistMoreline = false
        for (idx, item) in itemList.enumerated() {
            itemIndex = 0
            if idx != 0 {
                if isVertical {
                    itemIndex = idx / maxLineCount
                    lineCount = idx % maxLineCount
                }
                else {
                    itemIndex = idx % columnCount
                    lineCount = (idx / columnCount)
                }
            }
            if showLineCount == 0 || lineCount < showLineCount {
                let cell = getView(item)
                xOffset = sectionInset.left + ((itemSizeWidth + self.columnSpacing) * CGFloat(itemIndex))
                yOffset = maxY
                itemHieght = self.columnHeights[lineCount]

                cell.frame = CGRect(x: xOffset, y: yOffset, width: itemSizeWidth, height: itemHieght)

                cell.actionClosure = item.actionClosure
                // row: 라인 내에서 column, section: 라인
                // row 가 영어로 행이지만 한 라인을 section 으로 봄
                cell.configure(gridView: self, data: item.contentObj, subData: item.subData, indexPath: IndexPath(row: itemIndex, section: lineCount), width: itemSizeWidth)
                if isVertical {
                    maxY = cell.frame.maxY + self.lineSpacing
                    if lineCount == (maxLineCount - 1) {
                        maxY = sectionInset.top
                    }
                }
                else {
                    if itemIndex == (columnCount - 1) {
                        maxY = cell.frame.maxY + self.lineSpacing
                    }
                }
            }
            else {
                self.isExistMoreline = true
                break
            }
        }

        if self.isHeightConstraint {
            self.updateHeightConstraint(to: self.showLineHeight)
        }
        else {
            self.frame.size.height = self.showLineHeight
        }
    }

    func reloadData() {
        self.reset()
        self.updateUI()
    }

    private func getAutoColumnCount() -> Int {
        var itemWidth = self.cellType.fromXib(cache: true).frame.size.width
        if UIDevice.current.userInterfaceIdiom != .phone {
            itemWidth = itemWidth * PadRatio
        }

        var maxX: CGFloat = itemWidth
        var displayAbleCount = 0

        let viewWidth = getViewWidth()
        while maxX <= viewWidth {
            displayAbleCount += 1
            maxX += itemWidth + columnSpacing
        }

        return displayAbleCount
    }

    private func setColumnHeights() {
        guard let data = self.data else { return }

        if columnCount == 0 || isAutoCount {
            isAutoCount = true
            columnCount = self.getAutoColumnCount()
        }

        guard columnCount != 0 else { return }

        self.columnHeights.removeAll()
        var itemHegihts = [CGFloat]()
        for item in data.itemList {
            let heigth = self.getItemSize(data: item).height
            itemHegihts.append(heigth)
        }

        let maxLineCount: Int = self.maxLineCount()
        self.columnHeights.reserveCapacity(maxLineCount)
        var maxHeight: CGFloat = 0
        var itemIndex: Int = 1

        if self.isVertical {
            for i in 0..<maxLineCount {
                for j in 0..<columnCount {
                    let h = itemHegihts[safe: i + j * maxLineCount] ?? 0
                    if self.columnHeights.count > i {
                        self.columnHeights[i] = max(self.columnHeights[i], h)
                    }
                    else {
                        self.columnHeights.append(h)
                    }
                }
            }
        }
        else {
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
        }

        if allItemHeightSame {
            var maxHeight: CGFloat = 0
            self.columnHeights.forEach({ maxHeight = max($0, maxHeight) })
            for i in 0..<self.columnHeights.count {
                self.columnHeights[i] = maxHeight
            }
        }
    }
}

 
fileprivate var CacheViewNibs = {
    let cache = NSCache<NSString, UIView>()
    cache.countLimit = 300
    return cache
}()

extension UIView {
    class func fromXib(cache: Bool = false) -> Self {
        return fromXib(cache: cache, as: self)
    }
    
    private class func fromXib<T>(cache: Bool = false, as type: T.Type) -> T {
        if cache, let view = CacheViewNibs.object(forKey: self.className as NSString) {
            return view as! T
        }
        let view: UIView = Bundle.main.loadNibNamed(self.className, owner: nil, options: nil)!.first as! UIView
        if cache {
            CacheViewNibs.setObject(view, forKey: self.className as NSString)
        }
        return view as! T
    }
    
    class func fromXibSize() -> CGSize {
        return fromXib(cache: true).frame.size
    }


}

extension CGSize {
    public func ratioHeight(setWidth: CGFloat) -> CGFloat {
        guard self.width != 0 else { return 0 }
        if self.width == setWidth {
            return self.height
        }
        let origin: CGFloat = self.height * setWidth / self.width
        return origin
    }
}

extension UIView {
    var isHeightConstraint: Bool {
        if let _ = self.constraints.first(where: { $0.firstAttribute == .height }) {
            return true
        }
        return false
    }

    var isWidhConstraint: Bool {
        if let _ = self.constraints.first(where: { $0.firstAttribute == .width }) {
            return true
        }
        return false
    }

    func updateHeightConstraint(to newHeight: CGFloat) {
        // height 제약 조건이 있는지 확인
        if let heightConstraint = self.constraints.first(where: { $0.firstAttribute == .height }) {
            // 값 변경
            heightConstraint.constant = newHeight
        } else {
            // height 제약 조건이 없다면 새로 추가
            let newConstraint = self.heightAnchor.constraint(equalToConstant: newHeight)
            newConstraint.isActive = true
        }
    }

    func updateWidthConstraint(to newWidth: CGFloat) {
        // height 제약 조건이 있는지 확인
        if let widthConstraint = self.constraints.first(where: { $0.firstAttribute == .width }) {
            // 값 변경
            widthConstraint.constant = newWidth
        } else {
            // height 제약 조건이 없다면 새로 추가
            let newConstraint = self.widthAnchor.constraint(equalToConstant: newWidth)
            newConstraint.isActive = true
        }
    }
}

extension Array {
    ///   Gets the object at the specified index, if it exists.
    public subscript(safe index: Int?) -> Element? {
        guard let index else { return nil }
        if indices.contains(index) {
            return self[index]
        }
        else {
            return nil
        }
    }
}


@inline(__always) public func swiftClassFromString(_ className: String, bundleName: String = "") -> AnyClass? {

    // get the project name
    if  let appName = Bundle.main.object(forInfoDictionaryKey:"CFBundleName") as? String {
        // generate the full name of your class (take a look into your "YourProject-swift.h" file)
        let classStringName = "\(appName).\(className)"
        guard let aClass = NSClassFromString(classStringName) else {
            let classStringName = "\(bundleName).\(className)"
            guard let aClass = NSClassFromString(classStringName) else {
                //                print(">>>>>>>>>>>>> [ \(className) ] : swiftClassFromString Create Fail <<<<<<<<<<<<<<")
                return nil

            }
            return aClass
        }
        return aClass
    }
    //    print(">>>>>>>>>>>>> [ \(className) ] : swiftClassFromString Create Fail <<<<<<<<<<<<<<")
    return nil
}

extension NSObject {
    public var className: String {
        return String(describing: type(of:self))
    }

    public class var className: String {
        return String(describing: self)
    }
}

