//
//  FirebaseUtils.swift
//  ptrptr
//
//  Created by Nate Parrott on 1/18/16.
//  Copyright © 2016 Nate Parrott. All rights reserved.
//

import UIKit
import Firebase

extension Firebase {
    var lastPathComponent: String {
        return description().componentsSeparatedByString("/").last!
    }
}
