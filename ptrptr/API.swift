//
//  API.swift
//  ptrptr
//
//  Created by Nate Parrott on 1/14/16.
//  Copyright © 2016 Nate Parrott. All rights reserved.
//

import Foundation
import Firebase

class API: NSObject {
    static let Shared = API()
    
    let firebaseRoot = Firebase(url: "https://ptrptr.firebaseio.com")
}