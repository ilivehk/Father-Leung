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
    var chinese = true
    var lang = "c"
    var displayTitle = "梁達材神父講道"
    var talkList = [String]()
    var talkAddress = [String]()
    
    
    @IBOutlet weak var displayMonthLabel: UILabel!
    @IBOutlet weak var displayYearLabel: UILabel!
    @IBOutlet weak var langButton: UIButton!
    @IBOutlet weak var dateText: UITextField!
    @IBOutlet weak var table: UITableView!
    
    @IBOutlet weak var yearPickerView: UIPickerView!
    @IBOutlet weak var monthPickerView: UIPickerView!
    
    @IBOutlet weak var rightBarButton: UIBarButtonItem!
    @IBOutlet weak var topBar: UINavigationItem!
    
    @IBAction func languageButton(_ sender: Any) {
        
        if chinese {
            
            langButton.setTitle("Eng", for: .normal)
            chinese = false
            displayYearLabel.text = "Year"
            displayMonthLabel.text = "Month"
            lang = "e"
            topBar.title = "Father Leung Homily"
            displayTitle = "Father Leung Homily"
            UserDefaults.standard.set(false, forKey: "chinese")
            
        }else {
            
            langButton.setTitle("中", for: .normal)
            chinese = true
            displayYearLabel.text = "年"
            displayMonthLabel.text = "月"
            lang = "c"
            topBar.title = "梁達材神父講道"
            displayTitle = "梁達材神父講道"
            UserDefaults.standard.set(true, forKey: "chinese")
        }
        
        
    }
    
    @IBAction func addButton(_ sender: Any) {
        
        
        if currentMonth != month.last {
        
        currentMonth = String(Int(currentMonth)! + 1)
        
        }else if currentYear != year.last{
            
            currentMonth = "1"
            currentYear = String(Int(currentYear)! + 1)
        }else {
            
            print("return")
            return
            
        }
        
        
        
        yearPickerView.selectRow(Int(currentYear)! - 2009 , inComponent: 0, animated: true)
        monthPickerView.selectRow(Int(currentMonth)! - 1, inComponent: 0, animated: true)

        loadpage(year: Int(currentYear)!, month: Int(currentMonth)!)
        
        
        
    }
    
    @IBAction func minusButton(_ sender: Any) {
        
        
        if currentMonth != month.first {
            
            currentMonth = String(Int(currentMonth)! - 1)
            
        }else if currentYear != year.first{
            
            currentMonth = "12"
            currentYear = String(Int(currentYear)! - 1)
        }else {
            
            print("return")
            return
            
        }
        
        
        
        yearPickerView.selectRow(Int(currentYear)! - 2009 , inComponent: 0, animated: true)
        monthPickerView.selectRow(Int(currentMonth)! - 1, inComponent: 0, animated: true)
        
        loadpage(year: Int(currentYear)!, month: Int(currentMonth)!)
        
        
        
        
    }
    
    
    
    @IBAction func actionButton(_ sender: Any) {
        
        if playButtonEnable {
            
            if audioPlayer.isPlaying {
                
                audioPlayer.pause()
                //self.topBar.rightBarButtonItem?.title = "Pause"
                let pauseButton = UIBarButtonItem(barButtonSystemItem: .pause, target: self, action: #selector(actionButton(_:))) //Use a selector
                topBar.rightBarButtonItem = pauseButton
                
            }else {
                
                audioPlayer.play()
                //self.topBar.rightBarButtonItem?.title = "Play"
                let playButton = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(actionButton(_:))) //Use a selector
                topBar.rightBarButtonItem = playButton
                
                
            }
        }else{
            
            print("no play yet")
            
        }
        
        
    }
    
    
    
    let month = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"]
    let year = ["2009", "2010", "2011", "2012", "2013", "2014", "2015", "2016", "2017", "2018", "2019" ]
    
    var currentYear = "2019"
    var currentMonth = "1"
    
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
        
        // loadContent()
        table.reloadData()
    }
    
  
    
    
    
    
    func loadContent(){
        
        
        let tableArr = UserDefaults.standard.object(forKey: "tableArray")
        if let arrayObject = tableArr as? NSArray {
            
            print(arrayObject.count)
            print(arrayObject[1])
            tablev = arrayObject as! [String]
            
            generateTalkList()
            print("loadContent sucess")
            
        }else{
            
            print("error load content")
            
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
                
                MPNowPlayingInfoCenter.default().nowPlayingInfo = [MPMediaItemPropertyTitle: displayTitle]
                
                
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
        
        
        if let url = URL(string: "http://www.frpeterleung.com/homily-calendar.php?lang="+lang+"&y=" + String(year) + "&m=" + String(month)) {
            
            let request = NSMutableURLRequest(url: url)
            
            let task = URLSession.shared.dataTask(with: request as URLRequest) {
                data, response, error in
                
                if let error = error?.localizedDescription {
                    
                    print(error)
                    
                } else {
                    
                    if let unwrappedData = data {
                        
                        let dataString = NSString(data: unwrappedData, encoding: String.Encoding.utf8.rawValue)!
                        
                        let seperator = "<div class='day-number'>"
                        
                        
                        talkArray = (dataString.components(separatedBy: seperator))
                        
                        UserDefaults.standard.set(talkArray, forKey: "tableArray")
                        
                        DispatchQueue.main.async {
                            self.loadContent()
                            self.table.reloadData()
                        }
                        
                    }
                    
                    
                    
                }
                
                
            }
            
            task.resume()
        }
        
        
        
        return
        
    }
    
    func generateTalkList() {
        
        talkList.removeAll()
        talkAddress.removeAll()
        var t = 1
        
        print("tablev has \(tablev.count) records")
        
        while tablev.count > t {
        
        //print(tablev[t])
            
        let talkA = NSString(string:tablev[t])
       
        let titleA = talkA.components(separatedBy: "</div>")
        
        let titleB = talkA.components(separatedBy: "<div class='liturgicalDay'>")
        let titleB1 = titleB[1].components(separatedBy: "</div>")
        //var titleC2 = String("")
        if talkA.contains("<a href='"){
            let titleC = talkA.components(separatedBy: "<a href='")
            
            for titleName in titleC {
            
                if titleName.contains("' target='_blank'>"){
                
            let titleC1 = titleName.components(separatedBy: "' target='_blank'>")
            let titleC2 = titleC1[1].components(separatedBy: "</a>")
                    
            print("title is \(titleC2[0]) and link is \(titleC1[0])")
            talkAddress.append(titleC1[0])
            talkList.append("\(titleA[0])-\(titleB1[0].replacingOccurrences(of: "\n", with: ""))-\(titleC2[0])")
           
                }
            }
            
            
        }else {
            //na = "N/A "
        }
        
            t += 1
        }
        
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int   {
        
        return talkList.count
     
    }
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "Cell")
        
        cell.textLabel?.text = talkList[indexPath.row]
        
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
        
        downloadFile(song: "http://www.frpeterleung.com\(talkAddress[indexPath.row])")
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        
        
        if let chi:Bool = UserDefaults.standard.object(forKey: "chinese") as? Bool {
            
            chinese = chi
            
            
            if !chinese {
                
                print("not chinese")
                langButton.setTitle("Eng", for: .normal)
                chinese = false
                displayYearLabel.text = "Year"
                displayMonthLabel.text = "Month"
                lang = "e"
                topBar.title = "Father Leung Homily"
                displayTitle = "Father Leung Homily"
            }else{
                print("chinese")
            }
            
        }
        
        
        yearPickerView.selectRow(9, inComponent: 0, animated: true)
        monthPickerView.selectRow(0, inComponent: 0, animated: true)
       
        loadpage(year: Int(currentYear)!, month: Int(currentMonth)!)
        
        
        /*
        let tableArr = UserDefaults.standard.object(forKey: "tableArray")
        if let arrayObject = tableArr as? NSArray {
            
            print(arrayObject.count)
            print(arrayObject[1])
            tablev = arrayObject as! [String]
            
            table.reloadData()
        }
        */
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
