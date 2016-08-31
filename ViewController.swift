//
//  ViewController.swift
//  hw9
//
//  Created by Lizhi Lu on 5/2/16.
//  Copyright © 2016 Lizhi Lu. All rights reserved.
//

import UIKit
import CoreData
import CCAutocomplete
import Alamofire

class ViewController: UIViewController, UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate, AutocompleteDelegate{
    
    let moc = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    var symbol:[String] = []
    var company:[String] = []
    var price:[String] = []
    var change:[String] = []
    var market:[String] = []
    var timer = NSTimer()
    
    var curr: String = ""

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var tableview: UITableView!
    
    func fre() -> Void {
        var num: Int = 0
        
        let req = NSFetchRequest(entityName: "List")
        do{
            let res = try moc.executeFetchRequest(req)
            num = res.count
            print(num)
        }catch{
            print("error")
        }
        if num == 0{
            self.symbol=[]
            self.company=[]
            self.change=[]
            self.market=[]
            self.price=[]
            self.tableview.reloadData()
        }
        if num>0{
            self.indicator.startAnimating()
            var s = [String](count: num, repeatedValue: "")
            var com = [String](count: num, repeatedValue: "")
            var p = [String](count: num, repeatedValue: "")
            var cha = [String](count: num, repeatedValue: "")
            var m = [String](count: num, repeatedValue: "")
            do{
                let res = try moc.executeFetchRequest(req)
                var l = res as! [NSManagedObject]
                for var i=0;i<l.count;i=i+1{
                    let a = l[i] as! List
                    let sy = a.symbol!
                    let index = i
                    Alamofire.request(.GET, "http://ajaxjsonandresponsi-env.us-west-1.elasticbeanstalk.com/", parameters: ["company1": sy])
                        .responseJSON{ response in
                            if let detail = response.result.value {
                                let Name=detail["Name"] as! String
                                let Symbol=detail["Symbol"] as! String
                                let LastPrice=detail["LastPrice"] as! Double
                                let Change=Double(round((detail["Change"] as! Double)*100)/100)
                                let ChangePercent=Double(round((detail["ChangePercent"] as! Double)*100)/100)
                                let Cap=detail["MarketCap"] as! Double
                                var MarketCap: String=""
                                if(Cap/1000000000)<0.005{
                                    MarketCap="\(Double(round(Cap/10000)/100))"+" Million"
                                }else{
                                    MarketCap="\(Double(round(Cap/10000000)/100))"+" Billion"
                                }
                                s[index]=Symbol
                                com[index]=Name
                                p[index]="$ "+"\(LastPrice)"
                                cha[index]="\(Change)"+"("+"\(ChangePercent)"+"%)"
                                m[index]="Market Cap: "+MarketCap
                                var isv=true
                                for var i=0;i<s.count;i=i+1{
                                    if s[i]==""{
                                        isv=false
                                    }
                                }
                                if isv==true{
                                    self.symbol = s
                                    self.company = com
                                    self.price = p
                                    self.change = cha
                                    self.market = m
                                    self.indicator.stopAnimating()
                                    dispatch_async(dispatch_get_main_queue(), {()->Void in
                                        self.tableview.reloadData()
                                        
                                    })
                                }
                                
                            }
                    }
                    
                }
                
            }catch{
                print("error")
            }
            
        }
        
        
    }

    
    
    @IBAction func aufresh(sender: UISwitch) {
        if sender.on{
           
            timer = NSTimer.scheduledTimerWithTimeInterval(10.0, target: self, selector: #selector(ViewController.fre), userInfo: nil, repeats: true)
        }else{
            timer.invalidate()
        }
        
    }
    
    
    @IBAction func fresh(sender: AnyObject) {
        fre()
    }
    
    var autoCompleteViewController: AutoCompleteViewController!
    func autoCompleteTextField() -> UITextField {
        return self.textField
    }
    func autoCompleteThreshold(textField: UITextField) -> Int {
        return 2
    }
    func autoCompleteItemsForSearchTerm(term: String) -> [AutocompletableOption] {
        var dataauto:[String]=[]
        Alamofire.request(.GET, "http://ajaxjsonandresponsi-env.us-west-1.elasticbeanstalk.com/", parameters: ["symbol": term])
            .responseJSON{ response in
                if let JSON = response.result.value {
                    //print("JSON: \(JSON)")
                    let jsize=JSON.count
                    for var i=0;i<jsize;i=i+1{
                        let tmp1 = (JSON[i]["Symbol"] as! String)+"-"
                        let tmp2 = (JSON[i]["Name"] as! String)+"-"
                        let tmp3 = (JSON[i]["Exchange"] as! String)
                        dataauto.append(tmp1+tmp2+tmp3)
                    }
                }
        }
        var s:[AutocompletableOption]=[]
        for var j=0;j<dataauto.count;j=j+1{
            let symbol=(AutocompleteCellData(text: dataauto[j],image:nil) as AutocompletableOption)
            s.append(symbol)
        }
        return s
    }
    func autoCompleteHeight() -> CGFloat {
        return CGRectGetHeight(self.view.frame) / 3.0
    }
    func didSelectItem(item: AutocompletableOption) {
        self.textField.text = item.text
    }
    var isFirstLoad: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if self.isFirstLoad {
            self.isFirstLoad = false
            //Autocomplete.setupAutocompleteForViewcontroller(self)
           //Autocomplete.setupAutocompleteForViewcontroller(self)
            Autocomplete.setupAutocompleteForViewcontroller(self)
        }
    }

