import RealityKit
import Foundation
import ModelIO
import UIKit
import SwiftUI

protocol PhotogrammetryProgressDelegate: AnyObject {
    func updateProgress(_ progress: Float, fractionComplete: Double)
}

func startPhotogrammetrySession(inputFolderUrl: URL, delegate: PhotogrammetryProgressDelegate?) async {
    guard PhotogrammetrySession.isSupported else {
        print("Object Capture is not supported on this device.")
        fatalError("Device not compatible.")
    }
    
    print("Full path of the selected folder:", inputFolderUrl.path)
    guard inputFolderUrl.startAccessingSecurityScopedResource() else {
        print("Failed to start accessing security-scoped resource.")
        return
    }
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let usdzFileURL = documentsDirectory.appendingPathComponent("Cube.usdz")
    print("Full path of the output .usdz file:", usdzFileURL.absoluteString)
    let request = PhotogrammetrySession.Request.modelFile(url: usdzFileURL, detail: .reduced)
    
    do {
        let session = try PhotogrammetrySession(input: inputFolderUrl)
        _ = Task.init {
            do {
                for try await output in session.outputs {
                    switch output {
                    case .processingComplete:
                        print("Processing Complete")
                        // Convert .usdz to .obj
                        let objFileURL = try convertUSDZtoOBJ(usdzFileURL: usdzFileURL)
                        print("Full path of the output .obj file:", objFileURL.absoluteString)
                    case .requestError(_, let error):
                        print("Request Error: \(error.localizedDescription)")
                    case .requestComplete(_, _):
                        print("Request Complete")
                    case .requestProgress(_, let fractionComplete):
                        let progress = Float(fractionComplete)
                        delegate?.updateProgress(progress, fractionComplete: fractionComplete)
                    case .inputComplete:
                        print("Input Complete")
                    case .invalidSample(_, let reason):
                        print("Invalid Sample: \(reason)")
                    case .skippedSample(_):
                        print("Skipped Sample")
                    case .automaticDownsampling:
                        print("Automatic Downsampling")
                    case .processingCancelled:
                        print("Processing Cancelled")
                    case .requestProgressInfo(_, _):
                        print("requestProgressInfo")
                    case .stitchingIncomplete:
                        print("stitchingIncomplete")
                    @unknown default:
                        print("Unknown output")
                    }
                }
            } catch {
                print("Output: ERROR = \(error.localizedDescription)")
            }
        }
        try session.process(requests: [request])
        


        
    } catch {
        print("Error creating photogrammetry session: \(error.localizedDescription)")
    }
}

func convertUSDZtoOBJ(usdzFileURL: URL) throws -> URL {
    let objFileName = usdzFileURL.deletingPathExtension().lastPathComponent + ".obj"
    let objFileURL = usdzFileURL.deletingLastPathComponent().appendingPathComponent(objFileName)

    let usdzAsset = MDLAsset(url: usdzFileURL)
    var success = false
    do {
        try usdzAsset.export(to: objFileURL)
        success = true
    } catch {
        throw NSError(domain: "USDZConversionError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to convert USDZ to OBJ: \(error.localizedDescription)"])
    }
    
    if success {
        return objFileURL
    } else {
        throw NSError(domain: "USDZConversionError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to convert USDZ to OBJ"])
    }
}

