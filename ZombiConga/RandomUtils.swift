//
//  RandomUtils.swift
//  ZombiConga
//
//  Created by Jorge Rebollo J on 25/07/16.
//  Copyright © 2016 RGStudio. All rights reserved.
//

import Foundation
import CoreGraphics

extension CGFloat {
    //Devuelave un número aleatorio entre 0 y 1
    static func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / Float(UInt32.max))
    }
    
    //Devuelve un número aleatorio del rango entre un mínimo y un máximo, en este caso 0 y 1. Usando ecuación lineal matemática.
    static func random(min:CGFloat, max:CGFloat)  -> CGFloat {
        assert(min < max)
        return CGFloat.random() * (max - min) + min
    }
}