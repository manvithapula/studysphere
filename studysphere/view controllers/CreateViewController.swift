//
//  CreateViewController.swift
//  Studysphere2
//
//  Created by Dev on 30/10/24.
//

import UIKit
import MobileCoreServices
import UniformTypeIdentifiers
class CreateViewController: UIViewController {
    let picker = UIPickerView()
        var thisSaturday: Date!
        

    @IBOutlet weak var Topic: UITextField!
    @IBOutlet weak var Date: UITextField!
    @IBOutlet weak var NextButton: UIButton!
    @IBOutlet weak var fileUploadView: DashedRectangleUpload!
    
    @IBOutlet weak var subject: UITextField!
    var datePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Topic.returnKeyType = .done
        Topic.autocorrectionType = .no
        Date.returnKeyType = .done
        Date.keyboardType = .numbersAndPunctuation
        fileUploadView.setup(in: self)
        setupDatePicker()
        
        
        // Do any additional setup after loading the view.
    }


    @IBAction func Topic(_ sender: Any) {
    }
    
    @IBAction func Date(_ sender: Any) {
        
    }
    
    @IBAction func TapButton(_ sender: Any) {
    }
    
    @objc private func datePickerDone() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        Date.text = dateFormatter.string(from: datePicker.date)
        Date.resignFirstResponder()
    }
    private func setupDatePicker() {
        // Create a container view that will hold both toolbar and picker
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 260)) // Adjust height as needed
        
        // Setup toolbar
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 44))
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(datePickerDone))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.items = [flexSpace, doneButton]
        
        // Setup date picker
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.frame = CGRect(x: 0, y: toolbar.frame.height, width: view.frame.width, height: 216) // Standard picker height
        
        // Add toolbar and picker to container
        containerView.addSubview(toolbar)
        containerView.addSubview(datePicker)
        
        // Set container as input view
        Date.inputView = containerView
    }
    
}


