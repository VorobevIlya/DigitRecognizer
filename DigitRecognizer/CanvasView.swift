//
//  CanvasView.swift
//  DigitRecognizer
//
//  Created by Илья Воробьев on 14.10.2022.
//

import Foundation
import UIKit

class CanvasView: UIView {
    
    var lines: [[CGPoint]] = []
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        lines.append([CGPoint]())
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else { return }
        
        guard var lastLine = lines.popLast() else { return }
        lastLine.append(point)
        lines.append(lastLine)
        
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        
        ctx.setStrokeColor(UIColor.white.cgColor)
        ctx.setLineWidth(15)
        ctx.setLineCap(.round)
        
        for line in lines {
            for (index, point) in line.enumerated() {
                if index == 0 {
                    ctx.move(to: point)
                } else {
                    ctx.addLine(to: point)
                }
            }
        }
 
        ctx.strokePath()
    }
    
    func clear() {
        lines.removeAll()
        setNeedsDisplay()
    }
    
    func getImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: bounds.size)
        let image = renderer.image { ctx in
            drawHierarchy(in: bounds, afterScreenUpdates: true)
        }
        return image
    }
}
