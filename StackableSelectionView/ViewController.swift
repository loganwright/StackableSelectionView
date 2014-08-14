//
//  ViewController.swift
//  StackableSelectionView
//
//  Created by Logan Wright on 8/9/14.
//  Copyright (c) 2014 Intrepid. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    enum StackableSelectionViewExample: Int {
        case One = 0, Two, Three, Four, Five
        
        mutating func updateForIndex(index: Int) {
            var updatedVersion: StackableSelectionViewExample
            switch index {
            case 0:
                updatedVersion = .One
            case 1:
                updatedVersion = .Two
            case 2:
                updatedVersion = .Three
            case 3:
                updatedVersion = .Four
            case 4:
                updatedVersion = .Five
            default:
                updatedVersion = .One
            }
            self = updatedVersion
        }
    }
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var _stackableView: StackableSelectionView?
    var stackableView: StackableSelectionView? {
    get {
        var currentStackableView: StackableSelectionView? = self._stackableView
        if currentStackableView == nil {
            currentStackableView = StackableSelectionView()
        }
        return currentStackableView!
    }
    set {
        self._stackableView = newValue
    }
    }
    
    var currentExample: StackableSelectionViewExample = .One
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateStackableViewForSegmentedControlIndex(0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Segmented Control

    @IBAction func segmentedControlDidUpdateValue(sender: UISegmentedControl) {
        self.updateStackableViewForSegmentedControlIndex(sender.selectedSegmentIndex)
    }
    
    func updateStackableViewForSegmentedControlIndex(index: Int) {
        self.currentExample.updateForIndex(index)
        
        stackableView?.removeFromSuperview()
        stackableView = StackableSelectionView()
        stackableView!.frame = self.stackableViewFrameForExample(self.currentExample)
        stackableView!.displayGrid = self.stackableViewDisplayGridForExample(self.currentExample)
        
        stackableView!.viewStack = self.viewStackForExample(self.currentExample, numberOfRows: stackableView!.displayGrid.rows, andNumberOfColumns: stackableView!.displayGrid.columns)
        self.stylizeStackableViewForExample(self.currentExample)
        stackableView!.backgroundColor = UIColor.darkGrayColor()
        stackableView!.layer.masksToBounds = true
        stackableView!.delegate = self
        self.view.addSubview(stackableView)
    }
    
    func stylizeStackableViewForExample(example: StackableSelectionViewExample) {
        switch example {
        case .One:
            stackableView!.layer.cornerRadius = stackableView!.frame.size.height / 2.0
            stackableView!.reverseStack = true
        case .Two:
            stackableView!.layer.cornerRadius = stackableView!.frame.size.height / 2.0
            stackableView!.reverseStack = true
        case .Three:
            stackableView!.layer.cornerRadius = 15
            stackableView!.reverseStack = true
        case .Four:
            stackableView!.layer.cornerRadius = 15
            stackableView!.reverseStack = true
        case .Five:
            stackableView!.layer.cornerRadius = stackableView!.frame.size.height / 2.0
            stackableView!.reverseStack = true
        }
    }

    func stackableViewFrameForExample(example: StackableSelectionViewExample) -> CGRect {
        
        var originX: CGFloat
        var originY: CGFloat
        var width: CGFloat
        var height: CGFloat
        
        switch example {
        case .One:
            originX = 10
            originY = 74
            width = 60.0
            height = 60.0
        case .Two:
            originX = 10
            originY = 74
            width = 60.0
            height = 60.0
        case .Three:
            originX = 10
            originY = 74
            width = CGRectGetWidth(self.view.bounds) - (originX * 2)
            height = 40.0
        case .Four:
            originX = 10
            originY = 74
            width = CGRectGetWidth(self.view.bounds) - (originX * 2)
            height = 40.0
        case .Five:
            originX = 10
            originY = 94
            width = 60.0
            height = 60.0
        }
        
        return CGRect(x: originX, y: originY, width: width, height: height)
    }
    
    
    func stackableViewDisplayGridForExample(example: StackableSelectionViewExample) -> StackableSelectionViewDisplayGrid {
        
        var numberOfRows: Int = 0
        var numberOfColumns: Int = 0
        
        var originX: CGFloat
        var originY: CGFloat
        var width: CGFloat
        var height: CGFloat
        
        switch example {
        case .One:
            numberOfRows = 1
            numberOfColumns = 3
            
            let padding: CGFloat = 10
            let currentWidth: CGFloat = CGRectGetWidth(stackableView!.frame)
            
            originX = CGRectGetMaxX(stackableView!.frame) + padding
            originY = CGRectGetMinY(stackableView!.frame)
            width = (CGFloat(currentWidth) * CGFloat(numberOfColumns))
            height = CGRectGetHeight(stackableView!.frame)
        case .Two:
            numberOfRows = 5
            numberOfColumns = 1
            
            let padding: CGFloat = 10
            let currentHeight: CGFloat = CGRectGetWidth(stackableView!.frame)
            
            originX = CGRectGetMinX(stackableView!.frame)
            originY = CGRectGetMaxY(stackableView!.frame) + padding
            width = CGRectGetHeight(stackableView!.frame)
            height = (currentHeight * CGFloat(numberOfRows))
        case .Three:
            numberOfRows = 5
            numberOfColumns = 1
            
            let padding: CGFloat = 10
            let currentWidth: CGFloat = CGRectGetWidth(stackableView!.frame)
            
            originX = CGRectGetMinX(stackableView!.frame)
            originY = CGRectGetMaxY(stackableView!.frame) + padding
            width = CGRectGetWidth(stackableView!.frame)
            height = CGRectGetHeight(stackableView!.frame) * CGFloat(numberOfRows)
        case .Four:
            numberOfRows = 2
            numberOfColumns = 3
            
            let padding: CGFloat = 10
            let currentWidth: CGFloat = CGRectGetWidth(stackableView!.frame)
            
            originX = CGRectGetMinX(stackableView!.frame)
            originY = CGRectGetHeight(self.view.bounds) - CGFloat(padding)
            width = CGRectGetWidth(stackableView!.frame)
            height = -(60 * CGFloat(numberOfRows))
        case .Five:
            numberOfRows = 1
            numberOfColumns = 3
            
            let padding: CGFloat = 10
            let currentWidth: CGFloat = CGRectGetWidth(stackableView!.frame)
            
            originX = CGRectGetMaxX(stackableView!.frame) + padding
            originY = CGRectGetMinY(stackableView!.frame)
            width = (CGFloat(currentWidth) * CGFloat(numberOfColumns))
            height = CGRectGetHeight(stackableView!.frame)
        }
        
        let displayRect: CGRect = CGRect(x: originX, y: originY, width: width, height: height)
        return StackableSelectionViewDisplayGrid(rows: numberOfRows, columns: numberOfColumns, frame: displayRect)
    }
    
    func viewStackForExample(example: StackableSelectionViewExample, numberOfRows: Int, andNumberOfColumns numberOfColumns: Int) -> [UIView] {
        
        var viewStack: [UIView] = []
        let numberOfViews = numberOfRows * numberOfColumns
        
        switch example {
        case .One:
            for i in 1...numberOfViews {
                let label = UILabel()
                label.backgroundColor = UIColor.blackColor()
                label.textColor = [UIColor.whiteColor(), UIColor.blueColor(), UIColor.greenColor()][Int(arc4random_uniform(3))]
                label.adjustsFontSizeToFitWidth = true
                label.font = UIFont.boldSystemFontOfSize(20.0)
                label.text = "\(i)"
                label.textAlignment = NSTextAlignment.Center
                label.layer.cornerRadius = stackableView!.frame.size.height / 2.0
                label.layer.masksToBounds = true
                viewStack.append(label)
            }
        case .Two:
            println(numberOfViews)
            for i in 1...numberOfViews {
                let label = UILabel()
                label.backgroundColor = UIColor.blackColor()
                label.textColor = [UIColor.whiteColor(), UIColor.blueColor(), UIColor.greenColor()][Int(arc4random_uniform(3))]
                label.adjustsFontSizeToFitWidth = true
                label.font = UIFont.boldSystemFontOfSize(20.0)
                label.text = "\(i)"
                label.textAlignment = NSTextAlignment.Center
                label.layer.cornerRadius = stackableView!.frame.size.height / 2.0
                label.layer.masksToBounds = true
                viewStack.append(label)
            }
        case .Three:
            for i in 1...numberOfViews {
                let label = UILabel()
                label.backgroundColor = UIColor.blackColor()
                label.textColor = [UIColor.whiteColor(), UIColor.blueColor(), UIColor.greenColor()][Int(arc4random_uniform(3))]
                label.adjustsFontSizeToFitWidth = true
                label.font = UIFont.boldSystemFontOfSize(20.0)
                label.text = "\(i)"
                label.textAlignment = NSTextAlignment.Center
                label.layer.cornerRadius = 15
                label.layer.masksToBounds = true
                viewStack.append(label)
            }
        case .Four:
            for i in 1...numberOfViews {
                let label = UILabel()
                label.backgroundColor = UIColor.blackColor()
                label.textColor = [UIColor.whiteColor(), UIColor.blueColor(), UIColor.greenColor()][Int(arc4random_uniform(3))]
                label.adjustsFontSizeToFitWidth = true
                label.font = UIFont.boldSystemFontOfSize(20.0)
                label.text = "\(i)"
                label.textAlignment = NSTextAlignment.Center
                label.layer.cornerRadius = stackableView!.frame.size.height / 2.0
                label.layer.masksToBounds = true
                viewStack.append(label)
            }
        case .Five:
            for i in 1...numberOfViews {
                let label = UILabel()
                label.backgroundColor = UIColor.blackColor()
                label.textColor = [UIColor.whiteColor(), UIColor.blueColor(), UIColor.greenColor()][Int(arc4random_uniform(3))]
                label.adjustsFontSizeToFitWidth = true
                label.font = UIFont.boldSystemFontOfSize(20.0)
                label.text = "\(i)"
                label.textAlignment = NSTextAlignment.Center
                label.layer.cornerRadius = stackableView!.frame.size.height / 2.0
                label.layer.masksToBounds = true
                viewStack.append(label)
            }
        }
        
        return viewStack
    }

}

extension ViewController: StackableSelectionViewDelegate {
    func stackableView(stackableSelectionView: StackableSelectionView, finishedAnimatingWithStatus isOpen: Bool) {
        println("Did finish animating")
    }
    func stackableView(stackableSelectionView: StackableSelectionView, didDeselectView view: UIView) {
        println("Did deselect view \((view as UILabel).text)")
    }
    func stackableView(stackableSelectionView: StackableSelectionView, didSelectView view: UIView) {
        println("Did select view \((view as UILabel).text)")
    }
}

