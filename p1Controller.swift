//
//  p1Controller.swift
//  hw9
//
//  Created by Lizhi Lu on 5/2/16.
//  Copyright © 2016 Lizhi Lu. All rights reserved.
//

import UIKit
//import Alamofire
import CoreData
import Alamofire
import FBSDKShareKit

class p1Controller: UIViewController, UITableViewDataSource,FBSDKSharingDelegate{

    var text1: String = ""
    var updown: [String] = ["Up","Up"]
    var data: [String] = []
    var ti: [String]=[]
    
    @IBOutlet weak var star: UIImageView!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var image: UIImageView!
    
    @IBOutlet weak var c1: UIButton!
    
    let moc = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    
    @IBAction func facebook(sender: AnyObject) {
        let content: FBSDKShareLinkContent = FBSDKShareLinkContent ()
        content.contentURL = NSURL(string: "http://finance.yahoo.com/")
        content.contentTitle = "Current Stock Price of "+data[0]+" is "+data[2]
        content.contentDescription = "Stock Information of "+data[0]+" ("+data[1]+")"
        content.imageURL = NSURL(string: "http://chart.finance.yahoo.com/t?s="+data[1]+"&lang=en-US&width=300&height=300")
        FBSDKShareDialog.showFromViewController(self, withContent: content,delegate:self)
    
    }
    
    func sharer(sharer: FBSDKSharing!, didCompleteWithResults results:[NSObject: AnyObject]){
        //print(results["postId"]!)
        
        if results["postId"] == nil{
            let alert = UIAlertView()
            alert.title = "Post Cancelled"
            alert.addButtonWithTitle("Ok")
            alert.show()
        }else{
            let alert = UIAlertView()
            alert.title = "Post Successfully"
            alert.addButtonWithTitle("Ok")
            alert.show()
        }
    }
    
    func sharer(sharer: FBSDKSharing!, didFailWithError error: NSError!) {
        print("sharer NSError")
        //println(error.description)
    }
    
    func sharerDidCancel(sharer: FBSDKSharing!)
    {
        let alert = UIAlertView()
        alert.title = "Post Cancelled"
        alert.addButtonWithTitle("Ok")
        alert.show()
    }

    
    
