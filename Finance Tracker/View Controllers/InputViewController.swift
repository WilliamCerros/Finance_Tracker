//
//  InputViewController.swift
//  Finance Tracker
//
//  Created by William Cerros on 12/6/20.
//

import UIKit
import Firebase
import MLKitVision
import FirebaseDatabase
import MLKitTextRecognition

class InputViewController: UIViewController {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.backgroundColor = .secondarySystemBackground
        
        button.backgroundColor = .systemBlue
        button.setTitle("Take Photo",
                        for: .normal)
        button.setTitleColor(.white,
                             for: .normal)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func didTapButton() {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        present(picker, animated: true)
    }
}

extension InputViewController: UIImagePickerControllerDelegate,
                                   UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as?
                UIImage else {
            return
        }
        imageView.image = image
        
        // Preparing image for text recognition
        let input = VisionImage(image: image)
        input.orientation = image.imageOrientation
        
        
        // Getting instance of Text Recognizer
        let textRecognizer = TextRecognizer.textRecognizer()
        
        // Process the image
        textRecognizer.process(input) { result, error in
            guard error == nil, let result = result else {
                //error handling
                return
            }
            
            // Recognized Text
            var rawTextArray = [String]()
            
            // Prepping data
            for block in result.blocks {
                for line in block.lines {
                    for element in line.elements {
                        
                        rawTextArray.append(element.text.lowercased())
                    }
                }
            }
            

            // Extracting the Amount Due from our Array
            for index in rawTextArray {
                if index.contains("$") {
                    // Extracting the cost
                    let input = index.trimmingCharacters(in: CharacterSet(charactersIn: "0123456789.").inverted)
                    let amountDue = input.replacingOccurrences(of: ",", with: "")
                    
                    // Getting the current date
                    let date = Date()
                    let formatter = DateFormatter()
                    
                    formatter.dateFormat = "dd EE"
                    
                    let currentDay = formatter.string(from: date)
                    
                    var amountDueWithDate = amountDue + " " + currentDay
                    
                    
                    // Update data base
                    let user = Auth.auth().currentUser
                    let db = Firestore.firestore()
                    let userRef = db.collection("users").document(user!.uid)
                    userRef.updateData(["expenses": FieldValue.arrayUnion([amountDueWithDate])])
                }
            }
        }
    }
}
