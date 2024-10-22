# PkhGridView

[![SwiftPM compatible](https://img.shields.io/badge/SwiftPM-compatible-brightgreen.svg)](https://swift.org/package-manager/)

👻 Easy GridView Controller  

## 목표
### UIView을 가로로 숫자 지정하여 배열하고 싶을때
### columnCount 숫자에 따라 가로 갯수가 정해지기 때문에 그리드뷰 width 기반으로 cell의 width가 자동으로 늘어남 (가로에 대한 높이 가변 처리는 getGridViewHeight 이용하여 처리 가능함)
### columnCount == 0 으로 셋팅시 Cell의 Xib의 Width 크기로대로 Cell의 가로 숫자가 가변으로 지정되어 그려짐 그리드뷰 가로 사이즈를 넘어가면 하단으로 내려감감
### GirdView Xib에서 Cell의 이름이나 여려가지 셋팅이 가능하므로 코드가 거의 없음
<br>

![SampleTestApp](https://github.com/pkh0225/PkhGridView/blob/master/ScreenShot.png)
![SampleTestApp](https://github.com/pkh0225/PkhGridView/blob/master/ScreenShot2.png)

<br>

## Test Code
```

        let texts = ["테스트1","테스트2","테스트3","테스트4","테스트5","테스트6","테스트7","테스트8","테스트9"]

        let gridListData = GridViewListData()
        // 그리드뷰에 셋팅된 뷰를 사용하기에 CellType을 따호 하지 않는다.
        for item in texts {
            let gridViewData = GridViewData()
                .setContentObj(item)
                .setSubData(nil)
                .setActionClosure( { [weak self] (name, object) in
                    guard let self else { return }
                    self.showAlert(name: name, object: object)
                })
            gridListData.itemList.append(gridViewData)
        }

        // 그리드뷰에 셋팅된 뷰를 사용하지 않고 커스트 다른 셀을 추가 한다.
        let gridViewData = GridViewData()
            .setContentObj("CustomView")
            .setSubData(nil)
            .setCellType(TestCellCollectionViewCell2.self)
            .setActionClosure( { [weak self] (name, object) in
                guard let self else { return }
                self.showAlert(name: name, object: object)
            })

        gridListData.itemList.append(gridViewData)


        self.gridView.data = gridListData
//        self.gridView.showLineCount = 1
//        self.gridView.allItemHeightSame = true
        self.gridView.reloadData()
}
```


## Core Functions

```
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
    
    
    
```
