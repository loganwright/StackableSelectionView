//
//  StackableSelectionView.swift
//  StackableSelectionView
//
//  Created by Logan Wright on 8/9/14.
//  Copyright (c) 2014 Intrepid. All rights reserved.
//

import UIKit

class StackableSelectionViewDisplayGridTile: Equatable {
    let row: Int
    let column: Int
    let centerPoint: CGPoint
    let size: CGSize
    var view: UIView?
    
    init(row: Int, column: Int, centerPoint: CGPoint, size: CGSize, view: UIView? = nil) {
        self.row = row
        self.column = column
        self.centerPoint = centerPoint
        self.size = size
        self.view = view
    }
    
}

func == (left: StackableSelectionViewDisplayGridTile, right: StackableSelectionViewDisplayGridTile) -> Bool {
    return (left.row == right.row) && (left.column == right.column)
}
func != (left: StackableSelectionViewDisplayGridTile, right: StackableSelectionViewDisplayGridTile) -> Bool {
    return !(left == right)
}

class StackableSelectionViewDisplayGrid {
    let rows: Int
    let columns: Int
    let frame: CGRect
    var gridTiles: [StackableSelectionViewDisplayGridTile]
    init(rows: Int, columns: Int, frame: CGRect, gridTiles: [StackableSelectionViewDisplayGridTile] = []) {
        self.rows = rows
        self.columns = columns
        self.frame = frame
        self.gridTiles = gridTiles
    }
}

var DisplayGridZero: StackableSelectionViewDisplayGrid {
    return StackableSelectionViewDisplayGrid(rows: 0, columns: 0, frame: CGRectZero)
}

@objc protocol StackableSelectionViewDelegate {
    optional func stackableView(stackableSelectionView: StackableSelectionView, finishedAnimatingWithStatus isOpen: Bool)
    optional func stackableView(stackableSelectionView: StackableSelectionView, didDeselectView view: UIView)
    optional func stackableView(stackableSelectionView: StackableSelectionView, didSelectView view: UIView)
}

class StackableSelectionView: UIView {

    typealias DisplayGrid = StackableSelectionViewDisplayGrid
    typealias GridTile = StackableSelectionViewDisplayGridTile
    
    enum SVAnimationStatus: String {
        case Open = "SVAnimationOpen"
        case Closed = "SVAnimationClose"
    }
    
    // MARK: - Properties
    
    var displayGrid: DisplayGrid = DisplayGridZero {
    didSet {
        self.buildGrid()
    }
    }
    var viewStack: [UIView] = [] {
    didSet {
        self.addTapGesturesToViewStack()
    }
    }
    
    var reverseStack: Bool = false
    var inset: CGFloat = 2.0
    var delegate: StackableSelectionViewDelegate?
    
    private var isOpen: Bool = false
    private var isAnimating: Bool = false
    private var gridTiles: [GridTile] = []
    private var currentlySelectedGridTile: GridTile!

    private var maxCount: Int {
    get {
        return self.viewStack.count < self.gridTiles.count ? self.viewStack.count : self.gridTiles.count
    }
    }
    
    // MARK: - Initialization
    
    init(frame: CGRect = CGRectZero) {
        super.init(frame: frame)
        
        let tap = UITapGestureRecognizer()
        tap.addTarget(self, action: "handleTap:")
        self.addGestureRecognizer(tap)
    }
    
    // MARK: - Property Processing
    
    func addTapGesturesToViewStack() {
        for view in self.viewStack {
            var viewTap = UITapGestureRecognizer(target: self, action: "handleViewTap:")
            view.addGestureRecognizer(viewTap)
        }
        self.addViewsToGrid()
    }
    
    func addViewsToGrid() {
        for i in 0..<self.maxCount {
            var gridTile = self.gridTiles[i]
            gridTile.view = self.viewStack[i]
        }
    }
    
