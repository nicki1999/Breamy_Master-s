import UIKit
import RealityKit
import Foundation
import SwiftUI
import AVFoundation

// Define the protocol for communication with CustomCameraViewController
protocol CustomCameraViewControllerDelegate: AnyObject {
    func didFinishCapturingImages(withFolderURL folderURL: URL)
}

final class SwiftCodeKitViewController: UIViewController, UIDocumentPickerDelegate, PhotogrammetryProgressDelegate, CustomCameraViewControllerDelegate {

    var selectedDirectoryURL: URL?
    private var isPickingImagesFolder = false // Flag to differentiate between picker contexts

    private let progressLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.textAlignment = .center
        label.text = "Progress: 0.00%"
        return label
    }()
    
    private let instructionsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.textAlignment = .left
        label.text = "1. Choose “Capture 100 Images” and pick an empty folder to save the torso images.\n\n" +
        "2. Click “Select the Folder of images” and choose the folder with your saved images.\n\n" +
        "3. Wait until the “progress” at the top of the screen reaches 100%\n\n" +
        "4. Hit “Done.”"
        label.numberOfLines = 0 // Allows multiple lines if needed
        label.lineBreakMode = .byWordWrapping // Ensures text wraps correctly
        return label
    }()


    func updateProgress(_ progress: Float, fractionComplete: Double) {
        DispatchQueue.main.async {
            let formattedProgress = String(format: "Progress: %.2f%%", progress * 100)
            self.progressLabel.text = formattedProgress
            print("Progress: \(progress * 100)%")
            print("Fraction Complete: \(fractionComplete)")
        }
    }

    private lazy var anotherButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Select the folder of images", for: .normal)
        button.backgroundColor = .blue
        button.layer.cornerRadius = 20
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(onAnotherButtonTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var imagesCaptureButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Capture 100 images", for: .normal)
        button.addTarget(self, action: #selector(startCustomCamera), for: .touchUpInside)
        button.backgroundColor = .blue
        button.layer.cornerRadius = 20
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var button: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Done", for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 20
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(onTap), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: "#F9EAED")
        anotherButton.backgroundColor = UIColor(hex: "#4849A1")  // Set background color
        imagesCaptureButton.backgroundColor = UIColor(hex: "#4849A1")  // Set background color
        anotherButton.setTitleColor(.white, for: .normal)
        imagesCaptureButton.setTitleColor(.white, for: .normal) // Set text color

        anotherButton.layer.cornerRadius = 5
        button.layer.cornerRadius = 5
        imagesCaptureButton.layer.cornerRadius = 5


        view.addSubview(progressLabel)
        view.addSubview(instructionsLabel) // Add this line
        view.addSubview(imagesCaptureButton)
        view.addSubview(anotherButton)
        view.addSubview(button)

        NSLayoutConstraint.activate([
            progressLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            progressLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 120),
            progressLabel.heightAnchor.constraint(equalToConstant: 30),
            
            // Instructions label constraints
            instructionsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            instructionsLabel.topAnchor.constraint(equalTo: progressLabel.bottomAnchor, constant: 40),
            instructionsLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            instructionsLabel.bottomAnchor.constraint(equalTo: imagesCaptureButton.topAnchor, constant: -200),

            
// Constraints for imagesCaptureButton
    imagesCaptureButton.heightAnchor.constraint(equalToConstant: 60),
    imagesCaptureButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
    imagesCaptureButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
    imagesCaptureButton.bottomAnchor.constraint(equalTo: anotherButton.topAnchor, constant: -15),

    // Constraints for anotherButton
    anotherButton.heightAnchor.constraint(equalToConstant: 60),
    anotherButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
    anotherButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
    anotherButton.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -15),

    // Constraints for button
    button.heightAnchor.constraint(equalToConstant: 60),
    button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
    button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
    button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            ])




                    
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("View did appear")
    }

    @objc func onTap() {
        dismiss(animated: true)
        SwiftCodeKit2.swiftCodeKitDidFinish?()
    }
    
    @objc func startCustomCamera() {
        isPickingImagesFolder = false // Ensure picker context is for capturing images

        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.folder])
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = .popover
        documentPicker.popoverPresentationController?.sourceView = imagesCaptureButton
        documentPicker.popoverPresentationController?.sourceRect = imagesCaptureButton.bounds
        present(documentPicker, animated: true, completion: nil)
    }

    @objc func onAnotherButtonTap() {
        isPickingImagesFolder = true // Ensure picker context is for picking folder of images

        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.folder])
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = .popover
        documentPicker.popoverPresentationController?.sourceView = anotherButton
        documentPicker.popoverPresentationController?.sourceRect = anotherButton.bounds
        present(documentPicker, animated: true, completion: nil)
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedFolderUrl = urls.first else {
            print("No folder selected.")
            return
        }

        // Start accessing the security-scoped resource
        if selectedFolderUrl.startAccessingSecurityScopedResource() {
            if isPickingImagesFolder {
                // When picking the folder of images
                Task {
                    await startPhotogrammetrySession(inputFolderUrl: selectedFolderUrl, delegate: self)
                }
            } else {
                // When starting the custom camera session
                selectedDirectoryURL = selectedFolderUrl

                // Create and present CustomCameraViewController
                let customCameraVC = CustomCameraViewController()
                customCameraVC.delegate = self
                customCameraVC.selectedDirectoryURL = selectedFolderUrl
                
                // Ensure presenting is done on the main thread
                DispatchQueue.main.async {
                    customCameraVC.modalPresentationStyle = .fullScreen
                    self.present(customCameraVC, animated: true, completion: nil)
                }
            }
        } else {
            print("Failed to access the selected folder.")
        }
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("Document picker was cancelled.")
    }

    func didFinishCapturingImages(withFolderURL folderURL: URL) {
        Task {
            await startPhotogrammetrySession(inputFolderUrl: folderURL, delegate: self)
        }
    }
}

