//
//  FirstViewController.swift
//  Finance Tracker
//
//  Created by William Cerros on 12/12/20.
//

import UIKit
import Charts
import Firebase

class FirstViewController: UIViewController, ChartViewDelegate {
    var lineChart = LineChartView()

    override func viewDidLoad() {
        super.viewDidLoad()
        lineChart.delegate = self
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        lineChart.frame = CGRect(x: 0, y: 0,
                                width: self.view.frame.size.width,
                                height: self.view.frame.size.width)
        lineChart.center = view.center
        view.addSubview(lineChart)
        let test = "test"
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
                var entries = [ChartDataEntry]()
                var daily_expense:[Double] = []
                var previous_state:Double = 0.0
                var counter = 0
                let num_of_expenses = expenses!.count - 1
                expenses?.forEach{
                    // Splitting intial entry into 2 components
                    // 1st index is the amount due
                    // 2nd index is the date entered
                    let split_string = $0.components(separatedBy: " ")
                    let money_spent = Double(split_string[0])
                    let day_of_the_month = Double(split_string[1])
                    
                    
                    // If the current day of the month is different from previous state then we total the
                    // the amount in the array and plot the sum for previous state
                    if previous_state != day_of_the_month && previous_state != 0 {
                        var amount_spent_one_day = 0.0
                        for expense in daily_expense {
                            amount_spent_one_day += expense
                        }
                        
                        //Empty the array after totalling the money spent in one particular day
                        daily_expense.removeAll()
                        
                        let chartEntry = ChartDataEntry(x: amount_spent_one_day, y: previous_state)
                        entries.append(chartEntry)
                    }
                    daily_expense.append(money_spent!)
                    previous_state = day_of_the_month!
                    if counter == num_of_expenses {
                        var amount_spent_one_day = 0.0
                        for expense in daily_expense {
                            amount_spent_one_day += expense
                        }
                        
                        //Empty the array after totalling the money spent in one particular day
                        daily_expense.removeAll()
                        
                        let chartEntry = ChartDataEntry(x: amount_spent_one_day, y: previous_state)
                        entries.append(chartEntry)
                    }
                    counter += 1
                }
             
                
                let set = LineChartDataSet(entries: entries)
                set.colors = ChartColorTemplates.material()
                let graph_data = LineChartData(dataSet: set)
                lineChart.data = graph_data
            } else {
                print("Document does not exist")
            }
        }
    }
}
