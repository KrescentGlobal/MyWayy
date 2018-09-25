//
//  AddTagsViewController.swift
//  MyWayy
//
//  Created by Spindance on 11/2/17.
//  Copyright © 2017 MyWayy. All rights reserved.
//

import UIKit
import TagListView

class AddTagsViewController: ActivityCreationOverlayViewController, UITextFieldDelegate{
  
    var arrTags = [String]()
    @IBOutlet weak var assignTagsLabel: UILabel!
    @IBOutlet weak var createTagField: UITextField!
    @IBOutlet weak var tagListView: TagListView!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
   
    var userTags = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tagListView.delegate = self
        assignTagsLabel.text = NSLocalizedString("ASSIGN TAGS", comment: "")
        setupCreateTagField()
        userTags = MyWayyService.shared.tags()
       
        for value in userTags{
           tagListView.addTag(value)
        }
    }
    
    func setupCreateTagField(){
         createTagField.delegate = self
         createTagField.becomeFirstResponder()
        
    }
    
    @IBAction func backButtonPress(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == createTagField {
            if createTagField.text != "" {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "CustomActivityViewController") as! CustomActivityViewController
               vc.arrTags.append(createTagField.text!)
                self.present(vc, animated: true, completion: nil)
            }
        }
        
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
       moveViewWhenKeyboardShown(up: true)
    }
}

extension AddTagsViewController: TagListViewDelegate{
    // MARK: TagsDelegate
    
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        
        arrTags.append(title)
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CustomActivityViewController") as! CustomActivityViewController
        vc.arrTags = arrTags
        self.present(vc, animated: true, completion: nil)
       
    }
    
    func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) {
        arrTags.remove(at: arrTags.index(of: title)!)
    }
}




