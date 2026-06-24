//
//  MahaPaths.swift
//  MahaPhotoBrowser
//
//  Created by long on 2025/9/25.
//
//  Copyright (c) 2020 Long Zhang <495181165@qq.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit

// MARK: 涂鸦path

public class MahaDrawPath: NSObject {
    private static var pathIndex = 0
    
    private let pathColor: UIColor
    
    private var backgroundPath: UIBezierPath
    
    private let pointScale: CGFloat
    
    private var rawPoints: [CGPoint] = []
    
    let index: Int
    
    var path: UIBezierPath
    
    var isPendingDeletion = false
    
    init(pathColor: UIColor, pathWidth: CGFloat, defaultLinePath: CGFloat, ratio: CGFloat, startPoint: CGPoint) {
        self.pathColor = pathColor
        path = UIBezierPath()
        path.lineWidth = pathWidth / ratio
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        path.move(to: CGPoint(x: startPoint.x / ratio, y: startPoint.y / ratio))
        
        backgroundPath = UIBezierPath()
        backgroundPath.lineWidth = pathWidth / ratio + defaultLinePath
        backgroundPath.lineCapStyle = .round
        backgroundPath.lineJoinStyle = .round
        backgroundPath.move(to: CGPoint(x: startPoint.x / ratio, y: startPoint.y / ratio))
        
        rawPoints.append(startPoint)
        pointScale = ratio
        index = Self.pathIndex
        Self.pathIndex += 1
        
        super.init()
    }
    
    func addLine(to point: CGPoint) {
        rawPoints.append(point)
        
        func scaledPoint(for point: CGPoint) -> CGPoint {
            return CGPoint(x: point.x / pointScale, y: point.y / pointScale)
        }
        
        guard rawPoints.count >= 4 else {
            path.addLine(to: scaledPoint(for: point))
            backgroundPath.addLine(to: scaledPoint(for: point))
            return
        }
        
        path.removeAllPoints()
        backgroundPath.removeAllPoints()
        
        // https://blog.csdn.net/ChasingDreamsCoder/article/details/53015694
        path.move(to: scaledPoint(for: rawPoints[0]))
        path.addLine(to: scaledPoint(for: rawPoints[1]))
        
        backgroundPath.move(to: scaledPoint(for: rawPoints[0]))
        backgroundPath.addLine(to: scaledPoint(for: rawPoints[1]))
        
        let granularity = 4
        for index in 3..<rawPoints.count {
            let p0 = rawPoints[index - 3]
            let p1 = rawPoints[index - 2]
            let p2 = rawPoints[index - 1]
            let p3 = rawPoints[index]
            
            for step in 1..<granularity {
                let t = CGFloat(step) * (1 / CGFloat(granularity))
                let tt = t * t
                let ttt = tt * t

                var interpolatedPoint = CGPoint.zero
                interpolatedPoint.x = 0.5 * (
                    2 * p1.x + (p2.x - p0.x) * t +
                    (2 * p0.x - 5 * p1.x + 4 * p2.x - p3.x) * tt +
                    (3 * p1.x - p0.x - 3 * p2.x + p3.x) * ttt
                )
                interpolatedPoint.y = 0.5 * (
                    2 * p1.y + (p2.y - p0.y) * t +
                    (2 * p0.y - 5 * p1.y + 4 * p2.y - p3.y) * tt +
                    (3 * p1.y - p0.y - 3 * p2.y + p3.y) * ttt
                )
                path.addLine(to: scaledPoint(for: interpolatedPoint))
                backgroundPath.addLine(to: scaledPoint(for: interpolatedPoint))
            }
            
            path.addLine(to: scaledPoint(for: p2))
            backgroundPath.addLine(to: scaledPoint(for: p2))
        }
        
        if let lastPoint = rawPoints.last {
            path.addLine(to: scaledPoint(for: lastPoint))
            backgroundPath.addLine(to: scaledPoint(for: lastPoint))
        }
    }
    
    func drawPath() {
        if isPendingDeletion {
            UIColor.white.set()
            backgroundPath.stroke()
            pathColor.withAlphaComponent(0.7).set()
        } else {
            pathColor.set()
        }
        
        path.stroke()
    }
}

public extension MahaDrawPath {
    static func ==(lhs: MahaDrawPath, rhs: MahaDrawPath) -> Bool {
        return lhs.index == rhs.index
    }
}

// MARK: 马赛克path

public class MahaMosaicPath: NSObject {
    let path: UIBezierPath
    
    let pointScale: CGFloat
    
    let scaledStartPoint: CGPoint
    
    var linePoints: [CGPoint] = []
    
    init(pathWidth: CGFloat, ratio: CGFloat, startPoint: CGPoint) {
        path = UIBezierPath()
        path.lineWidth = pathWidth
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        path.move(to: startPoint)
        
        pointScale = ratio
        scaledStartPoint = CGPoint(x: startPoint.x / ratio, y: startPoint.y / ratio)
        
        super.init()
    }
    
    func addLine(to point: CGPoint) {
        path.addLine(to: point)
        linePoints.append(CGPoint(x: point.x / pointScale, y: point.y / pointScale))
    }
}
