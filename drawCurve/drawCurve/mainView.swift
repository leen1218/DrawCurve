//
//  mainView.swift
//  drawCurve
//
//  Created by en li on 2018/2/10.
//  Copyright © 2018年 xqf. All rights reserved.
//

import Foundation
import UIKit

let originPadding:CGFloat = 50
let curvePointCount = 10


class MyCanvas: UIView, UIGestureRecognizerDelegate {
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.frame = frame
		let tap:UITapGestureRecognizer = UITapGestureRecognizer.init()
		tap.numberOfTapsRequired = 2
		tap.numberOfTouchesRequired = 1
		tap.delegate = self
		tap.addTarget(self, action: #selector(tapAction(action:)))
		self.addGestureRecognizer(tap)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	@objc func tapAction(action:UITapGestureRecognizer) -> Void {
		self.setNeedsDisplay()	// Redraw
	}
	

	
	override func draw(_ rect: CGRect) {
		
		super.draw(rect)
		
		drawTwoStages(rect: rect)
		self.saveToDisk()
	}
	
	func saveToDisk() {
		
		UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
		self.drawHierarchy(in: self.bounds, afterScreenUpdates: false)
		guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
			return
		}
		let imageData: Data! = image.pngData()
		let fileManager = FileManager.default
		let desktopPath = try! fileManager.url(for: .desktopDirectory, in: .allDomainsMask, appropriateFor: nil, create: true)
		let filePath = desktopPath.appendingPathComponent("test.png")
		do {
			try imageData.write(to: filePath, options: .atomic)
		}
		catch {
			print("save file error: \(error)")
		}
	}
	
