//
//  ParkDetailViewController.swift
//  TaiepiParkS
//
//  Created by Richard on 2018/02/22.
//  Copyright © 2018年 Snowowl. All rights reserved.
//

import UIKit

class ParkDetailViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var aScrollView: UIScrollView! {
        didSet {
            aScrollView.isScrollEnabled = true
            aScrollView.showsVerticalScrollIndicator = true
            aScrollView.showsHorizontalScrollIndicator = true
        }
    }
    
    @IBOutlet weak var scrollContentView: UIView!
    
    @IBOutlet weak var parkImageView: UIImageView!
    
    @IBOutlet weak var parkNameLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var openTimeLabel: UILabel!
    
    @IBOutlet weak var parkIntroLabel: UILabel!
    
    @IBOutlet weak var aCollection: UICollectionView! {
        didSet {
            aCollection.backgroundColor = UIColor.white
            aCollection.dataSource = self
            aCollection.delegate = self
            aCollection.isScrollEnabled = true
            aCollection.showsVerticalScrollIndicator = false
            aCollection.showsHorizontalScrollIndicator = true
        }
    }
    
    var parkItem : NSDictionary?
    var nearbyviewArray : NSArray?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    func loadData() {
        if parkItem != nil {
            let parkName = parkItem?.object(forKey: "ParkName") as! String
            let name = parkItem?.object(forKey: "Name") as! String
            let introduction = parkItem?.object(forKey: "Introduction") as! String
            let openTime = parkItem?.object(forKey: "OpenTime") as! String
            
            let image = parkItem?.object(forKey: "thumbImage") as! UIImage
            
            self.parkNameLabel.text = parkName
            self.nameLabel.text = name
            self.openTimeLabel.text = openTime
            self.parkIntroLabel.text = introduction
            self.parkImageView.image = image
            
            self.parkIntroLabel.sizeToFit()
            
            var scrollContentSize = self.parkImageView.frame.size.height + self.parkNameLabel.frame.size.height + self.nameLabel.frame.size.height + self.openTimeLabel.frame.size.height + self.parkIntroLabel.frame.size.height + self.aCollection.frame.size.height
            scrollContentSize += 50
            
            let contentViewFrame = CGRect(x: 0, y: 0, width: self.aScrollView.frame.size.width, height: scrollContentSize)
            
            self.scrollContentView.frame = contentViewFrame
            
            self.aScrollView.contentSize = CGSize(width: contentViewFrame.size.width, height: contentViewFrame.size.height)
        }
    }

    // MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if nearbyviewArray?.lastObject != nil {
            return nearbyviewArray!.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as? ParkCollectionViewCell
        let cellItem = nearbyviewArray![indexPath.row] as! NSDictionary
        
        let image = cellItem.object(forKey: "thumbImage") as! UIImage
        cell!.photoImageView.image = image
        cell!.nameLabel.text = cellItem.object(forKey: "Name") as! String?
        return cell!
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cellItem = nearbyviewArray![indexPath.row] as! NSDictionary
        
        parkItem = cellItem
        loadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
