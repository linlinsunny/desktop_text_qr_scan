

import AppKit
import Vision

enum RecognitionType {
    case text
    case qrCode
}

class ScreenCapture {
    func capture(type: RecognitionType) {
        let task = Process()
        task.launchPath = "/usr/sbin/screencapture"
        task.arguments = ["-i", "-c"]
        task.launch()
        task.waitUntilExit()

        guard let pasteboard = NSPasteboard.general.pasteboardItems?.first,
              let fileType = pasteboard.types.first,
              let data = pasteboard.data(forType: fileType) else {
            return
        }
        
        guard let image = NSImage(data: data) else { return }

        if type == .text {
            recognizeText(in: image)
        } else {
            recognizeQRCode(in: image)
        }
    }

    private func recognizeText(in image: NSImage) {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return }

        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        let request = VNRecognizeTextRequest { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            let recognizedStrings = observations.compactMap { $0.topCandidates(1).first?.string }
            let fullText = recognizedStrings.joined(separator: "\n")
            
            self.handleResult(fullText)
        }
        request.recognitionLevel = .accurate

        try? requestHandler.perform([request])
    }

    private func recognizeQRCode(in image: NSImage) {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return }

        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        let request = VNDetectBarcodesRequest { (request, error) in
            guard let observations = request.results as? [VNBarcodeObservation] else { return }
            let recognizedStrings = observations.compactMap { $0.payloadStringValue }
            let fullText = recognizedStrings.joined(separator: "\n")

            self.handleResult(fullText)
        }

        try? requestHandler.perform([request])
    }

    private func handleResult(_ result: String) {
        guard !result.isEmpty else { return }

        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(result, forType: .string)

        if let url = URL(string: result), ["http", "https"].contains(url.scheme?.lowercased()) {
            NSWorkspace.shared.open(url)
        }
    }
}

