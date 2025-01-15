import UIKit
import RealityKit
import Foundation
import SwiftUI


// Adopt the PhotogrammetryProgressDelegate protocol
final class SwiftCodeKitViewController: UIViewController, UIDocumentPickerDelegate, PhotogrammetryProgressDelegate {

    // Define an instance of DocumentPickerDelegate
    var selectedDirectoryURL: URL?

    // Progress label to display the progress information
    private let progressLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.textAlignment = .center
        label.text = "Progress: 0.00%"
        return label
    }()

    // Implement the method to update UI with progress
    func updateProgress(_ progress: Float, fractionComplete: Double) {
        // Update UI with the progress information
        DispatchQueue.main.async {
            // Update the progress label text
            let formattedProgress = String(format: "Progress: %.2f%%", progress * 100)
            self.progressLabel.text = formattedProgress
            // You can also use fractionComplete if needed
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

    private lazy var button: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Back", for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 20
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(onTap), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Add the progress label to the view
        view.addSubview(progressLabel)

        // Set constraints for the progress label
        NSLayoutConstraint.activate([
            progressLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 50), // Adjust the constant as needed
            progressLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 120), // Adjust the width as needed
            progressLabel.heightAnchor.constraint(equalToConstant: 30) // Adjust the height as needed
        ])

        // Add the buttons
        view.addSubview(button)
        view.addSubview(anotherButton)

        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 150),
            button.heightAnchor.constraint(equalToConstant: 50),
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            anotherButton.widthAnchor.constraint(equalToConstant: 150),
            anotherButton.heightAnchor.constraint(equalToConstant: 50),
            anotherButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            anotherButton.topAnchor.constraint(equalTo: button.bottomAnchor, constant: 20)
        ])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Perform actions when the view appears
        print("View did appear")
    }

    @objc func onTap() {
        dismiss(animated: true)
    }

    @objc func onAnotherButtonTap() {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.folder])
        documentPicker.delegate = self

        // Present the document picker as a popover from the button
        documentPicker.modalPresentationStyle = .popover
        documentPicker.popoverPresentationController?.sourceView = anotherButton
        documentPicker.popoverPresentationController?.sourceRect = anotherButton.bounds

        present(documentPicker, animated: true, completion: nil)
    }
}