	func drawTwoStages(rect: CGRect) {
		let context = UIGraphicsGetCurrentContext()
		
		let origin = CGPoint.init(x: originPadding * 3, y: rect.height - originPadding * 3)
		let xaxisLength = rect.width - originPadding * 4
		let yaxisHeight = rect.height - originPadding * 5
		
		// 1. Draw X
		let startX = origin
		let endX = CGPoint.init(x: origin.x + xaxisLength, y: origin.y)
		self.drawAxis(context: context!, start: startX, end: endX, isX: true)
		
		// 2. Draw Y
		let startY = origin
		let endY = CGPoint.init(x: origin.x, y: origin.y - yaxisHeight)
		self.drawAxis(context: context!, start: startY, end: endY, isX: false)
		
		let xdataarea = xaxisLength - 20
		let ydataarea = yaxisHeight - 5
		
		// 3. Draw Stage Line
		// 3.1 Stage 1
		let stage1LeftTop = CGPoint.init(x: origin.x, y: origin.y - ydataarea / 8.0 * 7.0)
		let stage1TopRight = CGPoint.init(x: origin.x + xdataarea / 3.0 * 2.0, y: origin.y - ydataarea / 8.0 * 7.0)
		let stage1RightBottom = CGPoint.init(x: origin.x + xdataarea / 3.0 * 2.0, y: origin.y)
		let stage1LowLeft = CGPoint.init(x: origin.x, y: origin.y - ydataarea / 8.0 * 5.0)
		let stage1LowRight = CGPoint.init(x: origin.x + xdataarea / 3.0 * 2.0, y: origin.y - ydataarea / 8.0 * 5.0)
		self.drawLine(context: context!, start: stage1LeftTop, end: stage1TopRight, color: UIColor.black, isDash: true)
		self.drawLine(context: context!, start: stage1TopRight, end: stage1RightBottom, color: UIColor.black, isDash: true)
		self.drawLine(context: context!, start: stage1LowLeft, end: stage1LowRight, color: UIColor.black, isDash: true)
		
		// 3.2 Stage 2
		let stage2LeftTop = CGPoint.init(x: origin.x + xdataarea / 3.0 * 2.0, y: origin.y - ydataarea / 8.0 * 4.0)
		let stage2TopRight = CGPoint.init(x: origin.x + xdataarea, y: origin.y - ydataarea / 8.0 * 4.0)
		let stage2RightBottom = CGPoint.init(x: origin.x + xdataarea, y: origin.y)
		let stage2LowLeft = CGPoint.init(x: origin.x + xdataarea / 3.0 * 2.0, y: origin.y - ydataarea / 8.0 * 2.0)
		let stage2LowRight = CGPoint.init(x: origin.x + xdataarea, y: origin.y - ydataarea / 8.0 * 2.0)
		self.drawLine(context: context!, start: stage2LeftTop, end: stage2TopRight, color: UIColor.black, isDash: true)
		self.drawLine(context: context!, start: stage2TopRight, end: stage2RightBottom, color: UIColor.black, isDash: true)
		self.drawLine(context: context!, start: stage2LowLeft, end: stage2LowRight, color: UIColor.black, isDash: true)
		
		// 4 Draw avg line
		let stage1AvgLeft = CGPoint.init(x: origin.x, y: origin.y - ydataarea / 8.0 * 6.0)
		let stage1AvgRight = CGPoint.init(x: origin.x + xdataarea / 3.0 * 2.0, y: origin.y - ydataarea / 8.0 * 6.0)
		self.drawLine(context: context!, start: stage1AvgLeft, end: stage1AvgRight, color: UIColor.red, isDash: true)
		let stage2AvgLeft = CGPoint.init(x: origin.x + xdataarea / 3.0 * 2.0, y: origin.y - ydataarea / 8.0 * 3.0)
		let stage2AvgRight = CGPoint.init(x: origin.x + xdataarea, y: origin.y - ydataarea / 8.0 * 3.0)
		self.drawLine(context: context!, start: stage2AvgLeft, end: stage2AvgRight, color: UIColor.red, isDash: true)
		
		// 5. Draw W constant line
		let startW = CGPoint.init(x: origin.x, y: origin.y - ydataarea / 8.0)
		let endW = CGPoint.init(x: origin.x + xdataarea, y: origin.y - ydataarea / 8.0)
		self.drawLine(context: context!, start: startW, end: endW)
		
		// 6. Draw Label
		let BigLetterSize = CGSize.init(width: 20, height: 20)
		let BigLetterFont = UIFont.italicSystemFont(ofSize: 15)
		let SmallLetterSize = CGSize.init(width: 10, height: 10)
		let SmallLetterFont = UIFont.italicSystemFont(ofSize: 10)
		
		// Y Label
		let retailer_price = "retail price"
		let YLabel = CGRect.init(origin: CGPoint.init(x: origin.x - 90, y: endY.y + 5), size: CGSize.init(width: 100, height: 20))
		self.drawLable(context: context!, frame: YLabel, lableStr: retailer_price, font: BigLetterFont)
		let XLabel = CGRect.init(origin: CGPoint.init(x: endX.x - 25, y: endX.y + 5), size: BigLetterSize)
		self.drawLable(context: context!, frame: XLabel, lableStr: "t", font: BigLetterFont)
		
		let discountPointLabel = "discount point"
		let discountFrame = CGRect.init(origin: CGPoint.init(x: origin.x + xdataarea / 3.0, y: endX.y + 5), size: CGSize.init(width: xdataarea / 3.0 * 2.0, height: 30))
		self.drawLable(context: context!, frame: discountFrame, lableStr: discountPointLabel, font: BigLetterFont)
		
		let WLabel = CGRect.init(origin: CGPoint.init(x: startW.x - 25, y: startW.y - 10), size: BigLetterSize)
		self.drawLable(context: context!, frame: WLabel, lableStr: "w", font: BigLetterFont)
		
		
		// E(y)
		let iyta = "η"
		let xoffset: CGFloat = 9
		let yoffset: CGFloat = 9
		// Stage 1 High
		let Stage1HighLabel = CGRect.init(origin: CGPoint.init(x: origin.x - 20 - xoffset, y: stage1LeftTop.y - yoffset), size: BigLetterSize)
		self.drawLable(context: context!, frame: Stage1HighLabel, lableStr: iyta, font: BigLetterFont)
		let Stage1HighLabelH = CGRect.init(origin: CGPoint.init(x: origin.x - 6 - xoffset, y: stage1LeftTop.y + 2 - yoffset), size: SmallLetterSize)
		self.drawLable(context: context!, frame: Stage1HighLabelH, lableStr: "h", font: SmallLetterFont)
		let Stage1HighLabelL = CGRect.init(origin: CGPoint.init(x: origin.x - 6 - xoffset, y: stage1LeftTop.y + 13 - yoffset), size: SmallLetterSize)
		self.drawLable(context: context!, frame: Stage1HighLabelL, lableStr: "1", font: SmallLetterFont)
		// Stage 1 Low
		let Stage1LowLabel = CGRect.init(origin: CGPoint.init(x: origin.x - 20 - xoffset, y: stage1LowLeft.y - yoffset), size: BigLetterSize)
		self.drawLable(context: context!, frame: Stage1LowLabel, lableStr: iyta, font: BigLetterFont)
		let Stage1LowLabelH = CGRect.init(origin: CGPoint.init(x: origin.x - 6 - xoffset, y: stage1LowLeft.y + 2 - yoffset), size: SmallLetterSize)
		self.drawLable(context: context!, frame: Stage1LowLabelH, lableStr: "l", font: SmallLetterFont)
		let Stage1LowLabelL = CGRect.init(origin: CGPoint.init(x: origin.x - 6 - xoffset, y: stage1LowLeft.y + 15 - yoffset), size: SmallLetterSize)
		self.drawLable(context: context!, frame: Stage1LowLabelL, lableStr: "1", font: SmallLetterFont)
		
		// Stage 2 High
		let Stage2HighLabel = CGRect.init(origin: CGPoint.init(x: stage2LeftTop.x - 20 - xoffset, y: stage2LeftTop.y - yoffset), size: BigLetterSize)
		self.drawLable(context: context!, frame: Stage2HighLabel, lableStr: iyta, font: BigLetterFont)
		let Stage2HighLabelH = CGRect.init(origin: CGPoint.init(x: stage2LeftTop.x - 6 - xoffset, y: stage2LeftTop.y + 2 - yoffset), size: SmallLetterSize)
		self.drawLable(context: context!, frame: Stage2HighLabelH, lableStr: "h", font: SmallLetterFont)
		let Stage2HighLabelL = CGRect.init(origin: CGPoint.init(x: stage2LeftTop.x - 6 - xoffset, y: stage2LeftTop.y + 13 - yoffset), size: SmallLetterSize)
		self.drawLable(context: context!, frame: Stage2HighLabelL, lableStr: "2", font: SmallLetterFont)
		// Stage 2 Low
		let Stage2LowLabel = CGRect.init(origin: CGPoint.init(x: stage2LowLeft.x - 20 - xoffset, y: stage2LowLeft.y - yoffset), size: BigLetterSize)
		self.drawLable(context: context!, frame: Stage2LowLabel, lableStr: iyta, font: BigLetterFont)
		let Stage2LowLabelH = CGRect.init(origin: CGPoint.init(x: stage2LowLeft.x - 6 - xoffset, y: stage2LowLeft.y + 2 - yoffset), size: SmallLetterSize)
		self.drawLable(context: context!, frame: Stage2LowLabelH, lableStr: "l", font: SmallLetterFont)
		let Stage2LowLabelL = CGRect.init(origin: CGPoint.init(x: stage2LowLeft.x - 6 - xoffset, y: stage2LowLeft.y + 15 - yoffset), size: SmallLetterSize)
		self.drawLable(context: context!, frame: Stage2LowLabelL, lableStr: "2", font: SmallLetterFont)
		
		// Avg Label
		let state1AvgLabel = "normal level"
		let state1AvgLabelFrame = CGRect.init(origin: CGPoint.init(x: stage2LeftTop.x - 105, y: stage1AvgRight.y - 25), size: CGSize.init(width: 100, height: 20))
		self.drawLable(context: context!, frame: state1AvgLabelFrame, lableStr: state1AvgLabel, font: BigLetterFont, color: UIColor.red)
		
		let state2AvgLabel = "discount level"
		let state2AvgLabelFrame = CGRect.init(origin: CGPoint.init(x: stage2LeftTop.x + 5, y: stage2AvgLeft.y - 25), size: CGSize.init(width: 100, height: 20))
		self.drawLable(context: context!, frame: state2AvgLabelFrame, lableStr: state2AvgLabel, font: BigLetterFont, color: UIColor.red)

		
		self.drawRandomCurveWithTwoStages(context: context!, stage1leftTop: stage1LeftTop, stage1rightBottom: stage1LowRight, stage2leftTop: stage2LeftTop, stage2rightBottom: stage2LowRight)
	}
	
