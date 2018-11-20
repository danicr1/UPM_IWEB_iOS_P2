//
//  ParametricFunctionView.swift
//  Cubo Flotando
//
//  Created by Daniel  on 23/09/2018.
//  Copyright © 2018 UPM. All rights reserved.
//

import UIKit

struct FunctionPoint {
    var x = 0.0
    var y = 0.0
}

protocol ParametricFunctionViewDataSource: class {
    
    func startIndexFor(_ functionView: ParametricFunctionView) -> Double
    func endIndexFor(_ functionView: ParametricFunctionView) -> Double
    
    func functionView(_ functionView: ParametricFunctionView, pointAt index: Double) -> FunctionPoint
    
    func pointsOfInterestFor(_ functionView: ParametricFunctionView) -> [FunctionPoint]
}

@IBDesignable
class ParametricFunctionView: UIView {

    @IBInspectable
    var lineWidth : Double = 3.0
    
    @IBInspectable
    var trajectoryColor : UIColor = UIColor.red
    
    @IBInspectable
    var textX: String = "x"
    
    @IBInspectable
    var textY: String = "y"
    
    // Numero de puntos en el eje X por unidad representada
    @IBInspectable
    var scaleX: Double = 1.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    // Numero de puntos en el eje Y por unidad representada
    @IBInspectable
    var scaleY: Double = 1.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    // Resolucion: Numero de muestras tomadas
    @IBInspectable
    var resolution: Double = 500 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    #if TARGET_INTERFACE_BUILDER
    var dataSource: ParametricFunctionViewDataSource!
    #else
    weak var dataSource: ParametricFunctionViewDataSource!
    #endif
    
    override func prepareForInterfaceBuilder() {
        
        class FakeDataSource: ParametricFunctionViewDataSource {
            
            func startIndexFor(_ functionView: ParametricFunctionView) -> Double {return 0.0}
            
            func endIndexFor(_ functionView: ParametricFunctionView) -> Double {return 5.0}
            
            func functionView(_ functionView: ParametricFunctionView, pointAt index: Double) -> FunctionPoint {
                return FunctionPoint(x: index, y: index)
            }
            
            func pointsOfInterestFor(_ functionView: ParametricFunctionView) -> [FunctionPoint] {
                return []
            }
        }
        
        dataSource = FakeDataSource()
    }
    
  
    override func draw(_ rect: CGRect) {
        print("---DRAW \(self.textY) / \(self.textX)---")
        
        drawAxis()
        drawTicks()
        drawTexts()
        drawTrajectory()
        drawPOI()
    }
 
    // Función que dibuja el eje
    private func drawAxis() {
        
        let width = bounds.size.width
        let height = bounds.size.height
        
        let path1 = UIBezierPath()
        path1.move(to: CGPoint(x: width/2, y: 0))
        path1.addLine(to: CGPoint(x: width/2, y: height))
        
        let path2 = UIBezierPath()
        path2.move(to: CGPoint(x: 0, y: height/2))
        path2.addLine(to: CGPoint(x: width, y: height/2))
        
        UIColor.black.setStroke()
        
        path1.lineWidth = 1
        path1.stroke()
        path2.lineWidth = 1
        path2.stroke()
    }
    
    // Función que dibuja las marcas del eje
    private func drawTicks() {
        
        let numberOfTicks = 8.0
        
        UIColor.blue.set()
        
        let ptsYByTick = Double(bounds.size.height) / numberOfTicks
        let unitsYByTick = (ptsYByTick / scaleY).roundedOneDigit
        for y in stride(from: -numberOfTicks * unitsYByTick, to: numberOfTicks*unitsYByTick, by: unitsYByTick) {
            let px = pointForX(0)
            let py = pointForY(y)
            
            let path = UIBezierPath()
            path.move(to: CGPoint(x: px-2, y: py))
            path.addLine(to: CGPoint(x: px+2, y: py))
            
            path.stroke()
        }
        
        let ptsXByTick = Double(bounds.size.width) / numberOfTicks
        let unitsXByTick = (ptsXByTick / scaleX).roundedOneDigit
        for x in stride(from: -numberOfTicks * unitsXByTick, to: numberOfTicks*unitsXByTick, by: unitsXByTick) {
            let px = pointForX(x)
            let py = pointForY(0)
            
            let path = UIBezierPath()
            path.move(to: CGPoint(x: px, y: py-2))
            path.addLine(to: CGPoint(x: px, y: py+2))
            
            path.stroke()
        }
    }
    
    
    // Función que dibuja los textos de los ejes
    private func drawTexts() {
        
        let width = bounds.size.width
        let height = bounds.size.height
        
        let attrs = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12)]
        
        let offset: CGFloat = 4 // Separacion del texto al eje y al borde
        
        let asX = NSAttributedString(string: textX, attributes: attrs)
        let sizeX = asX.size()
        let posX = CGPoint(x: width - sizeX.width - offset, y: height/2 + offset)
        asX.draw(at: posX)
        
        let asY = NSAttributedString(string: textY, attributes: attrs)
        let posY = CGPoint(x: width/2 + offset, y: offset)
        asY.draw(at: posY)
    }
    
    
    private func drawTrajectory() {
        
        if dataSource == nil {
            return
        }
        
        let startTime = dataSource.startIndexFor(self)
        let endTime = dataSource.endIndexFor(self)
        let incrTime = max((endTime - startTime) / resolution , 0.01)
        //print("\(incrTime)")
        
        let path = UIBezierPath()
        
        var point = dataSource.functionView(self, pointAt: startTime)
        var px = pointForX(point.x)
        var py = pointForY(point.y)
        path.move(to: CGPoint(x: px, y: py))
        
        for t in stride(from: startTime, to: endTime, by: incrTime) {
            point = dataSource.functionView(self, pointAt: t)
            px = pointForX(point.x)
            py = pointForY(point.y)
            path.addLine(to: CGPoint(x: px, y: py))
        }
        
        point = dataSource.functionView(self, pointAt: endTime)
        px = pointForX(point.x)
        py = pointForY(point.y)
        path.move(to: CGPoint(x: px, y: py))
        
        path.lineWidth = CGFloat(lineWidth)
        
        trajectoryColor.set()
        
        path.stroke()
    }
    
    private func drawPOI() {
        
        for p in dataSource.pointsOfInterestFor(self) {
            
            let px = pointForX(p.x)
            let py = pointForY(p.y)
            
            let path = UIBezierPath(ovalIn: CGRect(x: px-4, y: py-4, width: 8, height: 8))
            
            UIColor.blue.setStroke()
            UIColor.white.setFill()
            path.lineWidth = 4
            
            path.stroke()
            path.fill()
        }
        
    }
    
    private func pointForX(_ x: Double) -> CGFloat {
        
        let width = bounds.size.width
        return width/2 + CGFloat(x*scaleX)
    }
    
    private func pointForY(_ y: Double) -> CGFloat {
        
        let height = bounds.size.height
        return height/2 - CGFloat(y*scaleY)
    }
}

extension Double {
    var roundedOneDigit:Double {
        get {
            var d = self
            var by = 1.0
            
            while d > 10 {
                d /= 10
                by = by * 10
            }
            while d < 1 {
                d *= 10
                by = by / 10
            }
            return d.rounded() * by
        }
    }

}
