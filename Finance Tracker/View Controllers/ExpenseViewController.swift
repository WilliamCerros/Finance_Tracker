//
//  ExpenseViewController.swift
//  Finance Tracker
//
//  Created by Maciej Dobaczewski on 12/13/20.
//

import UIKit
import Firebase
import FirebaseDatabase

class ExpenseViewController: UIViewController {

    @IBOutlet weak var AddExpenseButton: UIButton!
    @IBOutlet weak var expenseValue: UITextField!
    
    @IBOutlet weak var category: UITextField!
    
    @IBOutlet weak var expenseDescription: UITextField!
    @IBAction func AddExpensePressed(_ sender: UIButton) {
        AddExpenseButton.isEnabled = false
        AddExpenseButton.setTitle("Adding", for: .normal)
        let user = Auth.auth().currentUser
        let db = Firestore.firestore()
        
        
        db.collection("users").document(user!.uid).collection("expenses").document().setData(["category" : category.text!
                                                                                              , "value": expenseValue.text!,
                                                                                              "description":   expenseDescription.text!,                                     "created": FieldValue.serverTimestamp(),  "updated": FieldValue.serverTimestamp()])
        AddExpenseButton.setTitle("Add Expense", for: .normal)
        expenseValue.text = ""
        expenseDescription.text = ""
        AddExpenseButton.isEnabled = true
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
