//
//  Speaker.swift
//  YOWSpeakers
//
//  Created by Cesare Rocchi on 03/09/14.
//  Copyright (c) 2014 Cesare Rocchi. All rights reserved.
//

import UIKit

class Speaker: NSObject {
  var speakerName: String = ""
  var speakerTitle: String = ""
  var avatarURL: String = ""
  
  init(dictionary: NSDictionary) {
    self.speakerName = dictionary["speakerName"] as String
    self.speakerTitle = dictionary["speakerTitle"] as String
    let s = dictionary["avatarURL"] as String
    self.avatarURL = "http://speakers.dev/" + s
    if (ONLINE) {
      self.avatarURL = s
    }
    super.init()
  }
}