	func drawThreeStages(rect: CGRect) {
		let context = UIGraphicsGetCurrentContext()
		
		let origin = CGPoint.init(x: originPadding, y: rect.height - originPadding * 3)
		let xaxisLength = rect.width - originPadding * 2
		let yaxisHeight = rect.height - originPadding * 5
		
		// 1. Draw X
		let startX = origin
		let endX = CGPoint.init(x: origin.x + xaxisLength, y: origin.y)
		self.drawAxis(context: context!, start: startX, end: endX, isX: true)
		
		// 2. Draw Y
		let startY = origin
		let endY = CGPoint.init(x: origin.x, y: origin.y - yaxisHeight)
		self.drawAxis(context: context!, start: startY, end: endY, isX: false)
		
		let xdataarea = xaxisLength - 20
		let ydataarea = yaxisHeight - 5
		
		// 3. Draw Stage Line
		// 3.1 Stage 1
		let stage1LeftTop = CGPoint.init(x: origin.x, y: origin.y - ydataarea / 8.0 * 7.0)
		let stage1TopRight = CGPoint.init(x: origin.x + xdataarea / 3.0, y: origin.y - ydataarea / 8.0 * 7.0)
		let stage1RightBottom = CGPoint.init(x: origin.x + xdataarea / 3.0, y: origin.y)
		let stage1LowLeft = CGPoint.init(x: origin.x, y: origin.y - ydataarea / 8.0 * 5.0)
		let stage1LowRight = CGPoint.init(x: origin.x + xdataarea / 3.0, y: origin.y - ydataarea / 8.0 * 5.0)
		self.drawLine(context: context!, start: stage1LeftTop, end: stage1TopRight, color: UIColor.black, isDash: true)
		self.drawLine(context: context!, start: stage1TopRight, end: stage1RightBottom, color: UIColor.black, isDash: true)
		self.drawLine(context: context!, start: stage1LowLeft, end: stage1LowRight, color: UIColor.black, isDash: true)
		
		// 3.2 Stage 2
		let stage2LeftTop = CGPoint.init(x: origin.x + xdataarea / 3.0, y: origin.y - ydataarea / 8.0 * 4.0)
		let stage2TopRight = CGPoint.init(x: origin.x + xdataarea / 3.0 * 2.0, y: origin.y - ydataarea / 8.0 * 4.0)
		let stage2RightBottom = CGPoint.init(x: origin.x + xdataarea / 3.0 * 2.0, y: origin.y)
		let stage2LowLeft = CGPoint.init(x: origin.x + xdataarea / 3.0, y: origin.y - ydataarea / 8.0 * 2.0)
		let stage2LowRight = CGPoint.init(x: origin.x + xdataarea / 3.0 * 2.0, y: origin.y - ydataarea / 8.0 * 2.0)
		self.drawLine(context: context!, start: stage2LeftTop, end: stage2TopRight, color: UIColor.black, isDash: true)
		self.drawLine(context: context!, start: stage2TopRight, end: stage2RightBottom, color: UIColor.black, isDash: true)
		self.drawLine(context: context!, start: stage2LowLeft, end: stage2LowRight, color: UIColor.black, isDash: true)
		
		// 3.3 Stage 3
		let stage3LeftTop = CGPoint.init(x: origin.x + xdataarea / 3.0 * 2.0, y: origin.y - ydataarea / 8.0)
		let stage3TopRight = CGPoint.init(x: origin.x + xdataarea, y: origin.y - ydataarea / 8.0)
		let stage3RightBottom = CGPoint.init(x: origin.x + xdataarea, y: origin.y)
		self.drawLine(context: context!, start: stage3TopRight, end: stage3RightBottom, color: UIColor.black, isDash: true)
		self.drawLine(context: context!, start: stage3LeftTop, end: stage3TopRight)
		
		// 4. Draw stage interval
		let stage1IntervalLow = CGPoint.init(x: origin.x + xdataarea / 3.0 / 5.0, y: stage1LowLeft.y)
		let stage1IntervalHigh = CGPoint.init(x: origin.x + xdataarea / 3.0 / 5.0, y: stage1LeftTop.y)
		self.drawDualArrowLine(context: context!, start: stage1IntervalLow, end: stage1IntervalHigh)
		let stage2IntervalLow = CGPoint.init(x: origin.x + xdataarea / 3.0 + xdataarea / 3.0 / 5.0, y: stage2LowLeft.y)
		let stage2IntervalHigh = CGPoint.init(x: origin.x + xdataarea / 3.0 + xdataarea / 3.0 / 5.0, y: stage2LeftTop.y)
		self.drawDualArrowLine(context: context!, start: stage2IntervalLow, end: stage2IntervalHigh)
		
		// 5 Draw avg line
		let stage1AvgLeft = CGPoint.init(x: origin.x, y: origin.y - ydataarea / 8.0 * 6.0)
		let stage1AvgRight = CGPoint.init(x: origin.x + xdataarea / 3.0, y: origin.y - ydataarea / 8.0 * 6.0)
		self.drawLine(context: context!, start: stage1AvgLeft, end: stage1AvgRight, color: UIColor.red, isDash: true)
		let stage2AvgLeft = CGPoint.init(x: origin.x + xdataarea / 3.0, y: origin.y - ydataarea / 8.0 * 3.0)
		let stage2AvgRight = CGPoint.init(x: origin.x + xdataarea / 3.0 * 2.0, y: origin.y - ydataarea / 8.0 * 3.0)
		self.drawLine(context: context!, start: stage2AvgLeft, end: stage2AvgRight, color: UIColor.red, isDash: true)
		
		// 6. Draw Label
		let stage1Str = "Stage 1: original price fluctuation"
		let stage1LabelFrame = CGRect.init(origin: CGPoint.init(x: origin.x, y: origin.y), size: CGSize.init(width: xdataarea / 3.0, height: 30))
		self.drawLable(context: context!, frame: stage1LabelFrame, lableStr: stage1Str)
		let stage2Str = "Stage 2: discounted fluctuation"
		let stage2LabelFrame = CGRect.init(origin: CGPoint.init(x: origin.x + xdataarea / 3.0, y: origin.y), size: CGSize.init(width: xdataarea / 3.0, height: 30))
		self.drawLable(context: context!, frame: stage2LabelFrame, lableStr: stage2Str)
		let stage3Str = "Disposal stage"
		let stage3LabelFrame = CGRect.init(origin: CGPoint.init(x: origin.x + xdataarea / 3.0 * 2.0, y: origin.y), size: CGSize.init(width: xdataarea / 3.0, height: 30))
		self.drawLable(context: context!, frame: stage3LabelFrame, lableStr: stage3Str)
		
		let BigLetterSize = CGSize.init(width: 20, height: 20)
		let BigLetterFont = UIFont.italicSystemFont(ofSize: 15)
		let SmallLetterSize = CGSize.init(width: 10, height: 10)
		let SmallLetterFont = UIFont.italicSystemFont(ofSize: 10)
		
		// Y Label
		let iyta = "η"
		let YLabel = CGRect.init(origin: CGPoint.init(x: origin.x - 25, y: endY.y + 5), size: BigLetterSize)
		self.drawLable(context: context!, frame: YLabel, lableStr: iyta, font: BigLetterFont)
		let XLabel = CGRect.init(origin: CGPoint.init(x: endX.x - 25, y: endX.y + 5), size: BigLetterSize)
		self.drawLable(context: context!, frame: XLabel, lableStr: "t", font: BigLetterFont)
		// Stage 1 High
		let Stage1HighLabel = CGRect.init(origin: CGPoint.init(x: stage1IntervalHigh.x - 20, y: stage1IntervalHigh.y - 25), size: BigLetterSize)
		self.drawLable(context: context!, frame: Stage1HighLabel, lableStr: iyta, font: BigLetterFont)
		let Stage1HighLabelH = CGRect.init(origin: CGPoint.init(x: stage1IntervalHigh.x - 6, y: stage1IntervalHigh.y - 23), size: SmallLetterSize)
		self.drawLable(context: context!, frame: Stage1HighLabelH, lableStr: "h", font: SmallLetterFont)
		let Stage1HighLabelL = CGRect.init(origin: CGPoint.init(x: stage1IntervalHigh.x - 6, y: stage1IntervalHigh.y - 12), size: SmallLetterSize)
		self.drawLable(context: context!, frame: Stage1HighLabelL, lableStr: "1", font: SmallLetterFont)
		// Stage 1 Low
		let Stage1LowLabel = CGRect.init(origin: CGPoint.init(x: stage1IntervalLow.x - 20, y: stage1IntervalLow.y + 5), size: BigLetterSize)
		self.drawLable(context: context!, frame: Stage1LowLabel, lableStr: iyta, font: BigLetterFont)
		let Stage1LowLabelH = CGRect.init(origin: CGPoint.init(x: stage1IntervalLow.x - 6, y: stage1IntervalLow.y + 7), size: SmallLetterSize)
		self.drawLable(context: context!, frame: Stage1LowLabelH, lableStr: "l", font: SmallLetterFont)
		let Stage1LowLabelL = CGRect.init(origin: CGPoint.init(x: stage1IntervalLow.x - 6, y: stage1IntervalLow.y + 20), size: SmallLetterSize)
		self.drawLable(context: context!, frame: Stage1LowLabelL, lableStr: "1", font: SmallLetterFont)
		
		// Stage 2 High
		let Stage2HighLabel = CGRect.init(origin: CGPoint.init(x: stage2IntervalHigh.x - 20, y: stage2IntervalHigh.y - 25), size: BigLetterSize)
		self.drawLable(context: context!, frame: Stage2HighLabel, lableStr: iyta, font: BigLetterFont)
		let Stage2HighLabelH = CGRect.init(origin: CGPoint.init(x: stage2IntervalHigh.x - 6, y: stage2IntervalHigh.y - 23), size: SmallLetterSize)
		self.drawLable(context: context!, frame: Stage2HighLabelH, lableStr: "h", font: SmallLetterFont)
		let Stage2HighLabelL = CGRect.init(origin: CGPoint.init(x: stage2IntervalHigh.x - 6, y: stage2IntervalHigh.y - 12), size: SmallLetterSize)
		self.drawLable(context: context!, frame: Stage2HighLabelL, lableStr: "2", font: SmallLetterFont)
		// Stage 2 Low
		let Stage2LowLabel = CGRect.init(origin: CGPoint.init(x: stage2IntervalLow.x - 20, y: stage2IntervalLow.y + 5), size: BigLetterSize)
		self.drawLable(context: context!, frame: Stage2LowLabel, lableStr: iyta, font: BigLetterFont)
		let Stage2LowLabelH = CGRect.init(origin: CGPoint.init(x: stage2IntervalLow.x - 6, y: stage2IntervalLow.y + 7), size: SmallLetterSize)
		self.drawLable(context: context!, frame: Stage2LowLabelH, lableStr: "l", font: SmallLetterFont)
		let Stage2LowLabelL = CGRect.init(origin: CGPoint.init(x: stage2IntervalLow.x - 6, y: stage2IntervalLow.y + 20), size: SmallLetterSize)
		self.drawLable(context: context!, frame: Stage2LowLabelL, lableStr: "2", font: SmallLetterFont)
		
		// Stage 3 Ch
		let Stage3Label = CGRect.init(origin: CGPoint.init(x: stage3LeftTop.x + xdataarea / 6.0, y: stage3LeftTop.y - 25), size: BigLetterSize)
		self.drawLable(context: context!, frame: Stage3Label, lableStr: "c", font: BigLetterFont)
		let Stage3LabelL = CGRect.init(origin: CGPoint.init(x: stage3LeftTop.x + xdataarea / 6.0 + 12, y: stage3LeftTop.y - 12), size: SmallLetterSize)
		self.drawLable(context: context!, frame: Stage3LabelL, lableStr: "h", font: SmallLetterFont)
		
		// E(y)
		let Stage1EStr = "E(η )"
		let ESize = CGSize.init(width: 50, height: 50)
		let Stage1ELabel = CGRect.init(origin: CGPoint.init(x: stage1AvgLeft.x + xdataarea / 6.0 + 10, y: stage1AvgLeft.y - 40), size: ESize)
		let EFont = UIFont.italicSystemFont(ofSize: 16)
		self.drawLable(context: context!, frame: Stage1ELabel, lableStr: Stage1EStr, font: EFont)
		let Stage1ELow = CGRect.init(origin: CGPoint.init(x: stage1AvgLeft.x + xdataarea / 6.0 + 38, y: stage1AvgLeft.y - 12), size: SmallLetterSize)
		self.drawLable(context: context!, frame: Stage1ELow, lableStr: "1", font: SmallLetterFont)
		
		let Stage2ELabel = CGRect.init(origin: CGPoint.init(x: stage2AvgLeft.x + xdataarea / 6.0 + 10, y: stage2AvgLeft.y - 40), size: ESize)
		self.drawLable(context: context!, frame: Stage2ELabel, lableStr: Stage1EStr, font: EFont)
		let Stage2ELow = CGRect.init(origin: CGPoint.init(x: stage2AvgLeft.x + xdataarea / 6.0 + 38, y: stage2AvgLeft.y - 12), size: SmallLetterSize)
		self.drawLable(context: context!, frame: Stage2ELow, lableStr: "2", font: SmallLetterFont)
		
		
		// 7. Draw Stage 1 Curve
		//self.drawRandomCurve(context: context!, leftTop: stage1LeftTop, rightBottom: stage1LowRight, isStage1: true)
		
		// 8. Draw Stage 2 Curve
		//self.drawRandomCurve(context: context!, leftTop: stage2LeftTop, rightBottom: stage2LowRight, isStage1: false)
		self.drawRandomCurveWithTwoStages(context: context!, stage1leftTop: stage1LeftTop, stage1rightBottom: stage1LowRight, stage2leftTop: stage2LeftTop, stage2rightBottom: stage2LowRight)
	}
	
