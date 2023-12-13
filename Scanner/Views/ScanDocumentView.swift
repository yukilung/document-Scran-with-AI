//
//  ContentView.swift
//  Scanner
//
//  Created by Jack on 29/3/2021.
//

import SwiftUI
import VisionKit
import Vision
import MapKit
import CoreData

struct ScanDocumentView: UIViewControllerRepresentable {
    
    @Environment(\.presentationMode) var presentationMode
    @Binding var recognizedText: String
    
    func makeCoordinator() -> Coordinator {
        Coordinator(recognizedText: $recognizedText, parent: self)
    }
    
    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let documentViewController = VNDocumentCameraViewController()
        documentViewController.delegate = context.coordinator
        return documentViewController
    }
    
    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {
        // nothing to do here
    }
    
    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        var recognizedText: Binding<String>
        var parent: ScanDocumentView
        
        let bill = Bill()
        
        init(recognizedText: Binding<String>, parent: ScanDocumentView) {
            self.recognizedText = recognizedText
            self.parent = parent
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            let extractedImages = extractImages(from: scan)
            let processedText = recognizeText(from: extractedImages)
            
            let organization = processedText.0
            let address = processedText.1

            guard let scannedImage = UIImage(cgImage: extractedImages[0]).pngData() else { return }

            PersistenceController.shared.documentSave(organization: organization, address: address, image: scannedImage)

            parent.presentationMode.wrappedValue.dismiss()
        }
        
        fileprivate func extractImages(from scan: VNDocumentCameraScan) -> [CGImage] {
            var extractedImages = [CGImage]()
            for index in 0..<scan.pageCount {
                let extractedImage = scan.imageOfPage(at: index)
                guard let cgImage = extractedImage.cgImage else { continue }
                
                extractedImages.append(cgImage)
            }
            return extractedImages
        }
 
        fileprivate func recognizeText(from images: [CGImage]) -> (String, String) {
            var organization = ""
            var entireRecognizedText = ""
            
            let recognizeTextRequest = VNRecognizeTextRequest { (request, error) in
                guard error == nil else { return }
                
                guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
                
                var components = [Bill]()
                
                let maximumRecognitionCandidates = 1
                for observation in observations {
                    guard let candidate = observation.topCandidates(maximumRecognitionCandidates).first else { continue }
                    for text in observation.topCandidates(1) {
                        let component = Bill()
                         component.x = observation.boundingBox.origin.x
                         component.y = observation.boundingBox.origin.y
                         component.text = text.string
                         components.append(component)
                     }
      
                    entireRecognizedText += "\(candidate.string)"

                }
                
                let start = CFAbsoluteTimeGetCurrent()
                organization = components[0].text
                entireRecognizedText = Bill().addressExtract(components)
                let diff = CFAbsoluteTimeGetCurrent() - start
                print("Took \(diff) seconds")
                
            }
            recognizeTextRequest.recognitionLevel = .accurate
            recognizeTextRequest.usesLanguageCorrection = true
            recognizeTextRequest.recognitionLanguages = ["zh-HK"]
            
            for image in images {
                let requestHandler = VNImageRequestHandler(cgImage: image, options: [:])
                
                try? requestHandler.perform([recognizeTextRequest])
            }
            
            return (organization, entireRecognizedText)
        }
        
    }
}
