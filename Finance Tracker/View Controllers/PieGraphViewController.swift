//
//  PieGraphViewController.swift
//  Finance Tracker
//
//  Created by Maciej Dobaczewski on 12/14/20.
//

import UIKit
import Firebase
import Charts

class PieGraphViewController: UIViewController {

    
    @IBOutlet weak var pieChartView: PieChartView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let user = Auth.auth().currentUser
        let db = Firestore.firestore()
        var expenseDictionary: [String: String] = [:]
        var totalExpense: Double = 0.0
        db.collection("users").document(user!.uid).collection("expenses").getDocuments(){ (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    let expenseValue = Double(document.get("value")as! Substring)  ?? 0.0
                    let category = document.get("category") as! String
                    let previousValue = Double(expenseDictionary[category] ?? "0") ?? 0.0
                    let currentCategoryExpense = previousValue + expenseValue
                    expenseDictionary[category] = String(currentCategoryExpense)
                    totalExpense += currentCategoryExpense
                }
            }
         }
        pieChartView.chartDescription?.enabled = false
        pieChartView.drawHoleEnabled = false
        pieChartView.rotationAngle = 0
        pieChartView.rotationEnabled = false
        pieChartView.isUserInteractionEnabled = false
        var entries: [PieChartDataEntry] = []
        var colors: [NSUIColor] = []
        for (category, value) in expenseDictionary {
            let percentageValue = (Double(value) ?? 0.0) / totalExpense
            entries.append(PieChartDataEntry(value: percentageValue, label: category))
            colors.append(NSUIColor(red: 135.0, green: 135.0, blue: 135.0, alpha: 255.0))
        }
        let dataSet = PieChartDataSet( entries: entries, label: "")
        dataSet.colors = colors
        dataSet.drawValuesEnabled = false
        
        pieChartView.data = PieChartData(dataSet: dataSet)
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
