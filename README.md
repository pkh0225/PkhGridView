# PkhGridView
👻 Easy CollectionViewCell Controller  

## 목표
> cell을 가로로 숫자 지정하여 배열하고 싶을때

<br>

![SampleTestApp](https://github.com/pkh0225/PkhGridView/blob/master/ScreenShot.png)
![SampleTestApp](https://github.com/pkh0225/PkhGridView/blob/master/ScreenShot2.png)

<br>

## Core Functions


```

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
