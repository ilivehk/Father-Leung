//
//  ViewController.swift
//  Father Leung
//
//  Created by Michael Lo on 2/10/2017.
//  Copyright © 2017年 noading. All rights reserved.
//

import UIKit
import AudioToolbox
import MediaPlayer
import AVFoundation

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var playButtonEnable = false
    var tablev = [String]()
    var player:AVAudioPlayer = AVAudioPlayer()
    var audioPlayer:AVAudioPlayer!
     let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    

    
    @IBOutlet weak var dateText: UITextField!
    @IBOutlet weak var table: UITableView!
    
    @IBOutlet weak var yearPickerView: UIPickerView!
    @IBOutlet weak var monthPickerView: UIPickerView!
    
    @IBOutlet weak var rightBarButton: UIBarButtonItem!
    @IBOutlet weak var topBar: UINavigationItem!
    
    
    @IBAction func actionButton(_ sender: Any) {
        
        if playButtonEnable {
        
        if audioPlayer.isPlaying {
            
            audioPlayer.pause()
            self.topBar.rightBarButtonItem?.title = "Pause"
            
            
        }else {
            
           audioPlayer.play()
            self.topBar.rightBarButtonItem?.title = "Play"
            
            
        }
        }else{
            
            print("no play yet")
            
        }
        
    
    }
    
    
    
    let month = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"]
    let year = ["2009", "2010", "2011", "2012", "2013", "2014", "2015", "2016", "2017", ]
    
    var currentYear = "2017"
    var currentMonth = "10"
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView == yearPickerView {
             return year[row]
        } else if pickerView == monthPickerView{
             return month[row]
        } else {
            
            return month[row]
        }
        
        
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        
        if pickerView == yearPickerView {
                return year.count
        } else if pickerView == monthPickerView{
                return month.count
        } else {
               return month.count
        }
        
        
        
    
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        
        if pickerView == yearPickerView {
            currentYear = year[row]
        } else if pickerView == monthPickerView{
            currentMonth = month[row]
        }
        
        loadpage(year: Int(currentYear)!, month: Int(currentMonth)!)
        
        
    }
    
    @IBAction func goButton(_ sender: Any) {
        

        let tableArr = UserDefaults.standard.object(forKey: "tableArray")
        if let arrayObject = tableArr as? NSArray {
            
            print(arrayObject.count)
            print(arrayObject[1])
            tablev = arrayObject as! [String]
            
            table.reloadData()
            
            
        }
        
    }
    
    func configureCommandCenter() {
        
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.pauseCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
            let canPause = true // <-- TODO: check if there is a file to pause
            if canPause {
                if let audioPlayer = self.audioPlayer, audioPlayer.isPlaying {
                    audioPlayer.pause()
                    print("pause command failed")
                    return .success
                }
            }
            print("pause command failed")
            return .commandFailed
        }
        
        commandCenter.playCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
            let canPlay = true // <-- TODO: check if there is a file to play
            if canPlay {
                if let audioPlayer = self.audioPlayer, !audioPlayer.isPlaying {
                    audioPlayer.play()
                    print("play command success")
                    return .success
                }
            }
            print("play command failed")
            return .commandFailed
        }
    }
    
    func playdownload(song: String) {
        
        if let audioUrl = URL(string: song) {

            let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let destinationUrl = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent)

            configureCommandCenter()
            
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                try AVAudioSession.sharedInstance().setActive(true)
                audioPlayer = try AVAudioPlayer(contentsOf: destinationUrl)
                
                guard let player = audioPlayer else { return }
                
                MPNowPlayingInfoCenter.default().nowPlayingInfo = [MPMediaItemPropertyTitle: "梁神父講道"]


                player.prepareToPlay()
                player.play()
                showPlay()
                
            } catch let error {
                print(error.localizedDescription)     
            }
           
        }
        

        
    }
    
    
    
    func downloadFile(song:String) {
        
       
        
        if let audioUrl = URL(string: song) {
            
            // then lets create your document folder url
            let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            
            // lets create your destination file url
            let destinationUrl = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent)
            print(destinationUrl)
            
            // to check if it exists before downloading it
            if FileManager.default.fileExists(atPath: destinationUrl.path) {
                print("The file already exists at path")
                playdownload(song: song as String)
                // if the file doesn't exist
            } else {
                
                 activity(On: true)
             
                
                // you can use NSURLSession.sharedSession to download the data asynchronously
                URLSession.shared.downloadTask(with: audioUrl, completionHandler: { (location, response, error) -> Void in
                    guard let location = location, error == nil else { return }
                    do {
                        
                        // after downloading your file you need to move it to your destination url
                        try FileManager.default.moveItem(at: location, to: destinationUrl)
                        self.activity(On: false)
                        print("File moved to documents folder")
                        self.playdownload(song: song as String)
                        
                        
                    } catch let error as NSError {
                        print(error.localizedDescription)
                        self.activity(On: false)
                    }
                }).resume()
                
            }
            
           
    
        
        }
        
      
        
    }
    
    func showPlay(){
        
        playButtonEnable = true
        print("showPlay")
        
        
    }
    
    
    public func loadpage(year:Int, month:Int){
        
        print(year)
        print(month)
        
        
        UserDefaults.standard.set(year, forKey: "currYear")
        UserDefaults.standard.set(month, forKey: "currMonth")
        
        var talkArray = [String]()
        
        
        if let url = URL(string: "http://www.frpeterleung.com/homily-calendar.php?lang=c&y=" + String(year) + "&m=" + String(month)) {
            
            let request = NSMutableURLRequest(url: url)
            
            let task = URLSession.shared.dataTask(with: request as URLRequest) {
                data, response, error in
                
                if let error = error {
                    
                    print(error)
                    
                } else {
                    
                    if let unwrappedData = data {
                        
                        let dataString = NSString(data: unwrappedData, encoding: String.Encoding.utf8.rawValue)!
                        
                        //  print(dataString!)
                        
                        let seperator = "<div class='day-number'>"
                        
                        //  let sepArray = (dataString?.components(separatedBy: seperator))!
                        
                        talkArray = (dataString.components(separatedBy: seperator))
                        
                        UserDefaults.standard.set(talkArray, forKey: "tableArray")
                        
                        
                    }
                    
                    
                    
                }
                
                
            }
            
            task.resume()
        }
        
        
        
        return
        
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int   {
        
        
        
        return tablev.count-1
        
    }
    

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "Cell")
        
        
        let talkA = NSString(string:tablev[indexPath.row+1])
        var na = ""
        let titleA = talkA.components(separatedBy: "</div>")
        
        let titleB = talkA.components(separatedBy: "<div class='liturgicalDay'>")
        let titleB1 = titleB[1].components(separatedBy: "</div>")
        var titleC2 = String("")
        if talkA.contains("target='_blank'>"){
            let titleC = talkA.components(separatedBy: "target='_blank'>")
            let titleC1 = titleC[1].components(separatedBy: "</a>")
            titleC2 = titleC1[0]
        }else {
            
           na = "N/A "
        }
        
        
        
        cell.textLabel?.text = String(na + titleA[0] + "日 " + titleB1[0] + "-" + titleC2)

        return cell
        
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        
        if playButtonEnable {
            
            if audioPlayer.isPlaying {
                
            }else {
                
                audioPlayer.play()
                self.topBar.rightBarButtonItem?.title = "Play"
                
                
            }
        }
      
        
        let mp3Link = NSString(string:tablev[indexPath.row+1])
        
        if mp3Link.contains("MP3"){
        
        let mp3Link1 = mp3Link.components(separatedBy: "<a href='")
        
        let mp3Link2 = mp3Link1[1].components(separatedBy: "' target='_blank'>")
            
        let mp3Link3 = "http://www.frpeterleung.com" + mp3Link2[0]
        
        print(mp3Link3)
            
        downloadFile(song: mp3Link3 as String)

        }

    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        
  
  
        yearPickerView.selectRow(8, inComponent: 0, animated: true)
        monthPickerView.selectRow(9, inComponent: 0, animated: true)

        let tableArr = UserDefaults.standard.object(forKey: "tableArray")
        if let arrayObject = tableArr as? NSArray {
            
            print(arrayObject.count)
            print(arrayObject[1])
            tablev = arrayObject as! [String]
            
            table.reloadData()
        }
    }
    
    func activity(On:Bool){
        
        if On {
            
            print("activityOn")
            
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
                   UIApplication.shared.beginIgnoringInteractionEvents()
            
        }else {
            print("activityOffed")
            
            DispatchQueue.main.async {
                 UIApplication.shared.endIgnoringInteractionEvents()
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
            }
            
        }
 
        
    }

}
