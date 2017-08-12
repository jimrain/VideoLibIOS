//
//  ViewController.swift
//  VideoLib
//
//  Created by James Rainville on 1/13/17.
//  Copyright © 2017 ShastaRain. All rights reserved.
//

import UIKit

let kViewControllerPlaybackServicePolicyKey = "BCpkADawqM3dCmAPU7-jl0hHWW8097dehsjhdHYeCZVO3HbClNSwbtBpZkhuDuab141BnGkFL_xvPCif9v6Sz5A27pFUo8-qFuq42J6vzrXnLkmeLzGkQ1HzNdow2rI0qmhyPaEEhSGTPpW9"
let kViewControllerAccountID = "4517911906001"
let kViewControllerVideoID = "5269117590001"
let kViewControllerPlaylistID = "5280100152001"

class VidTableViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    let playbackService = BCOVPlaybackService(accountId: kViewControllerAccountID, policyKey: kViewControllerPlaybackServicePolicyKey)!
    
    var thePlaylist:BCOVPlaylist?
    var downloadTask: URLSessionDownloadTask?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        playbackService.findPlaylist(withPlaylistID: kViewControllerPlaylistID, parameters: nil) {
            (playlist: BCOVPlaylist?, dict: [AnyHashable:Any]?, error: Error?) in
            if let p = playlist {
                print(p.count())
                self.thePlaylist = p
                self.tableView.reloadData()
            } else {
                print("Could not get playlist.")
            }
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self;
        tableView.dataSource = self;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     if segue.identifier == "segueShowNavigation"{
     var DestViewController = segue.destinationViewController as! UINavigationController
     let targetController = DestViewController.topViewController as! ReceiveViewController
     targetController.data = "hello from ReceiveVC !"
     }}
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goto_video_landing" {
            let DestViewController = segue.destination as! UINavigationController
            let videoLandingViewController = DestViewController.topViewController as! VideoLandingViewController
            let indexPath = sender as! IndexPath
            let vid = self.thePlaylist?.videos[(indexPath as NSIndexPath).row] as? BCOVVideo

            videoLandingViewController.videoID = vid?.properties["id"]! as! String

        }
    }

    
    // To satisfy ATS we need to use the https source for the thumbnail. This function takes the list of
    // thumbnail sources and returns a string representation of the https URL.
    func getHttpsUrl(urlList: Array<Any>) -> String {
        var httpsUrl:String = ""
        
        for url in urlList {
            let urlItem = url as! Dictionary<String, String>
            
            let theUrl = urlItem["src"]!
            let index = theUrl.index(theUrl.startIndex, offsetBy: 5)
            if (theUrl.substring(to: index) == "https") {
                httpsUrl = theUrl
                break
            }
            
        }
        
        return (httpsUrl)
    }


}

extension VidTableViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let p = self.thePlaylist {
            return Int(p.count())
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell( withIdentifier: "Video_cell", for: indexPath) as! VideoTableViewCell
        if let p = self.thePlaylist {
            let vid = p.videos[(indexPath as NSIndexPath).row] as! BCOVVideo
            // print(vid.properties["thumbnail"]!)
            cell.title.text = vid.properties["name"] as? String
            cell.vDescription.text = vid.properties["description"] as? String
            
            cell.thumbNail.image = UIImage(named: "Placeholder")
            let urlStr = getHttpsUrl(urlList: vid.properties["thumbnail_sources"] as! Array<Any>)
            print (urlStr)
            
            if let url = URL(string: urlStr) {
                downloadTask = cell.thumbNail.loadImage(url: url)
            }
        }
        
        return cell
    }
  

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // print("Selected")
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "goto_video_landing", sender: indexPath)
    }
    
    /*
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return indexPath
    }
    
    */
    
}

class VideoTableViewCell: UITableViewCell {
    
    @IBOutlet weak var thumbNail: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var vDescription: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        // let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "didTapImage:")
        // eventImageView.addGestureRecognizer(tapGestureRecognizer)
        thumbNail.isUserInteractionEnabled = true
    }
}

extension UIImageView {
    func loadImage(url: URL) -> URLSessionDownloadTask {
        let session = URLSession.shared
        let downloadTask = session.downloadTask(with: url,
                                                completionHandler: { [weak self] url, response, error in
                                                    if error == nil,
                                                        let url = url,
                                                        let data = try? Data(contentsOf: url),
                                                        let image = UIImage(data: data) {
                                                        DispatchQueue.main.async {
                                                            if let strongSelf = self {
                                                                strongSelf.image = image
                                                            }
                                                        }
                                                    }
        })
        downloadTask.resume()
        return downloadTask
    }
}



