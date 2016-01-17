//
//  DrawingEditModeBar.swift
//  ptrptr
//
//  Created by Nate Parrott on 1/17/16.
//  Copyright © 2016 Nate Parrott. All rights reserved.
//

import UIKit

class DrawingEditModeBar: EditModeBar {
    @IBAction func confirm() {
        
        canvasVC!.popEditMode()
    }
}
