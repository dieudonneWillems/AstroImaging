//
//  ASImage.swift
//  AstroImaging
//
//  Created by Don Willems on 09/02/2020.
//  Copyright © 2020 lapsedpacifist. All rights reserved.
//

import Foundation
import AppKit
import MetalPerformanceShaders

public class ASImage {
    
    private let matrix : MPSMatrix
    
    public var size : NSSize {
        get {
            return NSSize(width: width, height: height)
        }
    }
    
    private let width : Int
    private let height : Int
    
    public static func extractChannels(from image: NSImage) -> [ASImage]? {
        let imageData = image.tiffRepresentation
        //let hasAlpha = image.representations[0].hasAlpha
        guard let source = CGImageSourceCreateWithData(imageData! as CFData, nil) else { return nil }
        let cgimage = CGImageSourceCreateImageAtIndex(source, 0, nil)
        return cgimage == nil ? nil : ASImage.extractChannels(from: cgimage!)
    }
    
    public static func extractChannels(from image: CGImage) -> [ASImage]? {
        let pixelData = image.dataProvider!.data
        let bytesPerPixel = image.bitsPerPixel / 8
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        //let divFac = pow(2,image.bitsPerPixel)/256
        let cap = image.height * image.width * 8
        var redChannelData = Data(capacity: cap)
        var greenChannelData = Data(capacity: cap)
        var blueChannelData = Data(capacity: cap)
        var isMonochrome = true
        var minValue = UInt64.max
        var maxValue = UInt64.min
        for row in 0..<Int(image.height) {
            print("row \(row) of \(image.height)")
            for column in 0..<Int(image.width) {
                let pixelInfo: Int = ((image.bytesPerRow * Int(row)) + (Int(column) * bytesPerPixel))
                var redbytes = [UInt8]()
                var greenbytes = [UInt8]()
                var bluebytes = [UInt8]()
                for index in 0..<bytesPerPixel {
                    redbytes.append(data[pixelInfo+index])
                    greenbytes.append(data[pixelInfo+1*bytesPerPixel+index])
                    bluebytes.append(data[pixelInfo+2*bytesPerPixel+index])
                }
                for _ in 0..<(8-bytesPerPixel) {
                    redbytes.append(UInt8(0))
                    greenbytes.append(UInt8(0))
                    bluebytes.append(UInt8(0))
                }
                redChannelData.append(contentsOf: redbytes)
                greenChannelData.append(contentsOf: greenbytes)
                blueChannelData.append(contentsOf: bluebytes)
                
                let r = UnsafePointer(redbytes).withMemoryRebound(to: UInt64.self, capacity: 1) {
                    $0.pointee
                }
                let g = UnsafePointer(greenbytes).withMemoryRebound(to: UInt64.self, capacity: 1) {
                    $0.pointee
                }
                let b = UnsafePointer(bluebytes).withMemoryRebound(to: UInt64.self, capacity: 1) {
                    $0.pointee
                }
                if r != g || r != b || g != b {
                    isMonochrome = false
                }
                if r > maxValue {
                    maxValue = r
                }
                if g > maxValue {
                    maxValue = g
                }
                if b > maxValue {
                    maxValue = b
                }
                if r < minValue {
                    minValue = r
                }
                if g < minValue {
                    minValue = g
                }
                if b < minValue {
                    minValue = b
                }
                //print("color (\(row), \(column)): \(r)\t\(g)\t\(b)")
 
            }
        }
        print("maxValue = \(maxValue)   minValue = \(minValue)   monochrome: \(isMonochrome)")
        if isMonochrome {
            let image = ASImage(withWidth: image.width, andHeight: image.height, data: redChannelData)
            if image == nil {
                return nil
            }
            return [image!]
        } else {
            let redImage = ASImage(withWidth: image.width, andHeight: image.height, data: redChannelData)
            let greenImage = ASImage(withWidth: image.width, andHeight: image.height, data: greenChannelData)
            let blueImage = ASImage(withWidth: image.width, andHeight: image.height, data: blueChannelData)
            if redImage == nil || greenImage == nil || blueImage == nil {
                return nil
            }
            return [redImage!, greenImage!, blueImage!]
        }
    }
    
    
    public init?(withWidth width: Int, andHeight height: Int, data: Data) {
        self.width = width
        self.height = height
        let device = MTLCreateSystemDefaultDevice()
        if device == nil {
            return nil
        }
        let rowBytes = width * MemoryLayout<UInt64>.stride
        let len = height * rowBytes
        let matrixDescriptor = MPSMatrixDescriptor(dimensions: height, columns: width, rowBytes: rowBytes, dataType: .uInt32)
        let buffer = device!.makeBuffer(length: len, options: [])
        if buffer == nil {
            return nil
        }
        matrix = MPSMatrix(buffer: buffer!, descriptor: matrixDescriptor)
    }
    
    
    deinit {
    }
 
 
    public var cgImage : CGImage? {
        get {
            let rawPointer = matrix.data.contents()
            let count = matrix.rows * matrix.columns
            let typedPointer = rawPointer.bindMemory(to: Float.self, capacity: count)
            let bufferedPointer = UnsafeBufferPointer(start: typedPointer, count: count)
            for index in 0..<count {
                let value = bufferedPointer[index]
                let row = index / matrix.columns
                let column = index - row * matrix.columns
                //print("v(\(row),\(column)) = \(value)")
            }
            return nil
        }
    }
}
