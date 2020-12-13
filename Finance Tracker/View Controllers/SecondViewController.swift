//
//  SecondViewController.swift
//  Finance Tracker
//
//  Created by William Cerros on 12/12/20.
//

import UIKit
import Charts
import Firebase

class SecondViewController: UIViewController, ChartViewDelegate {
    
    var barChart = BarChartView()
    var mon_expense: (Double) = 0
    var tue_expense: (Double) = 0
    var wed_expense: (Double) = 0
    var thur_expense: (Double) = 0
    var fri_expense: (Double) = 0
    var sat_expense: (Double) = 0
    var sun_expense: (Double) = 0

    

    override func viewDidLoad() {
        super.viewDidLoad()
        barChart.delegate = self

        // Do any additional setup after loading the view.
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        barChart.frame = CGRect(x: 0, y: 0,
                                width: self.view.frame.size.width,
                                height: self.view.frame.size.width)
        barChart.center = view.center
        view.addSubview(barChart)
    
        var expenses: [String] = []
        
        let user = Auth.auth().currentUser
        let db = Firestore.firestore()
        let docRef = db.collection("users").document(user!.uid)
        docRef.getDocument { [self] (document, error) in
            if let document = document, document.exists {
                let data = document.get("expenses")
                let temp = data as? NSArray
                var objCArray = NSMutableArray(array: temp!)
                let expenses = objCArray as NSArray as? [String]

                expenses?.forEach{
                    // Splitting intial entry into 2 components
                    // 1st index is the amount due
                    // 2nd index is the date entered
                    let split_string = $0.components(separatedBy: " ")
                    
                    var money_spent = split_string[0]
                    var day_of_the_week = split_string[2]
                    
                    switch day_of_the_week {
                    case "Mon":
                        mon_expense += Double(money_spent)!
                    case "Tue":
                        tue_expense += Double(money_spent)!
                    case "Wed":
                        wed_expense += Double(money_spent)!
                    case "Thur":
                        thur_expense += Double(money_spent)!
                    case "Fri":
                        fri_expense += Double(money_spent)!
                    case "Sat":
                        sat_expense += Double(money_spent)!
                    case "Sun":
                        sun_expense += Double(money_spent)!
                    default:
                        break
                    }
                }
             
                var entries = [BarChartDataEntry]()
                var barChartDataEntry = BarChartDataEntry(x: 0, y:mon_expense)
                entries.append(barChartDataEntry)
                
                barChartDataEntry = BarChartDataEntry(x: 1, y:tue_expense)
                entries.append(barChartDataEntry)
                
                barChartDataEntry = BarChartDataEntry(x: 2, y:wed_expense)
                entries.append(barChartDataEntry)
                
                barChartDataEntry = BarChartDataEntry(x: 3, y:thur_expense)
                entries.append(barChartDataEntry)
                
                barChartDataEntry = BarChartDataEntry(x: 4, y:fri_expense)
                entries.append(barChartDataEntry)
                
                barChartDataEntry = BarChartDataEntry(x: 5, y:sat_expense)
                entries.append(barChartDataEntry)
                
                barChartDataEntry = BarChartDataEntry(x: 6, y:sun_expense)
                entries.append(barChartDataEntry)
  
                let days = ["Mon", "Tue", "Wed", "Thur", "Fri", "Sat", "Sun"]
                barChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: days)
                barChart.xAxis.granularity = 1
                
                let set = BarChartDataSet(entries: entries)
                set.colors = ChartColorTemplates.joyful()
                let graph_data = BarChartData(dataSet: set)
                barChart.data = graph_data
            } else {
                print("Document does not exist")
            }
        }
    }
}