    @IBAction func GetQuote(sender: AnyObject) {
        if(textField.text==""){
            let alert = UIAlertView()
            alert.title = "Please Enter a Stock Name or Symbol"
            alert.addButtonWithTitle("Ok")
            alert.show()
        }else{
            var sym: String=""
            if((textField.text?.rangeOfString("-")) == nil){
                sym=textField.text!
            }else{
                let index=textField.text?.characters.indexOf("-")
                sym=(textField.text?.substringToIndex(index!))!
            }
            //print(sym)
            Alamofire.request(.GET, "http://ajaxjsonandresponsi-env.us-west-1.elasticbeanstalk.com/", parameters: ["company1": sym])
                .responseJSON{ response in
                    if let detail = response.result.value {
                        print("\(detail)")
                        //print(detail)
                        let err = detail["Message"]
                        //print(err)
                        if( (err as? String) != nil){
                            let alert = UIAlertView()
                            alert.title = "Invalid Symbol"
                            alert.addButtonWithTitle("Ok")
                            alert.show()
                        }else{
                            self.curr=sym
                            self.performSegueWithIdentifier("todetail", sender:self)
                        }
                    }
            }
        }

        
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier=="todetail" {
            let dest: p1Controller = segue.destinationViewController as! p1Controller
            dest.text1 = curr
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.textField.resignFirstResponder()
        return false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        //autocompleteContainer.hidden = true
        textField.clearButtonMode=UITextFieldViewMode.Always
        var num: Int = 0
        
        let req = NSFetchRequest(entityName: "List")
        do{
            let res = try moc.executeFetchRequest(req)
            num = res.count
            print(num)
        }catch{
            print("error")
        }
        if num == 0{
            self.symbol=[]
            self.company=[]
            self.change=[]
            self.market=[]
            self.price=[]
            self.tableview.reloadData()
        }
        if num>0{
            self.indicator.startAnimating()
            var s = [String](count: num, repeatedValue: "")
            var com = [String](count: num, repeatedValue: "")
            var p = [String](count: num, repeatedValue: "")
            var cha = [String](count: num, repeatedValue: "")
            var m = [String](count: num, repeatedValue: "")
            do{
                let res = try moc.executeFetchRequest(req)
                var l = res as! [NSManagedObject]
                for var i=0;i<l.count;i=i+1{
                    let a = l[i] as! List
                    let sy = a.symbol!
                    let index = i
                    Alamofire.request(.GET, "http://ajaxjsonandresponsi-env.us-west-1.elasticbeanstalk.com/", parameters: ["company1": sy])
                        .responseJSON{ response in
                            if let detail = response.result.value {
                                let Name=detail["Name"] as! String
                                let Symbol=detail["Symbol"] as! String
                                let LastPrice=detail["LastPrice"] as! Double
                                let Change=Double(round((detail["Change"] as! Double)*100)/100)
                                let ChangePercent=Double(round((detail["ChangePercent"] as! Double)*100)/100)
                                let Cap=detail["MarketCap"] as! Double
                                var MarketCap: String=""
                                if(Cap/1000000000)<0.005{
                                    MarketCap="\(Double(round(Cap/10000)/100))"+" Million"
                                }else{
                                    MarketCap="\(Double(round(Cap/10000000)/100))"+" Billion"
                                }
                                s[index]=Symbol
                                com[index]=Name
                                p[index]="$ "+"\(LastPrice)"
                                cha[index]="\(Change)"+"("+"\(ChangePercent)"+"%)"
                                m[index]="Market Cap: "+MarketCap
                                var isv=true
                                for var i=0;i<s.count;i=i+1{
                                    if s[i]==""{
                                        isv=false
                                    }
                                }
                                if isv==true{
                                    self.symbol = s
                                    self.company = com
                                    self.price = p
                                    self.change = cha
                                    self.market = m
                                    self.indicator.stopAnimating()
                                    //self.green = UIColor(red: 86, green: 173, blue: 103, alpha: 1)
                                    //self.red = UIColor(red: 215, green: 87, blue: 71,alpha: 1)
                                    dispatch_async(dispatch_get_main_queue(), {()->Void in
                                        self.tableview.reloadData()
                                        
                                    })
                                }
                                
                            }
                    }
                    
                }
                
            }catch{
                print("error")
            }
            
        }
    }

    
    /*override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }*/

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! maincell
        cell.symbol.text = symbol[indexPath.row]
        cell.company.text = company[indexPath.row]
        cell.price.text = price[indexPath.row]
        cell.change.text = change[indexPath.row]
        cell.market.text = market[indexPath.row]
        if cell.change.text![(cell.change.text?.startIndex.advancedBy(0))!]=="-"{
            cell.change.backgroundColor = UIColor.redColor()
        }else{
            cell.change.backgroundColor = UIColor.greenColor()
        }
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return symbol.count
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            symbol.removeAtIndex(indexPath.row)
            company.removeAtIndex(indexPath.row)
            price.removeAtIndex(indexPath.row)
            change.removeAtIndex(indexPath.row)
            market.removeAtIndex(indexPath.row)
            do{
                let req = NSFetchRequest(entityName: "List")
                let res = try moc.executeFetchRequest(req)
                moc.deleteObject(res[indexPath.row] as! NSManagedObject)
                try moc.save()
            }catch{
                print("error")
            }
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        curr = symbol[indexPath.row]
        self.performSegueWithIdentifier("todetail", sender:self)
    }

}

