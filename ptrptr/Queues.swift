//
//  Queues.swift
//  ptrptr
//
//  Created by Nate Parrott on 1/16/16.
//  Copyright © 2016 Nate Parrott. All rights reserved.
//

import Foundation

func backgroundThread(f: dispatch_block_t) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), f)
}

func mainThread(f: dispatch_block_t) {
    dispatch_async(dispatch_get_main_queue(), f)
}
