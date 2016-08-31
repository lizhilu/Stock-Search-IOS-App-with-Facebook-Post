//
//  p3Controller.swift
//  hw9
//
//  Created by Lizhi Lu on 5/2/16.
//  Copyright © 2016 Lizhi Lu. All rights reserved.
//

import UIKit
import CoreData
import Alamofire

class p3Controller: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    var text3: String = ""
    var url:[String]=[]
    var ti:[String]=[]
    var des: [String]=[]
    var publish:[String]=[]
    var date:[String]=[]
    
    
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var n3: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        //navigationItem.hidesBackButton = false
        navigationItem.hidesBackButton = true
        navigationItem.title=text3
        let newBackButton = UIBarButtonItem(title: "<Back", style: UIBarButtonItemStyle.Plain, target: self, action:"back:")
        self.navigationItem.leftBarButtonItem = newBackButton
        print(text3)
        
        n3.layer.cornerRadius = 5
        
        if(text3 != ""){
            Alamofire.request(.GET, "http://ajaxjsonandresponsi-env.us-west-1.elasticbeanstalk.com/", parameters: ["company3": text3])
                .responseJSON{ response in
                    if let detail = response.result.value {
                        //print("\(detail["d"])")
                        let data=detail.dataUsingEncoding(NSUTF8StringEncoding,allowLossyConversion: false)!
                        do {
                            let json = try NSJSONSerialization.JSONObjectWithData(data, options: []) as! [String: AnyObject]
                            let result=json["d"]!["results"]!!
                            let size=result.count
                            //print(size)
                            for var i=0;i<size;i=i+1{
                                self.url.append(result[i]["Url"] as! String)
                                self.ti.append(result[i]["Title"] as! String)
                                self.des.append(result[i]["Description"] as! String)
                                self.publish.append(result[i]["Source"] as! String)
                                self.date.append(result[i]["Date"] as! String)
                            }
                            dispatch_async(dispatch_get_main_queue(), {()->Void in
                                self.tableview.reloadData()
                            })
                            
                        } catch let error as NSError {
                            print("Failed to load: \(error.localizedDescription)")
                        }
                        
                    }
            }
        }
    }

    func back(sender:UIBarButtonItem) {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell=tableView.dequeueReusableCellWithIdentifier("cell3", forIndexPath: indexPath) as! newscell
        cell.title.text = ti[indexPath.row]
        cell.title.numberOfLines = 2
        cell.des.text=des[indexPath.row]
        cell.des.numberOfLines = 5
        cell.publish.text=publish[indexPath.row]
        cell.date.text=date[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ti.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let url = NSURL(string: url[indexPath.row]) {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier=="newstocurr"{
            let curr: p1Controller=segue.destinationViewController as! p1Controller
            curr.text1=text3
        }
        if segue.identifier=="newstohis"{
            let his:p2Controller=segue.destinationViewController as! p2Controller
            his.text2=text3
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
