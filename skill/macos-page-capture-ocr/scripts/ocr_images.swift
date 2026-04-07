#!/usr/bin/env swift

import AppKit
import Foundation
import Vision

struct OCRConfiguration {
    let inputDirectory: URL
    let outputFile: URL?
    let languages: [String]
}

enum OCRError: Error, CustomStringConvertible {
    case usage(String)
    case missingImages(URL)
    case unreadableImage(URL)

    var description: String {
        switch self {
        case .usage(let message):
            return message
        case .missingImages(let directory):
            return "No PNG, JPG, JPEG, TIFF, or HEIC images were found in \(directory.path)."
        case .unreadableImage(let file):
            return "Could not load image: \(file.path)"
        }
    }
}

func parseArguments() throws -> OCRConfiguration {
    let values = Array(CommandLine.arguments.dropFirst())
    guard !values.isEmpty else {
        throw OCRError.usage(
            """
            Usage:
              swift ocr_images.swift <input-directory> [--output output.txt] [--languages ja-JP,en-US]
            """
        )
    }

    let inputDirectory = URL(fileURLWithPath: values[0], isDirectory: true)
    var outputFile: URL?
    var languages = ["ja-JP", "en-US"]

    var index = 1
    while index < values.count {
        let argument = values[index]
        switch argument {
        case "--output":
            guard index + 1 < values.count else {
                throw OCRError.usage("Missing file path after --output.")
            }
            outputFile = URL(fileURLWithPath: values[index + 1])
            index += 2
        case "--languages":
            guard index + 1 < values.count else {
                throw OCRError.usage("Missing comma-separated value after --languages.")
            }
            languages = values[index + 1]
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
            index += 2
        default:
            throw OCRError.usage("Unknown argument: \(argument)")
        }
    }

    return OCRConfiguration(inputDirectory: inputDirectory, outputFile: outputFile, languages: languages)
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

func cgImage(from imageURL: URL) throws -> CGImage {
    guard let image = NSImage(contentsOf: imageURL) else {
        throw OCRError.unreadableImage(imageURL)
    }

    var rect = NSRect(origin: .zero, size: image.size)
    guard let cgImage = image.cgImage(forProposedRect: &rect, context: nil, hints: nil) else {
        throw OCRError.unreadableImage(imageURL)
    }

    return cgImage
}

func recognizeText(in imageURL: URL, languages: [String]) throws -> String {
    let request = VNRecognizeTextRequest()
    request.recognitionLevel = .accurate
    request.usesLanguageCorrection = true
    request.recognitionLanguages = languages

    let handler = VNImageRequestHandler(cgImage: try cgImage(from: imageURL), options: [:])
    try handler.perform([request])

    let observations = (request.results ?? []).compactMap { observation in
        observation.topCandidates(1).first?.string
    }

    return observations.joined(separator: "\n")
}

do {
    let configuration = try parseArguments()
    let images = try imageFiles(in: configuration.inputDirectory)

    guard !images.isEmpty else {
        throw OCRError.missingImages(configuration.inputDirectory)
    }

    let outputText = try images.map { imageURL in
        try recognizeText(in: imageURL, languages: configuration.languages)
    }.joined(separator: "\n\n")

    if let outputFile = configuration.outputFile {
        let outputDirectory = outputFile.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true)
        try outputText.write(to: outputFile, atomically: true, encoding: .utf8)
        print(outputFile.path)
    } else {
        print(outputText)
    }
} catch {
    fputs("\(error)\n", stderr)
    exit(1)
}
