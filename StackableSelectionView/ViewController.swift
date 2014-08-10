//
//  ViewController.swift
//  StackableSelectionView
//
//  Created by Logan Wright on 8/9/14.
//  Copyright (c) 2014 Intrepid. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var stackableView: StackableSelectionView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let tap = UITapGestureRecognizer()
        tap.addTarget(self, action: "handleTap:")
        self.view.addGestureRecognizer(tap)
        
        resetStackableView()
    }
    
    func handleTap(tap: UITapGestureRecognizer) {
        resetStackableView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func resetStackableView() {
        stackableView?.removeFromSuperview()

        let originY: CGFloat = 30
        let originX: CGFloat = 10
        let width: CGFloat = 60.0
        let height: CGFloat = 60.0
        let stackableViewFrame = CGRect(x: originX, y: originY, width: width, height: height)
        
        let numberOfRows = 1
        let numberOfColumns = 3
        let displayFrame = CGRect(x: 10 + width + 10, y: originY, width: width * CGFloat(numberOfColumns), height: height)
        let grid: StackableSelectionViewDisplayGrid = StackableSelectionViewDisplayGrid(rows: numberOfRows, columns: numberOfColumns, frame: displayFrame)
        
        let numberOfViews = numberOfRows * numberOfColumns
        
        var viewStack: [UIView] = []
        for i in 1...numberOfViews {
            let label = UILabel()
            label.backgroundColor = UIColor.blackColor()
            label.textColor = [UIColor.whiteColor(), UIColor.blueColor(), UIColor.greenColor()][Int(arc4random_uniform(3))]
            label.adjustsFontSizeToFitWidth = true
            label.font = UIFont.boldSystemFontOfSize(20.0)
            label.text = "\(i)"
            label.textAlignment = NSTextAlignment.Center
            label.layer.cornerRadius = height / 2.0
            label.layer.masksToBounds = true
            viewStack.append(label)
        }
        
        stackableView = StackableSelectionView()
        stackableView!.displayGrid = grid
        stackableView!.viewStack = viewStack
        stackableView!.frame = stackableViewFrame
        stackableView!.backgroundColor = UIColor.darkGrayColor()
        stackableView!.layer.cornerRadius = height / 2.0
        stackableView!.layer.masksToBounds = true
        stackableView!.reverseStack = true
        stackableView!.delegate = self
        self.view.addSubview(stackableView)
        
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

