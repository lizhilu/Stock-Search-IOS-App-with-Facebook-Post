//
//  p2Controller.swift
//  hw9
//
//  Created by Lizhi Lu on 5/2/16.
//  Copyright © 2016 Lizhi Lu. All rights reserved.
//

import UIKit
import CoreData

class p2Controller: UIViewController, UIWebViewDelegate{
    
    var text2: String = ""
    @IBOutlet weak var webview: UIWebView!
    @IBOutlet weak var h2: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        navigationItem.hidesBackButton = true
        navigationItem.title=text2
        let newBackButton = UIBarButtonItem(title: "<Back", style: UIBarButtonItemStyle.Plain, target: self, action:"back:")
        self.navigationItem.leftBarButtonItem = newBackButton
        
        print(text2)
        h2.layer.cornerRadius = 5
        
        if let url=NSBundle.mainBundle().URLForResource("index", withExtension: "html"){
            let fragurl=NSURL(string: "#"+text2, relativeToURL: url)!
            let request=NSURLRequest(URL: fragurl)
            webview.delegate=self
            webview.loadRequest(request)
        }
        
    }
    
    func back(sender:UIBarButtonItem) {
        //let ViewController = self.storyboard!.instantiateViewControllerWithIdentifier("ViewController")
        //self.navigationController?.pushViewController(ViewController, animated: true)
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier=="tonews"{
            let news:p3Controller=segue.destinationViewController as! p3Controller
            news.text3=text2
        }
        if segue.identifier=="histocurr"{
            let curr: p1Controller=segue.destinationViewController as! p1Controller
            curr.text1=text2
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
