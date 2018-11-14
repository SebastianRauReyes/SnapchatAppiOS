//
//  VerSnapViewController.swift
//  SnapchatAppiOS
//
//  Created by Sebastian Rau Reyes on 9/11/18.
//  Copyright © 2018 Sebastian Rau. All rights reserved.
//

import UIKit
import SDWebImage
import Firebase
import AVFoundation

class VerSnapViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    var snap = Snap()
    
    var audioRecorder : AVAudioRecorder?
    var audioURL : URL?
    var audioPlayer : AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        label.text? = snap.descrip
        imageView.sd_setImage(with: URL(string: snap.imageURL))
        do{
        try audioPlayer = AVAudioPlayer(contentsOf: URL(string: snap.imageURL)!)
        }catch{}
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        FIRDatabase.database().reference().child("usuarios").child(FIRAuth.auth()!.currentUser!.uid).child("snaps").child(snap.id).removeValue()
        
        FIRStorage.storage().reference().child("imagenes").child("\(snap.imagenID).jpg").delete(completion: {(error) in
                print("Se eliminó la imagen correctamente")
        })
    }

    @IBAction func playAudioTapped(_ sender: Any) {
        print("Playing...")
        audioPlayer?.play()
    }
}
