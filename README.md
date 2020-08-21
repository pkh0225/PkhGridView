# PkhGridView
👻 Easy CollectionViewCell Controller  

## 목표
### cell을 가로로 숫자 지정하여 배열하고 싶을때
### columnCount 숫자에 따라 가로 갯수가 정해지기 때문에 그리드뷰 width 기반으로 cell의 width가 자동으로 늘어남 (가로에 대한 높이 가변 처리는 getGridViewHeight 이용하여 처리 가능함)
 ###columnCount == 0 으로 셋팅시 Cell의 Xib의 Width 크기로대로 Cell의 가로 숫자가 가변으로 지정되어 그려짐 그리드뷰 가로 사이즈를 넘어가면 하단으로 내려감감
 ###GirdView Xib에서 Cell의 이름이나 여려가지 셋팅이 가능하므로 코드가 거의 없음
<br>

![SampleTestApp](https://github.com/pkh0225/PkhGridView/blob/master/ScreenShot.png)
![SampleTestApp](https://github.com/pkh0225/PkhGridView/blob/master/ScreenShot2.png)

<br>

## Test Code 음
```

let texts = ["테스트1","테스트2","테스트3","테스트4","테스트5","테스트6","테스트7","테스트8","테스트9"]
let data = GridViewData(itemList: texts)
gridView.configure(data: data) { (name, object) in
    print(name)
}
```


## Core Functions


```
protocol PkhGridViewCellProtocol: UICollectionViewCell {
    var actionClosure: OnActionClosure? { get set }
    
    static func getGridViewHeight(data: Any?, width: CGFloat) -> CGFloat
    func configure(_ data: Any?)
}


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
```
