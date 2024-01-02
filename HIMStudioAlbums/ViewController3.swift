//
//  ViewController3.swift
//  HIMStudioAlbums
//
//  Created by Deniz Baran SERBEST on 12.04.2023.
//

import UIKit
import CoreData

class ViewController3: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var yearText1: UITextField!
    @IBOutlet weak var yearText2: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    var chosenAlbum = ""
    var chosenID : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if chosenAlbum != "" {
            saveButton.isHidden = true
            nameText.isEnabled = false
            yearText1.isEnabled = false
            yearText2.isEnabled = false
            
            //CoreData
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "StudioAlbums")
            let idString = chosenID?.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject]{
                        if let name = result.value(forKey: "name") as? String {
                            nameText.text = name
                        }
                        if let year1 = result.value(forKey: "released") as? String {
                            yearText1.text = year1
                        }
                        if let year2 = result.value(forKey: "recorded") as? String {
                            yearText2.text = year2
                        }
                        if let imageData = result.value(forKey: "image") as? Data {
                            let image = UIImage(data: imageData)
                            imageView.image = image
                        }
                    }
                }
            } catch{
                print("error")
            }
           
            
        } else {
            //Recognizer
            let Gesture = UITapGestureRecognizer(target: self, action: #selector(HideKeyboard))
            view.addGestureRecognizer(Gesture)
            
            imageView.isUserInteractionEnabled = true
            let TapImage = UITapGestureRecognizer(target: self, action: #selector(SelectImage))
            imageView.addGestureRecognizer(TapImage)
        }
        
    }
    
    
    @objc func HideKeyboard() {
        view.endEditing(true)
    }
    
    @objc func SelectImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true)
    }
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let album = NSEntityDescription.insertNewObject(forEntityName: "StudioAlbums", into: context)
        
        album.setValue(nameText.text, forKey: "name")
        album.setValue(yearText1.text, forKey: "released")
        album.setValue(yearText2.text, forKey: "recorded")
        album.setValue(UUID(), forKey: "id")
        let imdata = imageView.image!.jpegData(compressionQuality: 0.5)
        album.setValue(imdata, forKey: "image")
        
        do {
            try context.save()
            print("ok")
        } catch {
            print("error")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    
}
