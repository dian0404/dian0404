#!/usr/bin/env swift
import AppKit
import Foundation
import ImageIO
import UniformTypeIdentifiers

let width = 1600
let height = 900
let gold = NSColor(calibratedRed: 212.0 / 255, green: 175.0 / 255, blue: 55.0 / 255, alpha: 1)
let frame = 3.0
let radius = 25.0

func fail(_ message: String) -> Never {
    fputs("Error: \(message)\n", stderr)
    exit(1)
}

guard CommandLine.arguments.count == 3 else {
    fail("Usage: make_cover.swift SOURCE OUTPUT.png")
}

let sourceURL = URL(fileURLWithPath: CommandLine.arguments[1])
let outputURL = URL(fileURLWithPath: CommandLine.arguments[2])
guard let source = NSImage(contentsOf: sourceURL),
      let sourceCG = source.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
    fail("Cannot read source image: \(sourceURL.path)")
}

let sourceWidth = sourceCG.width
let sourceHeight = sourceCG.height
guard min(sourceWidth, sourceHeight) >= 600 else {
    fail("Source is only \(sourceWidth)x\(sourceHeight); use a higher-resolution source (short edge at least 600 px).")
}

let targetRatio = CGFloat(width) / CGFloat(height)
let sourceRatio = CGFloat(sourceWidth) / CGFloat(sourceHeight)
let cropWidth = sourceRatio > targetRatio ? Int((CGFloat(sourceHeight) * targetRatio).rounded()) : sourceWidth
let cropHeight = sourceRatio > targetRatio ? sourceHeight : Int((CGFloat(sourceWidth) / targetRatio).rounded())
let cropRect = CGRect(
    x: (sourceWidth - cropWidth) / 2,
    y: (sourceHeight - cropHeight) / 2,
    width: cropWidth,
    height: cropHeight
)
guard let cropped = sourceCG.cropping(to: cropRect) else { fail("Could not crop source image.") }

let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
guard let context = CGContext(
    data: nil,
    width: width,
    height: height,
    bitsPerComponent: 8,
    bytesPerRow: width * 4,
    space: colorSpace,
    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
) else { fail("Could not create 1600x900 bitmap context.") }

context.interpolationQuality = .high
context.setFillColor(gold.cgColor)
context.fill(CGRect(x: 0, y: 0, width: width, height: height))
let imageRect = CGRect(x: frame, y: frame, width: Double(width) - frame * 2, height: Double(height) - frame * 2)
let imagePath = CGPath(roundedRect: imageRect, cornerWidth: radius - frame, cornerHeight: radius - frame, transform: nil)
context.saveGState()
context.addPath(imagePath)
context.clip()
context.draw(cropped, in: imageRect)
context.restoreGState()

guard let outputImage = context.makeImage() else { fail("Could not render output image.") }
try? FileManager.default.createDirectory(at: outputURL.deletingLastPathComponent(), withIntermediateDirectories: true)
guard let destination = CGImageDestinationCreateWithURL(outputURL as CFURL, UTType.png.identifier as CFString, 1, nil) else {
    fail("Could not create output file: \(outputURL.path)")
}
CGImageDestinationAddImage(destination, outputImage, [kCGImagePropertyColorModel: kCGImagePropertyColorModelRGB] as CFDictionary)
guard CGImageDestinationFinalize(destination) else { fail("Could not finish PNG output.") }

guard outputImage.width == width, outputImage.height == height else {
    fail("Output verification failed: \(outputImage.width)x\(outputImage.height)")
}
let attributes = try FileManager.default.attributesOfItem(atPath: outputURL.path)
let byteCount = attributes[.size] as? NSNumber ?? 0
print("Verified \(outputURL.path): \(outputImage.width)x\(outputImage.height) sRGB RGBA PNG (\(byteCount) bytes)")
