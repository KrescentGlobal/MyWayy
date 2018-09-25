//
//  OnboardViewController.swift
//  MyWayy
//
//  Created by KITLABS-M-003 on 22/08/18.
//  Copyright © 2018 MyWayy. All rights reserved.
//

import UIKit
import DKImagePickerController

class OnboardViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {
   
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var descriptionCharacterCount: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var nameTextField: UITextField!
     var shImage = true
    private let pageController = UIPageControl()
     let defaultText = "Tell us a little something about you..."
    var onboardData = Onboard()
    
    var isMovedUp = true {
        willSet {
            guard newValue != isMovedUp else { return }
            moveViewWhenKeyboardShown(up: newValue)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupUI()
        // Do any additional setup after loading the view.
    }
    private func setupUI() {
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navigationTitleFont = UIFont.medium(14)
        let navigationLargeTitleFont = UIFont.medium(24)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: navigationTitleFont, NSAttributedStringKey.foregroundColor: UIColor.with(Rgb(r: 73, g: 80, b: 87))]
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.font: navigationLargeTitleFont, NSAttributedStringKey.foregroundColor: UIColor.with(Rgb(r: 73, g: 80, b: 87))]
        let navBarsize = navigationController!.navigationBar.bounds.size
        let origin = CGPoint(x: navBarsize.width/2-15, y: 20)
        pageController.frame =  CGRect(x: origin.x, y: origin.y, width: 30, height: 30)
        guard let navigationBar = self.navigationController?.navigationBar else { return }
        navigationBar.addSubview(pageController)
        pageController.numberOfPages = 2
        pageController.currentPage = 0
        pageController.currentPageIndicatorTintColor = UIColor.with(Rgb(r: 75, g: 116, b: 255))
        pageController.pageIndicatorTintColor = UIColor.with(Rgb(r: 144, g: 144, b: 144))
        NSLayoutConstraint.activate([
            pageController.topAnchor.constraint(equalTo: navigationBar.topAnchor,
                                                constant: -10),
            pageController.rightAnchor.constraint(equalTo: navigationBar.centerXAnchor, constant: -20),
            pageController.heightAnchor.constraint(equalToConstant: 30),
            pageController.widthAnchor.constraint(equalTo: pageController.heightAnchor)
            ]) 
    }
    func setupView(){
        if (profileImage.image == UIImage(named: "profilePhotoCopy")){
            shImage = false
        }
        
        descriptionTextView.text = defaultText
        descriptionTextView.textColor = UIColor.blueyGrey
        nextButton.isEnabled = false
        nextButton.backgroundColor = UIColor.lightPeriwinkle
        nameTextField.delegate = self
        descriptionTextView.delegate = self
   
    }
    
    override func touchesBegan(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
         moveViewWhenKeyboardShown(up: true)
       
        if (descriptionTextView.text.trimmingCharacters(in: .whitespaces) == "") || (descriptionTextView.text.trimmingCharacters(in: .whitespaces) == defaultText) || shImage == false{
            nextButton.isEnabled = false
            nextButton.backgroundColor = UIColor.lightPeriwinkle
        }
        else{
            nextButton.isEnabled = true
            nextButton.backgroundColor = UIColor.lightishBlueFullAlpha
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        moveViewWhenKeyboardShown(up: false)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        self.view.endEditing(true)
        
        return false
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView == descriptionTextView && descriptionTextView.text == defaultText {
            descriptionTextView.text = ""
            descriptionTextView.textColor = UIColor.charcoalGrey
        }
        moveViewWhenKeyboardShown(up: true)
        if (nameTextField.text?.trimmingCharacters(in: .whitespaces) == "") || shImage == false{
            nextButton.isEnabled = false
            nextButton.backgroundColor = UIColor.lightPeriwinkle
        }
        else{
            nextButton.isEnabled = true
            nextButton.backgroundColor = UIColor.lightishBlueFullAlpha
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        
        let  char = text.cString(using: String.Encoding.utf8)!
        let isBackSpace = strcmp(char, "\\b")
        
        if descriptionTextView.text.lengthOfBytes(using: String.Encoding.utf8) <= CreateRoutineViewController.MaxDescriptionLength || (isBackSpace == -92){
            descriptionCharacterCount.text = "\(CreateRoutineViewController.MaxDescriptionLength - descriptionTextView.text.lengthOfBytes(using: String.Encoding.utf8))"
            return true
        }
        return false
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
       
        if textView == descriptionTextView && descriptionTextView.text.trimmingCharacters(in: .whitespaces) == "" {
            descriptionTextView.text = defaultText
            descriptionTextView.textColor = UIColor.blueyGrey
        }
        moveViewWhenKeyboardShown(up: false)
    }
    
    
    @IBAction func selectImageAction(_ sender: Any) {
        
         showPicker()
       
        if (descriptionTextView.text.trimmingCharacters(in: .whitespaces) == "") || (descriptionTextView.text.trimmingCharacters(in: .whitespaces) == defaultText) || (nameTextField.text?.trimmingCharacters(in: .whitespaces) == ""){
            nextButton.isEnabled = false
            nextButton.backgroundColor = UIColor.lightPeriwinkle
        }
        else{
            nextButton.isEnabled = true
            nextButton.backgroundColor = UIColor.lightishBlueFullAlpha
        }
    }
    
    func showPicker(){
        
        let pickerController = DKImagePickerController()
        pickerController.assetType = .allPhotos
        pickerController.singleSelect = true
        pickerController.didSelectAssets = { (assets: [DKAsset]) in
            for imageAsset in assets{
                imageAsset.fetchImageWithSize(CGSize(width: 100, height: 100), completeBlock: { image, info in
                    
                    self.profileImage.image = image
                    self.shImage = true
                })
            }
        }
        
        self.present(pickerController, animated: true) {}
    }
    
    
    @IBAction func backAc(_ sender: Any) {
         self.dismiss(animated: true, completion: nil)
    }

    
    @IBAction func nextAction(_ sender: Any) {
         self.view.endEditing(true)
        
        if (descriptionTextView.text.trimmingCharacters(in: .whitespaces) == "") || (descriptionTextView.text.trimmingCharacters(in: .whitespaces) == defaultText) || (nameTextField.text?.trimmingCharacters(in: .whitespaces) == "") || shImage == false{
            
            self.showOkErrorAlert(message: "All information is necessary")
        }
        else{
            
            onboardData.name = nameTextField.text!
            onboardData.description = descriptionTextView.text
            onboardData.image = profileImage.image!
            let nxtVC = self.storyboard?.instantiateViewController(withIdentifier: "OnboardSecondViewController") as! OnboardSecondViewController
            nxtVC.onboardData = onboardData
            self.navigationController?.pushViewController(nxtVC, animated: true)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