	func drawLable(context: CGContext, frame: CGRect, lableStr: String, font: UIFont) {
		let label = UILabel(frame: frame)
		label.text = lableStr
		label.font = font
		label.textAlignment = .center
		self.addSubview(label);
	}
	
	func drawLable(context: CGContext, frame: CGRect, lableStr: String, font: UIFont, color: UIColor) {
		let label = UILabel(frame: frame)
		label.text = lableStr
		label.font = font
		label.textColor = color
		label.textAlignment = .center
		self.addSubview(label);
	}
	
	func drawLable(context: CGContext, frame: CGRect, lableStr: String) {
		let label = UILabel(frame: frame)
		label.text = lableStr
		label.textAlignment = .center
		self.addSubview(label);
	}
	
	func drawRandomCurveWithTwoStages(context: CGContext, stage1leftTop: CGPoint, stage1rightBottom: CGPoint, stage2leftTop: CGPoint, stage2rightBottom: CGPoint) {
		let Stage1YMin = stage1leftTop.y
		let Stage1YMax = stage1rightBottom.y
		let Stage2YMin = stage2leftTop.y
		let Stage2YMax = stage2rightBottom.y
		let XRange = stage2rightBottom.x - stage1leftTop.x
		
		
		let path = UIBezierPath()
		var startP = CGPoint.init(x: stage1leftTop.x, y: self.randomNum(low: Stage1YMin, High: Stage1YMax))
		path.move(to: startP)
		for i in 1...(curvePointCount * 2 + 1)
		{
			var endP = CGPoint.init(x: stage1leftTop.x + XRange * CGFloat(i) / CGFloat(curvePointCount * 2 + 1), y: self.randomNum(low: Stage1YMin, High: Stage1YMax))
			if (i > 14) {
				endP.y = self.randomNum(low: Stage2YMin, High: Stage2YMax)
			}
			if (i == 6) {
				endP.y = Stage1YMin
			}
			if (i == 11) {
				endP.y = Stage1YMax
			}
			if (i == 18) {
				endP.y = Stage2YMax
			}
			
			if (i == 15) {
				startP.y = self.randomNum(low: Stage2YMin, High: Stage2YMax)
				path.move(to: startP)
			}
			
			self.addBezierCurve(path: path, start: startP, end: endP)
			startP = endP
		}
		context.setStrokeColor(UIColor.black.cgColor)
		path.stroke()
	}
	
