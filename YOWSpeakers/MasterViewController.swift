//
//  MasterViewController.swift
//  YOWSpeakers
//
//  Created by Cesare Rocchi on 03/09/14.
//  Copyright (c) 2014 Cesare Rocchi. All rights reserved.
//

import UIKit
import WebKit

let MESSAGE_HANDLER = "didFetchSpeakers"
let ONLINE = true

class MasterViewController: UITableViewController, WKScriptMessageHandler {

  var speakers = NSMutableArray()
  var speakersWebView: WKWebView?

  override func awakeFromNib() {
    super.awakeFromNib()
  }

  override func viewDidLoad() {
    title = "Speakers"
    super.viewDidLoad()
    
    //1. Create empty configuration
    let speakersWebViewConfiguration = WKWebViewConfiguration()
    //2. Load JavaScript code
    let scriptURL = NSBundle.mainBundle().pathForResource("fetchSpeakers", ofType: "js")
    let jsScript = String.stringWithContentsOfFile(scriptURL!, encoding:NSUTF8StringEncoding, error: nil)
    //3. Wrap JavaScript code in a user script
    let fetchAuthorsScript = WKUserScript(source: jsScript, injectionTime: .AtDocumentEnd, forMainFrameOnly: true)
    //4. Add script to configuration's controller
    speakersWebViewConfiguration.userContentController.addUserScript(fetchAuthorsScript)
    //5. Subscribe to listen for a callback from the web view
    speakersWebViewConfiguration.userContentController.addScriptMessageHandler(self, name: MESSAGE_HANDLER)
    //6. Create web view with configuration
    speakersWebView = WKWebView(frame: CGRectZero, configuration: speakersWebViewConfiguration)
    var speakersURL = NSURL.URLWithString("http://speakers.dev/webarchive-index.html");
    if (ONLINE) {
      speakersURL = NSURL.URLWithString("https://a.confui.com/public/conferences/533ec7198cc0a36c75000001/locations/533ec7198cc0a36c75000002/speakers");
    }
    println("URL \(speakersURL)")
    let speakersRequest = NSURLRequest(URL:speakersURL)
    //7. Set up KVO
    speakersWebView!.addObserver(self, forKeyPath: "loading", options: .New, context: nil)
    speakersWebView!.addObserver(self, forKeyPath: "estimatedProgress", options: .New, context: nil)
    //8. Load request
    speakersWebView!.loadRequest(speakersRequest)
    
  }

  func userContentController(userContentController: WKUserContentController!, didReceiveScriptMessage message: WKScriptMessage!) {
    
    if (message.name == MESSAGE_HANDLER) {
      if let resultArray = message.body as? [Dictionary<String, String>] {
        for d in resultArray {
          let speaker = Speaker(dictionary: d)
          speakers.addObject(speaker);
        }
      }
      tableView.reloadData()
    }
    
  }
  
  override func observeValueForKeyPath(keyPath: String!, ofObject object: AnyObject!, change: [NSObject : AnyObject]!, context: UnsafeMutablePointer<Void>) {
    
    switch keyPath {
      
    case "loading":
      UIApplication.sharedApplication().networkActivityIndicatorVisible = speakersWebView!.loading
      
    case "estimatedProgress":
      println("progress \(speakersWebView!.estimatedProgress)")
      
    default:
      println("unknown key")
      
    }
    
  }
  
  // MARK: - Segues

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "showDetail" {
        if let indexPath = self.tableView.indexPathForSelectedRow() {
            let object = speakers[indexPath.row] as NSDate
        (segue.destinationViewController as DetailViewController).detailItem = object
        }
    }
  }

  // MARK: - Table View

  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return speakers.count
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
    cell.tag = indexPath.row;
    let speaker = speakers[indexPath.row] as Speaker
    cell.textLabel?.text = speaker.speakerName
    cell.detailTextLabel?.text = speaker.speakerTitle
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
      
      let url = NSURL.URLWithString(speaker.avatarURL);
      var err: NSError?
      var imageData :NSData = NSData.dataWithContentsOfURL(url,options: NSDataReadingOptions.DataReadingMappedIfSafe, error: &err)
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        
        if (cell.tag == indexPath.row) {
          cell.imageView?.image = UIImage(data:imageData)
          cell.setNeedsLayout()
        }
        
      })
      
    })
    return cell
  }
  
  override func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    
    cell.imageView?.image = nil
    cell.setNeedsLayout()
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
}