    func buildGrid() {
        let displayGridFrame = self.displayGrid.frame
        let displayGridTotalWidth: CGFloat = CGRectGetWidth(displayGridFrame)
        let displayGridTotalHeight: CGFloat = CGRectGetHeight(displayGridFrame)
        let displayGridOriginY: CGFloat = CGRectGetMinY(displayGridFrame)
        let displayGridOriginX: CGFloat = CGRectGetMinX(displayGridFrame)
        
        let individualWidth: CGFloat = displayGridTotalWidth / CGFloat(self.displayGrid.columns)
        let individualHeight: CGFloat = displayGridTotalHeight / CGFloat(self.displayGrid.rows)
        let individualTileSize = CGSizeMake(individualWidth, individualHeight)
        
        let centerOffsetForFirstRowY: CGFloat = individualHeight / 2.0
        let centerOffsetForFirstColumnX: CGFloat = individualWidth / 2.0
        
        for row in 0..<self.displayGrid.rows {
            let centerOffsetForCurrentRowY: CGFloat = centerOffsetForFirstRowY + (individualHeight * CGFloat(row))
            let actualCenterForCurrentRowY: CGFloat = displayGridOriginY + centerOffsetForCurrentRowY
            
            var newRow: [GridTile] = []
            
            for column in 0..<self.displayGrid.columns {
                let centerOffsetForCurrentColumnX = centerOffsetForFirstColumnX + (individualWidth * CGFloat(column))
                let actualCenterForCurrentColumnX = displayGridOriginX + centerOffsetForCurrentColumnX
                
                let viewIndex = row + column
                var viewToAdd: UIView?
                if viewIndex < self.viewStack.count {
                    viewToAdd = self.viewStack[viewIndex]
                }
                
                let centerPoint = CGPoint(x: actualCenterForCurrentColumnX, y: actualCenterForCurrentRowY)
                let gridTile = GridTile(row: row, column: column, centerPoint: centerPoint, size: individualTileSize, view: viewToAdd)
                newRow.insert(gridTile, atIndex: column)
                self.gridTiles.append(gridTile)
                
                if !self.reverseStack && row == 0 && column == 0 {
                    self.currentlySelectedGridTile = gridTile
                }
                else if row == self.displayGrid.rows - 1 && column == self.displayGrid.columns - 1 {
                    self.currentlySelectedGridTile = gridTile
                }
            }
            
        }
        
    }
    
    // MARK: - Main Tap Gesture
    
    func handleTap(tap: UITapGestureRecognizer) {
        
        if !self.isAnimating {
            if self.isOpen {
                self.isOpen = false
                self.close()
            }
            else {
                self.isOpen = true
                self.open()
            }
        }
    }
    
    // MARK: - Adding / Removing Views
    
    override func didMoveToSuperview()  {
        super.didMoveToSuperview()
        
        if !self.reverseStack {
            for var i = self.viewStack.count - 1; i >= 0; --i {
                if self.superview != nil {
                    self.addViewFromViewStackAtIndex(i)
                }
            }
        }
        else {
            for i in 0..<self.viewStack.count {
                if self.superview != nil {
                    self.addViewFromViewStackAtIndex(i)
                }
            }
        }
        
    }
    
    override func removeFromSuperview() {
        for view in self.viewStack {
            view.removeFromSuperview()
        }
        super.removeFromSuperview()
    }
    
    func addViewFromViewStackAtIndex(index: Int) {
        let view = self.viewStack[index]
        view.frame = self.frame
        view.userInteractionEnabled = false
        view.layer.shouldRasterize = true
        view.layer.rasterizationScale = UIScreen.mainScreen().scale
        self.superview.addSubview(view)
    }
    
    // MARK: - Selection
    
    func handleViewTap(tap: UITapGestureRecognizer) {
        let tappedView = tap.view
        let idx = find(self.viewStack, tappedView)!
        let selectedTile = self.gridTiles[idx]
        let alreadySelected = selectedTile == self.currentlySelectedGridTile
        if !alreadySelected {
            
            let oldView = self.currentlySelectedGridTile.view!
            let oldIndex = find(self.viewStack, oldView)!
            
            self.updateSelection(selectedTile)
            self.delegate?.stackableView?(self, didSelectView: tappedView)
            self.delegate?.stackableView?(self, didDeselectView: oldView)
        }
        
        if self.isOpen {
            self.isOpen = false
            if !self.isAnimating {
                self.close()
            }
        }
        
        
    }
    
    func updateSelection(selectedTile: GridTile) {
        let indexOfNewTile = self.indexOfTile(selectedTile)
        let indexOfCurrentTile = self.indexOfTile(self.currentlySelectedGridTile!)
        self.swapObjectsAtIndexOne(indexOfCurrentTile, andIndexTwo: indexOfNewTile)
    }
    
    func indexOfTile(tile: GridTile) -> Int {
        let offsetPerRow = tile.row * self.displayGrid.columns
        return offsetPerRow + tile.column
    }
    
