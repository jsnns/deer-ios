//
//  SurveyListView.swift
//  Deer
//
//  Created by Jacob Sansbury on 9/1/16.
//  Copyright © 2016 Fabric. All rights reserved.
//


import UIKit
import TwitterKit
import FirebaseDatabase
import Firebase
import TwitterKit

class SurveyListView: UITableViewController {
    
    let database = FIRDatabase.database()
    var surveyKeys: [String] = []
    var data: [Survey] = []
    
    func delay(delay: Double, closure: ()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(),
            closure
        )
    }
    
    func getValidSurveysForUserID(userID: String) {
        database.reference().child("/users-permissions").child(userID).observeEventType(.Value, withBlock: { (permissedSurveys) in
            
            if permissedSurveys.value != nil {
                
                if let surveyIterator = permissedSurveys.value!["granted"]! as? [String: AnyObject] {
                    
                    for survey in surveyIterator {
                        
                        self.surveyKeys.append(survey.0)
                        print("Appended survey with key: " + survey.0 + " to the valid surveys list...")
                        
                    }
                    
                }
                
            }
            
            
            })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let uid = Twitter.sharedInstance().sessionStore.session()?.userID {
            self.getValidSurveysForUserID(uid)
            print("Logged in with: " + uid)
        } else {
            print("Not logged in")
        }
        
        let databaseRef = database.reference().child("/surveys")
        
        databaseRef.observeEventType(FIRDataEventType.Value, withBlock: { (snapshot) in
            let surveyDict = snapshot.children
            
            for survey in surveyDict {
                
                if self.surveyKeys.contains(survey.value["key"] as! String) {
                    print("Adding data " + (survey.value["key"] as! String))
                    self.data.append(Survey(type: survey.value["time"] as! String,
                                            reward: survey.value["reward"] as! Int,
                                            name: survey.value["name"] as! String,
                                            key: survey.value["key"] as! String))
                    self.tableView.reloadData()
                } else {
                    print("Not permitted to access: " + String(survey.value["key"] as! String))
                }
            }
            
        })
        
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("survey", forIndexPath: indexPath) as! SurveyCell
        cell.surveyName.text = data[indexPath.item].name
        cell.surveyReward.text = "CS " + String(data[indexPath.item].reward)
        cell.surveyTime.text = data[indexPath.item].type
        cell.surveyKey.text = data[indexPath.item].key
        return cell
    }
    
}
