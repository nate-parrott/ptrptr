//
//  CGMath.swift
//  ptrptr
//
//  Created by Nate Parrott on 1/15/16.
//  Copyright © 2016 Nate Parrott. All rights reserved.
//

import UIKit

func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPointMake(lhs.x + rhs.x, lhs.y + rhs.y)
}

func *(lhs: CGPoint, rhs: CGFloat) -> CGPoint {
    return CGPointMake(lhs.x * rhs, lhs.y * rhs)
}

func *(lhs: CGFloat, rhs: CGPoint) -> CGPoint {
    return CGPointMake(rhs.x * lhs, rhs.y * lhs)
}

func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return lhs + rhs * -1
}

func /(lhs: CGPoint, rhs: CGFloat) -> CGPoint {
    return CGPointMake(lhs.x / rhs, lhs.y / rhs)
}