	func drawRandomCurve(context: CGContext, leftTop: CGPoint, rightBottom: CGPoint, isStage1: Bool) {
		let YMin = leftTop.y
		let YMax = rightBottom.y
		let XRange = rightBottom.x - leftTop.x
		
		
		let path = UIBezierPath()
		var startP = CGPoint.init(x: leftTop.x, y: self.randomNum(low: YMin, High: YMax))
		if (!isStage1) {
			startP.y = YMin
		}
		path.move(to: startP)
		var endP = CGPoint.init(x: leftTop.x + XRange / CGFloat(curvePointCount), y: self.randomNum(low: YMin, High: YMax))
		self.addBezierCurve(path: path, start: startP, end: endP)
		for i in 2...curvePointCount
		{
			startP = endP
			if (i == curvePointCount && isStage1) {
				endP = CGPoint.init(x: leftTop.x + XRange * CGFloat(i) / CGFloat(curvePointCount), y: YMax)
			} else {
				endP = CGPoint.init(x: leftTop.x + XRange * CGFloat(i) / CGFloat(curvePointCount), y: self.randomNum(low: YMin, High: YMax))
			}
			if (isStage1 && i == 6) {
				endP.y = YMin
			}
			if (!isStage1 && i == 3) {
				endP.y = YMax
			}
			self.addBezierCurve(path: path, start: startP, end: endP)
		}
		context.setStrokeColor(UIColor.black.cgColor)
		path.stroke()
	}
	
