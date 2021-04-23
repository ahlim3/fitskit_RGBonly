/*
 
 Copyright (c) <2020>
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 
 */

import FITS
import Accelerate
import Foundation

extension AnyImageHDU {
    
    func vMONO(_ data: inout DataUnit,  width: Int, height: Int, bscale: Float, bzero: Float, _ bitpix: BITPIX) -> CGImage? {
        
        var converted = FITSByteTool.normalize_F(&data, width: width, height: height, bscale: bscale, bzero: bzero, bitpix)
        /*
        var imagemultiplier = converted.reduce(0,+) / Float(converted.count) * Float(65535.0)
        for item in 0 ..< converted.count{
            converted[item] = converted[item] * imagemultiplier
        }
 */
        let layerBytes = width * height * FITSByte_F.bytes
        let rowBytes = width * FITSByte_F.bytes
        
        let gray = converted.withUnsafeMutableBytes{ mptr8 in
            vImage_Buffer(data: mptr8.baseAddress?.advanced(by: layerBytes * 0).bindMemory(to: FITSByte_F.self, capacity: width * height), height: vImagePixelCount(height), width: vImagePixelCount(width), rowBytes: rowBytes)
        }
        
        var finfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
        finfo.insert(CGBitmapInfo(rawValue: CGBitmapInfo.byteOrder32Little.rawValue))
        finfo.insert(CGBitmapInfo(rawValue: CGBitmapInfo.floatComponents.rawValue))
        let format = vImage_CGImageFormat(bitsPerComponent: FITSByte_F.bits, bitsPerPixel: FITSByte_F.bits, colorSpace: CGColorSpaceCreateDeviceGray(), bitmapInfo: finfo)!
        
        return try? gray.createCGImage(format: format)
    }
    func v_data(_ data: inout DataUnit,  width: Int, height: Int, bscale: Float, bzero: Float, _ bitpix: BITPIX) -> [FITSByte_F]? {
        
        let converted = FITSByteTool.normalize_F(&data, width: width, height: height, bscale: bscale, bzero: bzero, bitpix)
        return converted
    }
    func vMONO_format(_ data: inout DataUnit,  width: Int, height: Int, bscale: Float, bzero: Float, _ bitpix: BITPIX) -> vImage_CGImageFormat? {
        
        var converted = FITSByteTool.normalize_F(&data, width: width, height: height, bscale: bscale, bzero: bzero, bitpix)
        
        let layerBytes = width * height * FITSByte_F.bytes
        let rowBytes = width * FITSByte_F.bytes
        
        let gray = converted.withUnsafeMutableBytes{ mptr8 in
            vImage_Buffer(data: mptr8.baseAddress?.advanced(by: layerBytes * 0).bindMemory(to: FITSByte_F.self, capacity: width * height), height: vImagePixelCount(height), width: vImagePixelCount(width), rowBytes: rowBytes)
        }
        
        var finfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
        finfo.insert(CGBitmapInfo(rawValue: CGBitmapInfo.byteOrder32Little.rawValue))
        finfo.insert(CGBitmapInfo(rawValue: CGBitmapInfo.floatComponents.rawValue))
        let format = vImage_CGImageFormat(bitsPerComponent: FITSByte_F.bits, bitsPerPixel: FITSByte_F.bits, colorSpace: CGColorSpaceCreateDeviceGray(), bitmapInfo: finfo)!
        return format
        
    }
    func vMONO_buffer(_ data: inout DataUnit,  width: Int, height: Int, bscale: Float, bzero: Float, _ bitpix: BITPIX) -> vImage_Buffer? {
        
        var converted = FITSByteTool.normalize_F(&data, width: width, height: height, bscale: bscale, bzero: bzero, bitpix)
        let Max = converted.max()!
        let Min = converted.min()!
        let factor = 1.0 / (Max - Min)
        let count = converted.count
        for item in 0 ..< count{
            converted[item] = converted[item] * factor
        }
        let layerBytes = width * height * FITSByte_F.bytes
        let rowBytes = width * FITSByte_F.bytes
        
        let gray = converted.withUnsafeMutableBytes{ mptr8 in
            vImage_Buffer(data: mptr8.baseAddress?.advanced(by: layerBytes * 0).bindMemory(to: FITSByte_F.self, capacity: width * height), height: vImagePixelCount(height), width: vImagePixelCount(width), rowBytes: rowBytes)
        }
        return gray
    }
    func vMONO_Complete(_ data: inout DataUnit,  width: Int, height: Int, bscale: Float, bzero: Float, _ bitpix: BITPIX) -> CGImage {
        var converted = FITSByteTool.normalize_F(&data, width: width, height: height, bscale: bscale, bzero: bzero, bitpix)
        
        let layerBytes = width * height * FITSByte_F.bytes
        let rowBytes = width * FITSByte_F.bytes
        
        var gray = converted.withUnsafeMutableBytes{ mptr8 in
            vImage_Buffer(data: mptr8.baseAddress?.advanced(by: layerBytes * 0).bindMemory(to: FITSByte_F.self, capacity: width * height), height: vImagePixelCount(height), width: vImagePixelCount(width), rowBytes: rowBytes)
        }
        
        var finfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
        finfo.insert(CGBitmapInfo(rawValue: CGBitmapInfo.byteOrder32Little.rawValue))
        finfo.insert(CGBitmapInfo(rawValue: CGBitmapInfo.floatComponents.rawValue))
        let format = vImage_CGImageFormat(bitsPerComponent: FITSByte_F.bits, bitsPerPixel: FITSByte_F.bits, colorSpace: CGColorSpaceCreateDeviceGray(), bitmapInfo: finfo)!
        var destinationBuffer: vImage_Buffer = {
            guard var destinationBuffer = try? vImage_Buffer(width: Int(width), height: Int(height), bitsPerPixel: UInt32(FITSByte_F.bits)) else {
                                                    fatalError("Unable to create destination buffers.")
            }
            
            return destinationBuffer
        }()
        let redCoefficient: Float = 0.2126
        let greenCoefficient: Float = 0.7152
        let blueCoefficient: Float = 0.0722
        let gammaCoefficient: Float = 1.0
        let divisor: Int32 = 0x1000
        let fDivisor = Float(divisor)
        
        var coefficientsMatrix = [
            Float(redCoefficient * fDivisor),
            Float(greenCoefficient * fDivisor),
            Float(blueCoefficient * fDivisor),
            Float(gammaCoefficient * fDivisor)
        ]
        let preBias: [Float] = [0, 0, 0, 0]
        let postBias: Float = 0
        vImageMatrixMultiply_ARGBFFFFToPlanarF(&gray,
                                               &destinationBuffer,
                                               &coefficientsMatrix,
                                               preBias,
                                               postBias,
                                               vImage_Flags(kvImagePrintDiagnosticsToConsole))
        let monoFormat = vImage_CGImageFormat(
            bitsPerComponent: 8,
            bitsPerPixel: 8,
            colorSpace: CGColorSpaceCreateDeviceGray(),
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue),
            renderingIntent: .defaultIntent)!
        let result = (try? destinationBuffer.createCGImage(format: monoFormat))!
        return result
    }
    
    func vRGB(_ data: inout DataUnit, layer: (Int,Int,Int) = (0,1,2),  width: Int, height: Int, bscale: Float, bzero: Float, _ bitpix: BITPIX) -> CGImage? {
        
        var converted = FITSByteTool.normalize_F(&data, width: width, height: height, bscale: bscale, bzero: bzero, bitpix)
        
        let layerBytes = width * height * FITSByte_F.bytes
        let rowBytes = width * FITSByte_F.bytes
        
        var red = converted.withUnsafeMutableBytes{ mptr8 in
            vImage_Buffer(data: mptr8.baseAddress?.advanced(by: layerBytes * layer.0).bindMemory(to: FITSByte_F.self, capacity: width * height), height: vImagePixelCount(height), width: vImagePixelCount(width), rowBytes: rowBytes)
        }
        
        var green = converted.withUnsafeMutableBytes{ mptr8 in
            vImage_Buffer(data: mptr8.baseAddress?.advanced(by: layerBytes * layer.1).bindMemory(to: FITSByte_F.self, capacity: width * height), height: vImagePixelCount(height), width: vImagePixelCount(width), rowBytes: rowBytes)
        }
        
        var blue = converted.withUnsafeMutableBytes{ mptr8 in
            vImage_Buffer(data: mptr8.baseAddress?.advanced(by: layerBytes * layer.2).bindMemory(to: FITSByte_F.self, capacity: width * height), height: vImagePixelCount(height), width: vImagePixelCount(width), rowBytes: rowBytes)
        }
        
        var outBuffer = try! vImage_Buffer(width: width, height: height, bitsPerPixel: UInt32(FITSByte_F.bits * 3))
        defer{
            outBuffer.free()
        }
        
        vImageConvert_PlanarFtoRGBFFF(&red, &green, &blue, &outBuffer, vImage_Flags(kvImageNoFlags))
        
        var finfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
        finfo.insert(CGBitmapInfo(rawValue: CGBitmapInfo.byteOrder32Little.rawValue))
        finfo.insert(CGBitmapInfo(rawValue: CGBitmapInfo.floatComponents.rawValue))
        let rgbFormat = vImage_CGImageFormat(bitsPerComponent: FITSByte_F.bits, bitsPerPixel: FITSByte_F.bits * 3, colorSpace: CGColorSpaceCreateDeviceRGB(), bitmapInfo: finfo)!
        
        return try? outBuffer.createCGImage(format: rgbFormat)
    }
    
    func vRGB_Buffer(_ data: inout DataUnit, layer: (Int,Int,Int) = (0,1,2),  width: Int, height: Int, bscale: Float, bzero: Float, _ bitpix: BITPIX) -> vImage_Buffer? {
        
        var converted = FITSByteTool.normalize_F(&data, width: width, height: height, bscale: bscale, bzero: bzero, bitpix)
        
        let layerBytes = width * height * FITSByte_F.bytes
        let rowBytes = width * FITSByte_F.bytes
        
        var red = converted.withUnsafeMutableBytes{ mptr8 in
            vImage_Buffer(data: mptr8.baseAddress?.advanced(by: layerBytes * layer.0).bindMemory(to: FITSByte_F.self, capacity: width * height), height: vImagePixelCount(height), width: vImagePixelCount(width), rowBytes: rowBytes)
        }
        
        var green = converted.withUnsafeMutableBytes{ mptr8 in
            vImage_Buffer(data: mptr8.baseAddress?.advanced(by: layerBytes * layer.1).bindMemory(to: FITSByte_F.self, capacity: width * height), height: vImagePixelCount(height), width: vImagePixelCount(width), rowBytes: rowBytes)
        }
        
        var blue = converted.withUnsafeMutableBytes{ mptr8 in
            vImage_Buffer(data: mptr8.baseAddress?.advanced(by: layerBytes * layer.2).bindMemory(to: FITSByte_F.self, capacity: width * height), height: vImagePixelCount(height), width: vImagePixelCount(width), rowBytes: rowBytes)
        }
        
        var outBuffer = try! vImage_Buffer(width: width, height: height, bitsPerPixel: UInt32(FITSByte_F.bits * 3))
        defer{
            outBuffer.free()
        }
        return outBuffer
    }
    
    func vRGB_format(_ data: inout DataUnit, layer: (Int,Int,Int) = (0,1,2),  width: Int, height: Int, bscale: Float, bzero: Float, _ bitpix: BITPIX) -> vImage_CGImageFormat? {
        
        var converted = FITSByteTool.normalize_F(&data, width: width, height: height, bscale: bscale, bzero: bzero, bitpix)
        
        let layerBytes = width * height * FITSByte_F.bytes
        let rowBytes = width * FITSByte_F.bytes
        
        var red = converted.withUnsafeMutableBytes{ mptr8 in
            vImage_Buffer(data: mptr8.baseAddress?.advanced(by: layerBytes * layer.0).bindMemory(to: FITSByte_F.self, capacity: width * height), height: vImagePixelCount(height), width: vImagePixelCount(width), rowBytes: rowBytes)
        }
        
        var green = converted.withUnsafeMutableBytes{ mptr8 in
            vImage_Buffer(data: mptr8.baseAddress?.advanced(by: layerBytes * layer.1).bindMemory(to: FITSByte_F.self, capacity: width * height), height: vImagePixelCount(height), width: vImagePixelCount(width), rowBytes: rowBytes)
        }
        
        var blue = converted.withUnsafeMutableBytes{ mptr8 in
            vImage_Buffer(data: mptr8.baseAddress?.advanced(by: layerBytes * layer.2).bindMemory(to: FITSByte_F.self, capacity: width * height), height: vImagePixelCount(height), width: vImagePixelCount(width), rowBytes: rowBytes)
        }
        
        var outBuffer = try! vImage_Buffer(width: width, height: height, bitsPerPixel: UInt32(FITSByte_F.bits * 3))
        defer{
            outBuffer.free()
        }
        
        vImageConvert_PlanarFtoRGBFFF(&red, &green, &blue, &outBuffer, vImage_Flags(kvImageNoFlags))
        
        var finfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
        finfo.insert(CGBitmapInfo(rawValue: CGBitmapInfo.byteOrder32Little.rawValue))
        finfo.insert(CGBitmapInfo(rawValue: CGBitmapInfo.floatComponents.rawValue))
        let rgbFormat = vImage_CGImageFormat(bitsPerComponent: FITSByte_F.bits, bitsPerPixel: FITSByte_F.bits * 3, colorSpace: CGColorSpaceCreateDeviceRGB(), bitmapInfo: finfo)!
        return rgbFormat
    }
    

    public func v_cgimage(onError: ((Error) -> Void)?, onCompletion: @escaping (CGImage) -> Void) {
        
        guard let bitpix = bitpix else {
            onError?(AcceleratedFail.invalidMetadata("Missing BITPIX information"))
            return
        }
        
        guard let channels = naxis, let width = naxis(1), let height = naxis(2) else {
            onError?(AcceleratedFail.invalidMetadata("Missing NAXIS information"))
            return
        }
        
        
        let bscale : Float = self.bscale ?? 1
        let bzero : Float = self.bzero ?? 0
        
        guard var dat = self.dataUnit else {
            onError?(AcceleratedFail.missingData("DataUnit Empty"))
            return
        }
        
        var image : CGImage?
        if channels == 2 {
            image = vMONO(&dat, width: width, height: height, bscale: bscale, bzero: bzero, bitpix)

        } else  if channels == 3 {
            image = vRGB(&dat, width: width, height: height, bscale: bscale, bzero: bzero, bitpix)
        }
        
        if let image = image{
            onCompletion(image)
        } else {
            onError?(AcceleratedFail.unsupportedFormat("Unable to crate image"))
        }
    }
    
    public func v_buffer(onError: ((Error) -> Void)?, onCompletion: @escaping (vImage_Buffer) -> Void) {
        
        guard let bitpix = bitpix else {
            onError?(AcceleratedFail.invalidMetadata("Missing BITPIX information"))
            return
        }
        
        guard let channels = naxis, let width = naxis(1), let height = naxis(2) else {
            onError?(AcceleratedFail.invalidMetadata("Missing NAXIS information"))
            return
        }
        
        
        let bscale : Float = self.bscale ?? 1
        let bzero : Float = self.bzero ?? 0
        
        guard var dat = self.dataUnit else {
            onError?(AcceleratedFail.missingData("DataUnit Empty"))
            return
        }
        
        var image : vImage_Buffer?
        if channels == 2 {
            image = vMONO_buffer(&dat, width: width, height: height, bscale: bscale, bzero: bzero, bitpix)
            
        } else  if channels == 3 {
            image = vRGB_Buffer(&dat, width: width, height: height, bscale: bscale, bzero: bzero, bitpix)
        }
        
        if let image = image{
            onCompletion(image)
        } else {
            onError?(AcceleratedFail.unsupportedFormat("Unable to crate image"))
        }
    }
    public func v_format(onError: ((Error) -> Void)?, onCompletion: @escaping (vImage_CGImageFormat) -> Void) {
        
        guard let bitpix = bitpix else {
            onError?(AcceleratedFail.invalidMetadata("Missing BITPIX information"))
            return
        }
        
        guard let channels = naxis, let width = naxis(1), let height = naxis(2) else {
            onError?(AcceleratedFail.invalidMetadata("Missing NAXIS information"))
            return
        }
        
        
        let bscale : Float = self.bscale ?? 1
        let bzero : Float = self.bzero ?? 0
        
        guard var dat = self.dataUnit else {
            onError?(AcceleratedFail.missingData("DataUnit Empty"))
            return
        }
        
        var format : vImage_CGImageFormat?
        if channels == 2 {
            format = vMONO_format(&dat, width: width, height: height, bscale: bscale, bzero: bzero, bitpix)
            
        } else  if channels == 3 {
            format = vRGB_format(&dat, width: width, height: height, bscale: bscale, bzero: bzero, bitpix)
        }
        
        if let format = format{
            onCompletion(format)
        } else {
            onError?(AcceleratedFail.unsupportedFormat("Unable to crate image"))
        }
    }
    public func v_data(onError: ((Error) -> Void)?, onCompletion: @escaping ([FITSByte_F]) -> Void) {
        
        guard let bitpix = bitpix else {
            onError?(AcceleratedFail.invalidMetadata("Missing BITPIX information"))
            return
        }
        
        guard let channels = naxis, let width = naxis(1), let height = naxis(2) else {
            onError?(AcceleratedFail.invalidMetadata("Missing NAXIS information"))
            return
        }
        
        
        let bscale : Float = self.bscale ?? 1
        let bzero : Float = self.bzero ?? 0
        
        guard var dat = self.dataUnit else {
            onError?(AcceleratedFail.missingData("DataUnit Empty"))
            return
        }
        
        var data : [FITSByte_F]?
        if channels == 2 {
            data = v_data(&dat, width: width, height: height, bscale: bscale, bzero: bzero, bitpix)
            
        } else  if channels == 3 {
            data = v_data(&dat, width: width, height: height, bscale: bscale, bzero: bzero, bitpix)
        }
        
        if let data = data{
            onCompletion(data)
        } else {
            onError?(AcceleratedFail.unsupportedFormat("Unable to crate image"))
        }
    }
    
}

