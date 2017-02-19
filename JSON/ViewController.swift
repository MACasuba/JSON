//
//  ViewController.swift
//  JSON
//
//  Created by MACasuba on 09-02-17.
//  Copyright © 2017 com.MACasuba.JSON. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import Foundation
import TVMLKit


class ViewController: UIViewController, UIApplicationDelegate, TVApplicationControllerDelegate {
    
    // MARK: Properties
    var window: UIWindow?
    var appController: TVApplicationController?
    
    let _baseUrl: String = "http://a1.phobos.apple.com/us/r1000/000/Features/atv/AutumnResources/videos"
    
    var _allAssets: Array<AnyObject> = Array()
    var _assets: Array<(url: String, timeOfDay: String,id: String, accessibilityLabel: String)> = Array()
  
    var _moviePlayer:AVPlayer!
    
    let _playerViewController = AVPlayerViewController()
    var _nextItem: AVPlayerItem!
    var _url: String = "", _id: String = "", _timeofday: String = "", _accessibilitylabel: String = ""
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("Something did appear")
    }

    
override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    getJSON()
    shuffleVideos()
    setupPlayer()
    start()

    }//end func

    
    func setupPlayer() -> Void {
        _moviePlayer = AVPlayer()
        
        //_moviePlayer.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: nil)
        
        _playerViewController.player = _moviePlayer
        _playerViewController.view.frame = view.frame
        
        _playerViewController.showsPlaybackControls = true //was false
        //_playerViewController.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        self.view.addSubview(_playerViewController.view)
        self.addChildViewController(_playerViewController)
    }
    
  
    
    func shuffleVideos() -> Void {
        _assets.shuffleInPlace()
    }
    
    func getNextVideo() -> (url: String, id: String, timeOfDay: String, accessibilityLabel: String) {
        let video = _assets.removeFirst()
        _assets.append(video)
        return video
    }
    
    func getRandomVideo() -> (url: String, id: String, timeOfDay: String, accessibilityLabel: String) {
        let video = _assets[Int(arc4random_uniform(UInt32(_assets.count)))]
        _assets.append(video)
        return video
    }
    
    func start() -> Void {
        (_url, _id, _timeofday, _accessibilitylabel) = getNextVideo()
        _nextItem = AVPlayerItem(url: URL(string: _url)!)
        _moviePlayer.replaceCurrentItem(with: _nextItem)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }





    func getJSON() -> Void {
        if let urlA = NSURL(string:"\(_baseUrl)/entries.json") {
            if let theURL = try? Data(contentsOf: urlA as URL) {
                do {
                    let parsedData = try JSONSerialization.jsonObject(with: theURL, options: JSONSerialization.ReadingOptions.mutableContainers) as! Array<AnyObject>
                    _allAssets = parsedData //telt alle assets = 12
                    processAssetsDay()
                }catch{
                    print("Details of JSON parsing error:\n \(error)")
                    print(error)
                }//end err
            }// end if
        }// end if
    }
    

    
    func processAssetsDay() -> Void {
        for i in 0..<_allAssets.count {
            let allAssets = _allAssets[i] as! Dictionary<String, AnyObject> //alle arrays in de JSON
            let assets = allAssets["assets"] as! Array<AnyObject> // alle items van iedere assets
            
            for j in 0..<assets.count {
                let asset: Dictionary<String, AnyObject> = assets[j] as! Dictionary<String, AnyObject>
            
            _assets.append((asset["url"] as! String, asset["id"] as! String,asset["timeOfDay"] as! String, asset["accessibilityLabel"] as! String))
                
            }//end j
        }// end i
        //print ("asset : \(_assets)")
    }//end process ass
    
    
func processAssets() -> Void {
    for i in 0..<_allAssets.count {
        let allAssets = _allAssets[i] as! Dictionary<String, AnyObject>
        let assets = allAssets["assets"] as! Array<AnyObject>

        for j in 0..<assets.count {
            let asset: Dictionary<String, AnyObject> = assets[j] as! Dictionary<String, AnyObject>
            _assets.append((asset["url"] as! String, asset["id"] as! String,asset["timeOfDay"] as! String, asset["accessibilityLabel"] as! String))
        }//end j
    }// end i
    //print ("asset : \(_assets)")
}//end
    
    
}


extension Collection {
    /// Return a copy of `self` with its elements shuffled
    func shuffle() -> [Iterator.Element] {
        var list = Array(self)
        list.shuffleInPlace()
        return list
    }
}

extension MutableCollection where Index == Int {
    /// Shuffle the elements of `self` in-place.
    mutating func shuffleInPlace() {
        // empty and single-element collections don't shuffle
        if count < 2 { return }
        
        for i in startIndex ..< endIndex - 1 {
            let j = Int(arc4random_uniform(UInt32(endIndex - i))) + i
            if i != j {
                swap(&self[i], &self[j])
            }//if
        }//i
    }//
}//