	func addBezierCurve(path: UIBezierPath, start: CGPoint, end: CGPoint) {
		let controlP1 = CGPoint.init(x: (start.x + end.x) / 2.0, y: start.y)
		let controlP2 = CGPoint.init(x: (start.x + end.x) / 2.0, y: end.y)
		path.addCurve(to: end, controlPoint1: controlP1, controlPoint2: controlP2)
	}
	
	func randomNum(low: CGFloat, High: CGFloat) -> CGFloat {
		return CGFloat(Float(arc4random()) / Float(UINT32_MAX)) * (High - low) + low
	}
	
	func drawLine(context: CGContext, start: CGPoint, end: CGPoint, color : UIColor, isDash: Bool) {
		// Draw line
		let path = CGMutablePath()
		path.move(to: start)
		path.addLine(to: end)
		
		context.addPath(path)
		
		context.saveGState()
		
		context.setStrokeColor(color.cgColor)
		if (isDash) {
			let lengths:[CGFloat] = [10,10]
			context.setLineDash(phase: 0, lengths: lengths)
		}
		context.setStrokeColor(color.cgColor)
		context.drawPath(using: CGPathDrawingMode.stroke)
		
		context.restoreGState()
	}
	
	func drawLine(context: CGContext, start: CGPoint, end: CGPoint) {
		self.drawLine(context: context, start: start, end: end, color: UIColor.black, isDash: false)
	}
	
