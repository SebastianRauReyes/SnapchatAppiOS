//
//  SnapsViewController.swift
//  SnapchatAppiOS
//
//  Created by Sebastian Rau Reyes on 31/10/18.
//  Copyright © 2018 Sebastian Rau. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class SnapsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var snaps : [Snap] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        FIRDatabase.database().reference().child("usuarios").child(FIRAuth.auth()!.currentUser!.uid).child("snaps").observe(FIRDataEventType.childAdded, with: {(snapshot) in
                let snap = Snap()
                snap.imageURL = (snapshot.value as! NSDictionary)["imagenURL"] as! String
                snap.from = (snapshot.value as! NSDictionary)["from"] as! String
                snap.descrip = (snapshot.value as! NSDictionary)["descripcion"] as! String
                snap.id = snapshot.key
            snap.imagenID = (snapshot.value as! NSDictionary)["imagenID"] as! String
                self.snaps.append(snap)
                self.tableView.reloadData()
            })
        FIRDatabase.database().reference().child("usuarios").child(FIRAuth.auth()!.currentUser!.uid).child("snaps").observe(FIRDataEventType.childRemoved, with: {(snapshot) in
                var interador = 0
                for snap in self.snaps{
                    if snap.id == snapshot.key{
                        self.snaps.remove(at: interador)
                    }
                    interador += 1
                }
            self.tableView.reloadData()
            
            })
    
    }

    @IBAction func cerrarSesionTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if snaps.count == 0{
            return 1
        }else{
            return snaps.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        if snaps.count == 0{
            cell.textLabel?.text = "No tienes SNAPS"
        }else{
            let snap = snaps[indexPath.row]
            cell.textLabel?.text = snap.from
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let snap = snaps[indexPath.row]
        performSegue(withIdentifier: "versnapsegue", sender: snap)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "versnapsegue"{
            let siguienteVC = segue.destination as! VerSnapViewController
            siguienteVC.snap = sender as! Snap
        }
    }
    
}