    func swapObjectsAtIndexOne(indexOne: Int, andIndexTwo indexTwo: Int) {
        let viewOne = self.viewStack[indexOne]
        let viewTwo = self.viewStack[indexTwo]
        self.viewStack[indexOne] = viewTwo
        self.viewStack[indexTwo] = viewOne
        
        var gridTileOne = self.gridTiles[indexOne]
        gridTileOne.view = viewTwo
      
        var gridTileTwo = self.gridTiles[indexTwo]
        gridTileTwo.view = viewOne
        
        self.currentlySelectedGridTile = gridTileOne
        
        let superViewSubviews = self.superview.subviews as [UIView]
        
        let viewOneIndex: Int = find(superViewSubviews, viewOne)!
        let viewTwoIndex: Int = find(superViewSubviews, viewTwo)!
        self.superview.insertSubview(viewTwo, atIndex: viewOneIndex)
        self.superview.insertSubview(viewOne, atIndex: viewTwoIndex)
    }
    
    // MARK: Open | Close
    
    func open() {
        self.isAnimating = true
        let viewCount = self.viewStack.count
        if !reverseStack && viewCount >= 1 {
            for var i = viewCount - 1; i >= 0; --i {
                self.openViewAtIndex(i)
            }
        }
        else {
            self.closeViewAtIndex(self.maxCount - 1)
        }
    }
    
    func close() {
        self.isAnimating = true
        if !self.reverseStack {
            self.closeViewAtIndex(self.maxCount - 1)
        }
        else {
            self.closeViewAtIndex(0)
        }
    }
    
    func closeViewAtIndex(index: Int) {
        if index >= 0 && index < self.maxCount {
            let nameKey = SVAnimationStatus.Closed.toRaw() + "_" + "\(index)"
            
            let view = self.viewStack[index]
            view.userInteractionEnabled = false
            view.pop_removeAllAnimations()
            
            let popSpring = POPSpringAnimation()
            popSpring.property = POPAnimatableProperty.propertyWithName(kPOPViewFrame) as POPAnimatableProperty
            popSpring.name = nameKey
            popSpring.delegate = self
            view.pop_addAnimation(popSpring, forKey: nameKey)
            popSpring.toValue = NSValue(CGRect: self.frame)
        }
        else {
            // finished close
            self.isAnimating = false
            self.delegate?.stackableView?(self, finishedAnimatingWithStatus: self.isOpen)
        }
        
    }
    
    func openViewAtIndex(index: Int) {
        if index >= 0 && index < self.maxCount {
            let gridTile = self.gridTiles[index]

            var targetOrigin = CGPointMake(gridTile.centerPoint.x - (gridTile.size.width / 2.0), gridTile.centerPoint.y - (gridTile.size.height / 2.0))
            var targetSize = gridTile.size
            
            targetOrigin.y += inset
            targetOrigin.x += inset
            targetSize.width -= inset * 2.0
            targetSize.height -= inset * 2.0
            
            let targetRect = CGRect(origin: targetOrigin, size: targetSize)
            
            let nameKey = SVAnimationStatus.Open.toRaw() + "_" + "\(index)"
            
            let view: UIView! = gridTile.view
            view.userInteractionEnabled = true
            
            view.pop_removeAllAnimations()
            
            let popSpring = POPSpringAnimation()
            popSpring.property = POPAnimatableProperty.propertyWithName(kPOPViewFrame) as POPAnimatableProperty
            popSpring.name = nameKey
            popSpring.delegate = self
            popSpring.toValue = NSValue(CGRect: targetRect)
            view.pop_addAnimation(popSpring, forKey: nameKey)
        }
        else {
            // Finished open
            self.isAnimating = false
            self.delegate?.stackableView?(self, finishedAnimatingWithStatus: self.isOpen)
        }
    }
}

extension StackableSelectionView: POPAnimationDelegate {
    
    var minimumProgress: CGFloat {
    get {
        return 0.25
    }
    }
    
    func pop_animationDidApply(anim: POPAnimation!) {
        let currentProgress = anim.currentProgress
        if currentProgress >= minimumProgress {
            let nameComponents: NSArray! = anim.name.componentsSeparatedByString("_")
            let prefix: String = nameComponents.firstObject! as String
            let currentIndex: Int = (nameComponents.lastObject! as String).toInt()!
            
            anim.delegate = nil
            
            if prefix == SVAnimationStatus.Open.toRaw() {
                if self.isOpen {
                    if !reverseStack {
                        self.openViewAtIndex(currentIndex + 1)
                    }
                    else {
                        self.openViewAtIndex(currentIndex - 1)
                    }
                }
                else {
                    self.closeViewAtIndex(currentIndex)
                }
            }
            else if prefix == SVAnimationStatus.Closed.toRaw() {
                if !self.isOpen {
                    if !self.reverseStack {
                        self.closeViewAtIndex(currentIndex - 1)
                    }
                    else {
                        self.closeViewAtIndex(currentIndex + 1)
                    }
                }
                else {
                    self.openViewAtIndex(currentIndex)
                }
            }
        }
    }
}