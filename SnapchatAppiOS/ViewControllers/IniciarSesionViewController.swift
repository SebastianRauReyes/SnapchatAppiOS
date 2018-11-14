//
//  IniciarSesionViewController.swift
//  SnapchatAppiOS
//
//  Created by Sebastian Rau Reyes on 31/10/18.
//  Copyright © 2018 Sebastian Rau. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class IniciarSesionViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func iniciarSesionTapped(_ sender: Any) {
        FIRAuth.auth()!.signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
           print("Intentamos Iniciar Sesión")
            if(error != nil){
                print("Error : \(String(describing: error))")
                FIRAuth.auth()!.createUser(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!, completion: { (user, error) in
                    print("Intentando Crear Usuario")
                    if(error != nil){
                        print("Error : \(String(describing: error))")
                    }else{
                        print("El usuario fue creado exitosamente!")
                        FIRDatabase.database().reference().child("usuarios").child(user!.uid).child("email").setValue(user!.email)
                        self.performSegue(withIdentifier: "iniciarsesionsegue", sender: nil)
                    }
                })
            }else{
                print("Inicio de Sesión Exitoso!")
                self.performSegue(withIdentifier: "iniciarsesionsegue", sender: nil)
            }
        }
    }
    

}

