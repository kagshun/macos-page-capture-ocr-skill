#!/usr/bin/env swift

import AppKit
import Foundation
import PDFKit

struct ImageToPDFConfiguration {
    let inputDirectory: URL
    let outputFile: URL
}

enum ImageToPDFError: Error, CustomStringConvertible {
    case usage(String)
    case missingImages(URL)
    case unreadableImage(URL)
    case failedToWrite(URL)

    var description: String {
        switch self {
        case .usage(let message):
            return message
        case .missingImages(let directory):
            return "No PNG, JPG, JPEG, TIFF, or HEIC images were found in \(directory.path)."
        case .unreadableImage(let file):
            return "Could not load image: \(file.path)"
        case .failedToWrite(let file):
            return "Failed to write PDF to \(file.path)"
        }
    }
}

func parseArguments() throws -> ImageToPDFConfiguration {
    let arguments = CommandLine.arguments.dropFirst()
    guard arguments.count >= 3 else {
        throw ImageToPDFError.usage(
            """
            Usage:
              swift images_to_pdf.swift <input-directory> --output <output.pdf>
            """
        )
    }

    let values = Array(arguments)
    let inputDirectory = URL(fileURLWithPath: values[0], isDirectory: true)

    guard let outputIndex = values.firstIndex(of: "--output"), outputIndex + 1 < values.count else {
        throw ImageToPDFError.usage("Missing required --output argument.")
    }

    let outputFile = URL(fileURLWithPath: values[outputIndex + 1])
    return ImageToPDFConfiguration(inputDirectory: inputDirectory, outputFile: outputFile)
}

func imageFiles(in directory: URL) throws -> [URL] {
    let fileManager = FileManager.default
    let allowedExtensions = Set(["png", "jpg", "jpeg", "tiff", "heic"])
    let entries = try fileManager.contentsOfDirectory(
        at: directory,
        includingPropertiesForKeys: [.isRegularFileKey],
        options: [.skipsHiddenFiles]
    )

    let files = entries.filter { url in
        allowedExtensions.contains(url.pathExtension.lowercased())
    }

    return files.sorted {
        $0.lastPathComponent.localizedStandardCompare($1.lastPathComponent) == .orderedAscending
    }
}

func buildPDF(from images: [URL], outputFile: URL) throws {
    let document = PDFDocument()

    for imageURL in images {
        guard let image = NSImage(contentsOf: imageURL) else {
            throw ImageToPDFError.unreadableImage(imageURL)
        }

        guard let page = PDFPage(image: image) else {
            throw ImageToPDFError.unreadableImage(imageURL)
        }

        document.insert(page, at: document.pageCount)
    }

    let outputDirectory = outputFile.deletingLastPathComponent()
    try FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true)

    guard document.write(to: outputFile) else {
        throw ImageToPDFError.failedToWrite(outputFile)
    }
}

do {
    let configuration = try parseArguments()
    let images = try imageFiles(in: configuration.inputDirectory)

    guard !images.isEmpty else {
        throw ImageToPDFError.missingImages(configuration.inputDirectory)
    }

    try buildPDF(from: images, outputFile: configuration.outputFile)
    print(configuration.outputFile.path)
} catch {
    fputs("\(error)\n", stderr)
    exit(1)
}
