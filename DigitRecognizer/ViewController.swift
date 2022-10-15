//
//  ViewController.swift
//  DigitRecognizer
//
//  Created by Илья Воробьев on 14.10.2022.
//

import UIKit
import Vision

class ViewController: UIViewController {

    @IBOutlet var canvasView: CanvasView!
    @IBOutlet var label: UILabel!
    @IBOutlet var confidenceLabel: UILabel!
    
    var requests = [VNRequest]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupVision()
    }
    
    func setupVision() {
        let defaultConfig = MLModelConfiguration()
        let imageClassifierWrapper = try? MNISTClassifier(configuration: defaultConfig)
        guard let imageClassifier = imageClassifierWrapper else {
            fatalError("App failed to create an image classifier model instance.")
        }
        let imageClassifierModel = imageClassifier.model
        guard let imageClassifierVisionModel = try? VNCoreMLModel(for: imageClassifierModel) else {
            fatalError("App failed to create a `VNCoreMLModel` instance.")
        }
        
        let classificationRequest = VNCoreMLRequest(model: imageClassifierVisionModel, completionHandler: self.handleClassification)
        
        self.requests = [classificationRequest]
    }
    
    func handleClassification(request: VNRequest, error: Error?) {
        guard let observations = request.results else {
            print("no results")
            return
        }
        
        let classifications = observations
            .compactMap({ $0 as? VNClassificationObservation })
        
        DispatchQueue.main.async {
            let formatter = NumberFormatter()
            formatter.numberStyle = .percent
            self.label.text = classifications.first?.identifier
            self.confidenceLabel.text = formatter.string(from: (classifications.first?.confidence ?? 0.0) as NSNumber)
        }
    }

    @IBAction func clearButtonTapped(_ sender: Any) {
        canvasView.clear()
        label.text = ""
    }
    
    @IBAction func recognizeButtonTapped(_ sender: Any) {
        let image = canvasView.getImage()
        let scaledImage = scaleImage(image: image, toSize: CGSize(width: 28, height: 28))
        let imageRequestHandler = VNImageRequestHandler(cgImage: scaledImage.cgImage!)
        
        do {
            try imageRequestHandler.perform(self.requests)
        } catch {
            print(error)
        }
    }
    
    func scaleImage(image: UIImage, toSize size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 1)
        image.draw(in: CGRect(origin: .zero, size: size))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}

