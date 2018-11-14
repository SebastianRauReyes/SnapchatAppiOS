//
//  ImagenViewController.swift
//  SnapchatAppiOS
//
//  Created by Sebastian Rau Reyes on 31/10/18.
//  Copyright © 2018 Sebastian Rau. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import AVFoundation

class ImagenViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descripcionTextField: UITextField!
    @IBOutlet weak var elegirContactoBoton: UIButton!
    
    @IBOutlet weak var recordButton: UIButton!
    
    @IBOutlet weak var playButton: UIButton!
    
    var imagePicker = UIImagePickerController()
    var imagenID = NSUUID().uuidString
    var audioID = NSUUID().uuidString
    var URlAudio = ""
    
    //Sound
    var audioRecorder : AVAudioRecorder?
    var audioURL : URL?
    var audioPlayer : AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRecorder()
        imagePicker.delegate = self
        elegirContactoBoton.isEnabled = false
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        imageView.image = image
        imageView.backgroundColor = UIColor.clear
        elegirContactoBoton.isEnabled = true
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func camaraTapped(_ sender: Any) {
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
    var imagenDownloadURL = ""
    var audioDownloadURL = ""
    
    @IBAction func elegirContactoTapped(_ sender: Any) {
        
        

        let audiosFolder = FIRStorage.storage().reference().child("audios")
        let audioData = NSData(contentsOf: audioURL!) as Data?
        audiosFolder.child("\(audioID).m4p").put(audioData!, metadata: nil, completion: {(metadata, error) in
            print("Intentando subir audio")
            if (error != nil){
                print("Error : \(String(describing: error))")
            }else{
                print("Audio subido correctamente!")
                self.audioDownloadURL = (metadata?.downloadURL()?.absoluteString)!
            }
        })
        
        elegirContactoBoton.isEnabled = false
        let imagenesFolder = FIRStorage.storage().reference().child("imagenes")
        let imagenData = UIImageJPEGRepresentation(imageView.image!, 0.1)!
        imagenesFolder.child("\(imagenID).jpg").put(imagenData, metadata: nil, completion: {(metadata, error) in
            print("Intentando subir la imagen")
            if (error != nil){
                print("Error : \(String(describing: error))")
            }else{
                print("Imagen subida correctamente!")
                self.imagenDownloadURL = (metadata?.downloadURL()?.absoluteString)!
                self.performSegue(withIdentifier: "seleccionarContactoSegue", sender: [self.imagenDownloadURL, self.audioDownloadURL])
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let siguienteVC = segue.destination as! ElejirUsuarioViewController
        siguienteVC.imagenURL = imagenDownloadURL as String
        siguienteVC.descrip = descripcionTextField.text!
        siguienteVC.imagenID = imagenID
        siguienteVC.audioID = audioID
        siguienteVC.URLaudio = audioDownloadURL as String
    }
    
    //Setup Recorder
    func setupRecorder(){
        do{
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try session.overrideOutputAudioPort(.speaker)
            try session.setActive(true)
            
            let basePath : String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            
            let pathComponents = [basePath,"\(audioID).m4p"]
            audioURL = NSURL.fileURL(withPathComponents: pathComponents)!
            print(audioURL!)
            var settings : [String:AnyObject] = [:]
            settings[AVFormatIDKey] = Int(kAudioFormatMPEG4AAC) as AnyObject?
            settings[AVSampleRateKey] = 44100.0 as AnyObject?
            settings[AVNumberOfChannelsKey] = 2 as AnyObject?
            
            audioRecorder = try AVAudioRecorder(url: audioURL!, settings: settings)
            audioRecorder!.prepareToRecord()
            
        }catch let error as NSError{
            print(error)
        }
    }
    
    @IBAction func recordTapped(_ sender: Any) {
        print("recordTapped")
        if(audioRecorder!.isRecording){
            audioRecorder?.stop()
            recordButton.setTitle("Record", for: .normal)
            
            playButton.isEnabled = true
            //addButton.isEnabled = true
        }else{
            audioRecorder?.record()
            recordButton.setTitle("Stop", for: .normal)
        }
    }
    
    @IBAction func playTapped(_ sender: Any) {
        print("playTapped")
        do{
            try audioPlayer = AVAudioPlayer(contentsOf: audioURL!)
            audioPlayer?.play()
            print("Playing...")
        }catch{}
    }
}