    @IBAction func like(sender: AnyObject) {
        let req = NSFetchRequest(entityName: "List")
        do{
            var isvalid = false
            var index = -1
            let res = try moc.executeFetchRequest(req)
            let l = res as! [NSManagedObject]
            for var i=0;i<l.count;i=i+1{
                let a = l[i] as! List
                if (a.symbol!) == text1{
                    isvalid = true
                    index = i
                    break
                }
            }
            if isvalid == false{
                let ed = NSEntityDescription.entityForName("List", inManagedObjectContext: moc)
                let l = List(entity: ed!, insertIntoManagedObjectContext:moc)
                l.symbol = text1
                do{
                    try moc.save()
                    print("Successfully saved")
                    star.image = UIImage(named: "Starfilled")
                    
                }catch
                {
                    print("Failed to save")
                }
                
            }else{
                do{
                    moc.deleteObject(res[index] as! NSManagedObject)
                    try moc.save()
                    star.image = UIImage(named: "Star")
                }catch{
                    print("error")
                }
                
            }
            
        }catch{
            print("error")
        }

        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        navigationItem.hidesBackButton = true
        navigationItem.title=text1
        let newBackButton = UIBarButtonItem(title: "<Back", style: UIBarButtonItemStyle.Plain, target: self, action:"back:")
        self.navigationItem.leftBarButtonItem = newBackButton
        
        c1.layer.cornerRadius = 5
        let req = NSFetchRequest(entityName: "List")
        do{
            var isvalid = false
            let res = try moc.executeFetchRequest(req)
            let l = res as! [NSManagedObject]
            for var i=0;i<l.count;i=i+1{
                let a = l[i] as! List
                if (a.symbol!) == text1{
                    isvalid = true
                    break
                }
            }
            if isvalid == true{
                star.image = UIImage(named: "Starfilled")
            }else{
                star.image = UIImage(named: "Star")
            }
            
        }catch{
            print("error")
        }
        
        if(text1 != ""){
            Alamofire.request(.GET, "http://ajaxjsonandresponsi-env.us-west-1.elasticbeanstalk.com/", parameters: ["company1": text1])
                .responseJSON{ response in
                    if let detail = response.result.value {
                        let Name=detail["Name"] as! String
                        let Symbol=detail["Symbol"] as! String
                        let LastPrice=detail["LastPrice"] as! Double
                        let Change=Double(round((detail["Change"] as! Double)*100)/100)
                        if Change<0.0{
                            self.updown[0]="Down"
                        }
                        //print(Change)
                        let ChangePercent=Double(round((detail["ChangePercent"] as! Double)*100)/100)
                        let datestring=detail["Timestamp"] as! String
                        //let dateformatter=NSDateFormatter()
                        //dateformatter.dateFormat="MM/dd/yyyy HH:mm"
                        //let date=dateformatter.dateFromString(datestring)
                        //let d=dateformatter.stringFromDate(date!)
                        //print(date)
                        //print(datestring)
                        
                        let full=datestring.componentsSeparatedByString(" ")
                        let t: String = (full[3] as NSString).substringToIndex(5)
                        let date: String=full[1]+" "+full[2]+" 2016 "+t
                        print(date)
                        let Cap=detail["MarketCap"] as! Double
                        var MarketCap: String=""
                        if(Cap/1000000000)<0.005{
                            MarketCap="\(Double(round(Cap/10000)/100))"+" Million"
                        }else{
                            MarketCap="\(Double(round(Cap/10000000)/100))"+" Billion"
                        }
                        //print(MarketCap)
                        let Volume=detail["Volume"] as! Int
                        let ChangeYTD=Double(round((detail["ChangeYTD"] as! Double)*100)/100)
                        if ChangeYTD<0.0{
                            self.updown[1]="Down"
                        }
                        let ChangePercentYTD=Double(round((detail["ChangePercentYTD"] as! Double)*100)/100)
                        //print(ChangeYTD)
                        //print(ChangePercentYTD)
                        let High=detail["High"] as! Double
                        let Low=detail["Low"] as! Double
                        let Open=detail["Open"] as! Double
                        var stockdetail:[String]=[]
                        stockdetail.append(Name)
                        stockdetail.append(Symbol)
                        stockdetail.append("$ "+"\(LastPrice)")
                        if Change>0.0{
                            stockdetail.append("+"+"\(Change)"+"("+"\(ChangePercent)"+"%)")
                        }else{
                            stockdetail.append("\(Change)"+"("+"\(ChangePercent)"+"%)")
                        }
                        stockdetail.append(date)
                        stockdetail.append(MarketCap)
                        stockdetail.append("\(Volume)")
                        if ChangeYTD>0.0{
                            stockdetail.append("+"+"\(ChangeYTD)"+"("+"\(ChangePercentYTD)"+"%)")
                        }else{
                            stockdetail.append("\(ChangeYTD)"+"("+"\(ChangePercentYTD)"+"%)")
                        }
                        stockdetail.append("$ "+"\(High)")
                        stockdetail.append("$ "+"\(Low)")
                        stockdetail.append("$ "+"\(Open)")
                        print(stockdetail)
                        self.data=stockdetail
                        self.ti=["Name","Symbol","Last Price","Change","Time and Date","Market Cap","Volume","Change YTD","High Price","Low Price","Opening Price"]
                        dispatch_async(dispatch_get_main_queue(), {()->Void in
                            self.tableview.reloadData()
                            let url = NSURL(string:"http://chart.finance.yahoo.com/t?s="+self.text1+"&lang=en-US&width=300&height=300")
                            let data = NSData(contentsOfURL:url!)
                            if data != nil {
                                self.image.image = UIImage(data:data!)
                            }
                            
                        })
                    }
            }
        }
        
        
    }
    
    func back(sender:UIBarButtonItem) {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell=tableView.dequeueReusableCellWithIdentifier("cell1", forIndexPath: indexPath) as! CustomerCell
        cell.title.text=ti[indexPath.row]
        cell.details.text=data[indexPath.row]
        if cell.title.text=="Change"{
            cell.upordown.image=UIImage(named: updown[0])
        }
        if cell.title.text=="Change YTD"{
            cell.upordown.image=UIImage(named: updown[1])
        }
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier=="tohistorical" {
            let history: p2Controller=segue.destinationViewController as! p2Controller
            history.text2=text1
        }
        if segue.identifier=="currtonews"{
            let news: p3Controller=segue.destinationViewController as! p3Controller
            news.text3=text1
            print("aaa")
        }
    }
    

    override func didReceiveMemoryWarning(){
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
