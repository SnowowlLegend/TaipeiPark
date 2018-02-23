//
//  ViewController.swift
//  TaiepiParkS
//
//  Created by Richard on 2018/01/31.
//  Copyright © 2018年 Snowowl. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate {

    @IBOutlet weak var aTableView: UITableView! {
        didSet {
            aTableView.dataSource = self
            aTableView.delegate = self
        }
    }
    
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    var queryTimer : Timer?
    var timeoutTimer : Timer?
    var timeout : TimeInterval!
    var responseData : NSMutableData?
    
    var sectionArray : NSMutableArray?
    var tableviewArray : NSMutableArray?
    var nearbyviewArray: NSMutableArray?
    
    var selectedIndexPath : IndexPath?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        activityView.startAnimating()
        
        self.startQueryTimer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        aTableView.rowHeight = UITableViewAutomaticDimension
        aTableView.estimatedRowHeight = 150
    }
    
    // MARK: HTTP Connection
    
    @objc func startConnection() {
        let urlString = Constant.Query_Remote_Url
        let url = URL.init(string: urlString)!
        let request = URLRequest.init(url: url, cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: Constant.Query_Timeout_Interval)
        let sessionConfiguration = URLSessionConfiguration.default
        let queue = OperationQueue.main
        let session = URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: queue)
        let task = session.dataTask(with: request as URLRequest!)
        task.resume()
    }
    
    func startQueryTimer() {
        if queryTimer == nil {
            queryTimer = Timer.scheduledTimer(timeInterval: Constant.Query_Timer_Interval, target: self, selector: #selector(self.startConnection), userInfo: nil, repeats: false)
        }
    }
    
    
    // MARK: HTTP NSURLSessionDelegate
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        let httpResponse = response as! HTTPURLResponse
        let statusCode = httpResponse.statusCode
        
        if statusCode != 200 {
            print("didReceive response error: \(statusCode)")
            print("didReceive response: \(response)")
        } else if statusCode == 200 {
            print("didReceive response successful")
            responseData = NSMutableData.init()
            completionHandler(.allow)
        }
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        responseData?.append(data)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if error != nil {
            print("didCompleteWithError error: \(error!)")
        }
        else {
            let jsonString = String.init(data: responseData as Data!, encoding: String.Encoding.utf8)
            print("didCompleteWithError data: \(jsonString!)")
            
            self.parseNprocess(with: jsonString!)
        }
    }

    // MARK: Parsing JSON Data
    
    func parseNprocess(with jsonString: String) {
        let jsonData = jsonString.data(using: String.Encoding.utf8)
        let json = try! JSONSerialization.jsonObject(with: jsonData!, options: [JSONSerialization.ReadingOptions.mutableContainers]) as! NSDictionary

        sectionArray = NSMutableArray.init()
        tableviewArray = NSMutableArray.init()
        
        let result = json["result"] as! NSDictionary
        let results = result["results"] as! NSArray
        
        var imageCount = 0
        var thumbCount = 0
        
        if results.lastObject != nil {
            var currentItem = results[0] as! NSDictionary
            sectionArray?.add(currentItem)
            
            let nearbyArray = NSMutableArray.init()
            
            var loadedImageCount = 0
            
            for index in stride(from: 0, to: results.count, by: 1) {
                let item = results[index] as! NSDictionary
                let imageURL = item["Image"] as! String
                let parkName = item["ParkName"] as! String
                let name = item["Name"] as! String
                let introduction = item["Introduction"] as! String
                let openTime = item["OpenTime"] as! String
                let yearBuilt = item["YearBuilt"] as! String
                
                print("\nImage URL: \(imageURL),\nPark Name:\(parkName),\nName: \(name),\nOpen Time: \(openTime),\nYear Build: \(yearBuilt),\nIntroduction: \(introduction)\n")
                
                if imageURL != "" {
                    imageCount += 1
                }
                
                let cellItem = NSMutableDictionary(dictionary: item)
                
                DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                    if let url = URL.init(string: imageURL) {
                        if let imageData = NSData.init(contentsOf: url) as Data? {
                        
                            DispatchQueue.main.async { [weak self] in
                                if let image = UIImage.init(data: imageData) {
                                    cellItem.setValue(image, forKey: "thumbImage")
                                    thumbCount += 1
                                    
                                    if thumbCount % 10 == 0 {
                                        loadedImageCount = thumbCount
                                    }
                                    
                                    if thumbCount - loadedImageCount >= 10 {
                                        self!.reloadTableView()
                                    }
                                }
                            }
                        }
                    }
                }
                
                let currentParkName = currentItem["ParkName"] as! String
                
                if parkName == currentParkName {
                    nearbyArray.add(cellItem)
                } else {
                    currentItem = cellItem
                    sectionArray?.add(currentItem)
                    
                    let itemArray = NSArray.init(array: nearbyArray)
                    tableviewArray?.add(itemArray)
                    nearbyArray.removeAllObjects()
                    nearbyArray.add(cellItem)
                }
            }
            
            tableviewArray?.add(nearbyArray)
        }
        
        reloadTableView()
    }
    
    func reloadTableView() {
        DispatchQueue.main.async { [weak self] in
            if self!.tableviewArray?.lastObject != nil {
                self!.aTableView.reloadData()
                
                self!.activityView.stopAnimating()
            }
        }
    }
    
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if sectionArray?.lastObject != nil {
            print("sections: \(sectionArray!.count)")
            return sectionArray!.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows = 0
        if tableviewArray!.lastObject != nil {
            if tableviewArray!.count > section {
                if let sectionItem = tableviewArray![section] as? NSArray {
                    rows = sectionItem.count
                    print("rows: \(rows) in section: \(section)")
                }
            } else {
                return 0
            }
        }
        else {
            return 0
        }
        
        return rows
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var headerTitle = ""

        if sectionArray!.lastObject != nil {
            if section < sectionArray!.count {
                if let sectionItem = sectionArray![section] as? NSDictionary {
                    headerTitle = sectionItem["ParkName"] as! String
                    print("title: \(headerTitle) of section: \(section)")
                }
            }
        }
        return headerTitle
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = aTableView.dequeueReusableCell(withIdentifier: "Park Cell") as? ParkListTableViewCell

        if cell == nil {
            cell = UITableViewCell.init(style: UITableViewCellStyle.subtitle, reuseIdentifier: "Park Cell") as? ParkListTableViewCell
        }
        
        if tableviewArray!.lastObject != nil {
            if tableviewArray!.count > indexPath.row {
                if let sectionItem = tableviewArray![indexPath.section] as? NSArray {
                    if let cellItem = sectionItem[indexPath.row] as? NSDictionary {
                        let parkName = cellItem["ParkName"] as! String
                        let name = cellItem["Name"] as! String
                        let introduction = cellItem["Introduction"] as! String
                        
                        var image = cellItem["thumbImage"] as? UIImage
                        
                        if image == nil {
                            image = UIImage.init(named: "Round_Landmark_Icon_Park")
                        }
                        
                        cell?.parkImageView.image = image
                        cell?.parkNameLabel.text = parkName
                        cell?.nameLabel.text = name
                        cell?.parkIntroLabel.text = introduction
                    }
                }
            }
        }

        return cell!
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        
        performSegue(withIdentifier: "Show Detail", sender: nil)

        tableView.deselectRow(at: indexPath, animated: true)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
        
        if segue.identifier == "Show Detail" {
            if segue.destination is ParkDetailViewController {
                if let pdvc = segue.destination as? ParkDetailViewController {
                    let sectionItem = tableviewArray![selectedIndexPath!.section] as! NSArray
                    let cellItem = sectionItem[selectedIndexPath!.row] as! NSDictionary
                    pdvc.parkItem = cellItem
                    pdvc.nearbyviewArray = sectionItem
                }
            }
        }
        
     }
    

}

struct Constant {
    static let Query_Remote_Url = "http://data.taipei/opendata/datalist/apiAccess?scope=resourceAquire&rid=bf073841-c734-49bf-a97f-3757a6013812"
    static let Query_Timer_Interval = 3.0
    static let Query_Timeout_Interval = 15.0
}

