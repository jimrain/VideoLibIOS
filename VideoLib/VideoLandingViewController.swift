//
//  VideoLandingViewController.swift
//  VideoLib
//
//  Created by James Rainville on 1/14/17.
//  Copyright © 2017 ShastaRain. All rights reserved.
//

import UIKit

class VideoLandingViewController: UIViewController, BCOVPlaybackControllerDelegate, BCOVPUIPlayerViewDelegate  {
    let playbackService = BCOVPlaybackService(accountId: kViewControllerAccountID, policyKey: kViewControllerPlaybackServicePolicyKey)!
    let playbackController :BCOVPlaybackController
    var videoID:String = ""
    
    @IBOutlet var videoContainer: UIView!
    
    required init?(coder aDecoder: NSCoder) {
        let manager = BCOVPlayerSDKManager.shared()!
        
        // This changes the source selection to HTTPS to make Apple's ATS happy.
        let options = BCOVBasicSessionProviderOptions()
        options.sourceSelectionPolicy =  BCOVBasicSourceSelectionPolicy.sourceSelectionHLS(withScheme: kBCOVSourceURLSchemeHTTPS)
        let provider = manager.createBasicSessionProvider(with: options)
        
        
        playbackController = manager.createPlaybackController(with: provider, viewStrategy: nil)
        
        super.init(coder: aDecoder)
        
        playbackController.analytics.account = kViewControllerAccountID
        
        playbackController.delegate = self
        playbackController.isAutoAdvance = true
        playbackController.isAutoPlay = true
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Create and set options
        let options = BCOVPUIPlayerViewOptions()
        options.presentingViewController = self
        
        // Create and configure Control View
        let controlsView = BCOVPUIBasicControlView.withVODLayout()
        let playerView = BCOVPUIPlayerView.init(playbackController: playbackController, options: options, controlsView: controlsView)!
        
        playerView.delegate = self
        playerView.frame = videoContainer.bounds
        playerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        videoContainer.addSubview(playerView)
        
        requestContentFromPlaybackService()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func requestContentFromPlaybackService() {
        playbackService.findVideo(withVideoID: videoID, parameters: nil) {
            (video: BCOVVideo?, dict: [AnyHashable:Any]?, error: Error?) in
            if let v = video {
                self.playbackController.setVideos([v] as NSFastEnumeration!)
            } else {
                print("ViewController Debug - Error retrieving video: %@", error!)
            }
        }
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