class CustomCameraViewController: UIViewController, AVCapturePhotoCaptureDelegate {

    weak var delegate: CustomCameraViewControllerDelegate?
    var selectedDirectoryURL: URL? // Add this property
    
    private var captureSession: AVCaptureSession!
    private var photoOutput: AVCapturePhotoOutput!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    
    private var captureCount = 0
    private let targetCaptureCount = 100
    private var captureButton: UIButton!
    private var infoLabel: UILabel!
    private var capturedImageCount = 0


    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        setupCaptureButton()
        setupInfoLabel()
    }

    private func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo

        guard let backCamera = AVCaptureDevice.default(for: .video) else {
            print("No camera available")
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            captureSession.addInput(input)
        } catch {
            print("Error configuring camera input: \(error)")
            return
        }

        photoOutput = AVCapturePhotoOutput()
        captureSession.addOutput(photoOutput)

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.layer.bounds
        view.layer.addSublayer(previewLayer)

        captureSession.startRunning()
    }

    private func setupCaptureButton() {
        captureButton = UIButton(frame: CGRect(x: (view.frame.size.width - 70) / 2, y: view.frame.size.height - 100, width: 70, height: 70))
        captureButton.layer.cornerRadius = 35
        captureButton.backgroundColor = .red
        captureButton.setTitle("Capture", for: .normal)
        captureButton.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)
        view.addSubview(captureButton)
    }
    
    private func setupInfoLabel() {
        infoLabel = UILabel()
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.textColor = .white
        infoLabel.textAlignment = .center
        infoLabel.text = "Capturing \(capturedImageCount) images of \(targetCaptureCount). Will close automatically when done."
        infoLabel.backgroundColor = UIColor.black.withAlphaComponent(0.5) // Semi-transparent background
        infoLabel.numberOfLines = 0 // Allows multiple lines
        view.addSubview(infoLabel)
        
        NSLayoutConstraint.activate([
            infoLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            infoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            infoLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9)
        ])
    }

    @objc private func capturePhoto() {
        guard captureCount < targetCaptureCount else {
            // Notify delegate and dismiss
            let fileManager = FileManager.default
            let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let folderURL = documentsURL.appendingPathComponent("CapturedPhotos")
            self.delegate?.didFinishCapturingImages(withFolderURL: folderURL)
            
            // Dismiss view controller on the main thread
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
            return
        }

        let photoSettings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: photoSettings, delegate: self)
    }


    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error)")
            return
        }
        
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            print("Error processing photo data")
            return
        }

        saveImage(image)
        capturedImageCount += 1
            DispatchQueue.main.async {
                self.infoLabel.text = "Capturing \(self.capturedImageCount) images of \(self.targetCaptureCount). Will close automatically when done."
            }
    }

    private func saveImage(_ image: UIImage) {
        guard let folderURL = selectedDirectoryURL else {
            print("No folder URL provided")
            return
        }

        do {
            try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Error creating directory: \(error)")
            return
        }

        let photoCount = (try? FileManager.default.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil).count) ?? 0
        let photoIndex = photoCount + 1
        let photoURL = folderURL.appendingPathComponent("photo\(photoIndex).jpg")

        if let data = image.jpegData(compressionQuality: 0.8) {
            do {
                try data.write(to: photoURL)
                print("Saved photo to \(photoURL)")
                captureCount += 1
            } catch {
                print("Error saving photo: \(error)")
            }
        }
    }

}
extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if hexSanitized.hasPrefix("#") {
            hexSanitized.remove(at: hexSanitized.startIndex)
        }

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let red = CGFloat((rgb >> 16) & 0xFF) / 255.0
        let green = CGFloat((rgb >> 8) & 0xFF) / 255.0
        let blue = CGFloat(rgb & 0xFF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
