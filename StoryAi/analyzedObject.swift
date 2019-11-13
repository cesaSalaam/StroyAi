//
//  analyzedObject.swift
//  StoryAi
//
//  Created by Cesa Salaam on 4/22/19.
//  Copyright © 2019 Cesa Salaam. All rights reserved.
//

import UIKit

class analyzedObject: NSObject {
    
    func myEmotionis(anger: Int, disgust: Int, fear: Int, joy: Int, sadness: Int)-> Any{
        let largest = max(max(max(max(anger,disgust),fear),joy),sadness)
        return largest
    }
}