	func drawAxis(context: CGContext, start: CGPoint, end: CGPoint, isX: Bool) {
		
		self.drawLine(context: context, start: start, end: end)
		
		// Draw arrow
		let arrowOffset:CGFloat = 5
		if (isX) {
			let arrowStart = CGPoint.init(x: end.x - arrowOffset, y: end.y - arrowOffset)
			let arrowMid = end
			let arrowEnd = CGPoint.init(x: end.x - arrowOffset, y: end.y + arrowOffset)
			
			let path = CGMutablePath()
			path.move(to: arrowStart)
			path.addLine(to: arrowMid)
			path.addLine(to: arrowEnd)
			
			context.addPath(path)
			context.setStrokeColor(UIColor.black.cgColor)
			context.drawPath(using: CGPathDrawingMode.stroke)
		} else {
			let arrowStart = CGPoint.init(x: end.x - arrowOffset, y: end.y + arrowOffset)
			let arrowMid = end
			let arrowEnd = CGPoint.init(x: end.x + arrowOffset, y: end.y + arrowOffset)
			
			let path = CGMutablePath()
			path.move(to: arrowStart)
			path.addLine(to: arrowMid)
			path.addLine(to: arrowEnd)
			
			context.addPath(path)
			context.setStrokeColor(UIColor.black.cgColor)
			context.drawPath(using: CGPathDrawingMode.stroke)
		}
	}
	func drawDualArrowLine(context: CGContext, start: CGPoint, end: CGPoint) {
		
		self.drawLine(context: context, start: start, end: end)
		
		let arrowOffset:CGFloat = 5
		// Draw arrow 1
		let arrowStart = CGPoint.init(x: start.x - arrowOffset, y: start.y - arrowOffset)
		let arrowMid = start
		let arrowEnd = CGPoint.init(x: start.x + arrowOffset, y: start.y - arrowOffset)
		
		let path = CGMutablePath()
		path.move(to: arrowStart)
		path.addLine(to: arrowMid)
		path.addLine(to: arrowEnd)
		
		context.addPath(path)
		context.drawPath(using: CGPathDrawingMode.stroke)
		
		// Draw arrow 2
		let arrow2Start = CGPoint.init(x: end.x - arrowOffset, y: end.y + arrowOffset)
		let arrow2Mid = end
		let arrow2End = CGPoint.init(x: end.x + arrowOffset, y: end.y + arrowOffset)
		
		let path2 = CGMutablePath()
		path2.move(to: arrow2Start)
		path2.addLine(to: arrow2Mid)
		path2.addLine(to: arrow2End)
		
		context.addPath(path2)
		context.drawPath(using: CGPathDrawingMode.stroke)
	}

}
