//
//  MathUtils.swift
//  ZombiConga
//
//  Created by Jorge Rebollo J on 25/07/16.
//  Copyright © 2016 RGStudio. All rights reserved.
//

import Foundation
import CoreGraphics

//Función que dados dos puntos devuelve uno nuevo como suma de los dos anteriores
func + (firstPoint:CGPoint, secondPoint:CGPoint) -> CGPoint {
    return CGPointMake(firstPoint.x + secondPoint.x, firstPoint.y + secondPoint.y)
}

//Función que dados dos puntos, le suma al primero el segundo, y devuelve como parámetro
func += (inout firstPoint:CGPoint, secondPoint:CGPoint) {
    firstPoint = firstPoint + secondPoint
}

//Función que dados dos puntos devuelve uno nuevo como diferencia de los dos anteriores
func - (firstPoint:CGPoint, secondPoint:CGPoint) -> CGPoint {
    return CGPointMake(firstPoint.x - secondPoint.x, firstPoint.y - secondPoint.y)
}

//Función que dados dos puntos, le resta al primero el segundo, y devuelve como parámetro
func -= (inout firstPoint:CGPoint, secondPoint:CGPoint) {
    firstPoint = firstPoint - secondPoint
}

//Función que dados dos puntos devuelve uno nuevo como producto de los dos anteriores
func * (firstPoint:CGPoint, secondPoint:CGPoint) -> CGPoint {
    return CGPointMake(firstPoint.x * secondPoint.x, firstPoint.y * secondPoint.y)
}

//Función que dados dos puntos, le multiplica al primero el segundo, y devuelve como parámetro
func *= (inout firstPoint:CGPoint, secondPoint:CGPoint) {
    firstPoint = firstPoint * secondPoint
}

//Función que dados un punto y un escalar multiplica cada coordenada del punto por el escalar
func * (point:CGPoint, scalar:CGFloat) -> CGPoint {
    return CGPointMake(point.x * scalar, point.y * scalar)
}

//Función que dados un punto y un escalar, los multiplica, y devuelve como parámetro
func *= (inout point:CGPoint, scalar:CGFloat) {
    point = point * scalar
}

//Función que dados dos puntos devuelve uno nuevo como cociente de los dos anteriores
func / (firstPoint:CGPoint, secondPoint:CGPoint) -> CGPoint {
    return CGPointMake(firstPoint.x / secondPoint.x, firstPoint.y / secondPoint.y)
}

//Función que dados dos puntos, le divide al primero el segundo, y devuelve como parámetro
func /= (inout firstPoint:CGPoint, secondPoint:CGPoint) {
    firstPoint = firstPoint / secondPoint
}

//Función que dados un punto y un escalar divide cada coordenada del punto por el escalar
func / (point:CGPoint, scalar:CGFloat) -> CGPoint {
    return CGPointMake(point.x / scalar, point.y / scalar)
}

//Función que dados un punto y un escalar, los divide, y devuelve como parámetro
func /= (inout point:CGPoint, scalar:CGFloat) {
    point = point / scalar
}

//Sólo se ejecutará si la app corre en 32 bits
#if !(arch(x86_64) || arch(arm64))
    
    func atan2(y:CGFloat, x:CGFloat) -> CGFloat {
        return CGFloat(atan2f(Float(y), Float(x)))
    }
    
    func sqrt(a:CGFloat) -> CGFloat {
        return CGFloat(sqrtf(Float(a)))
    }

#endif

extension CGPoint {
    //Calcula la longitud del punto (hipotenusa) usando el teorema de Pitágoras
    func lenght() -> CGFloat {
        return sqrt(x*x+y*y)
    }
    
    //Normaliza el vector para que tenga longiitud 1
    func normalize() -> CGPoint {
        return self / lenght()
    }
    
    //Calcula un ángulo que forma el punto con la horizontal (hipotenusa)
    var angle:CGFloat {
        return atan2(y,x)
    }
}

let π = CGFloat(M_PI)

//Gira el elemento de modo que tenga que rotar siempre lo menos posible
func shortesAngleBetween(angle1:CGFloat, angle2:CGFloat) -> CGFloat {
    let twoπ = 2.0 * π
    var angle = (angle2 - angle1) % twoπ //Los resultados siempre estarán entre 0 y 2π
    if angle >= π {
        angle -= twoπ
    }
    if angle <= -π {
        angle += twoπ
    }
    
    //Después de este fragmento, seguro que el ángulo se encuentra entre -π y π, por tanto sabrá hacias dónde  rotar con menor diferencia respecto a su posición original
    return angle
}

//Devuelve la distancia en píxeles entre el punto1 y el punto2
func distanceBetweenPoints(point1:CGPoint, point2:CGPoint) -> CGFloat {
    let distanceVector = point2 - point1
    let distance = distanceVector.lenght()
    return distance
}

extension CGFloat {
    func sign() -> CGFloat {
        return (self >= 0) ? 1.0 : -1.0
    }
}

//Mantiene el giro entre el ángulo máximo y mínimo del elemento dado
func clamp(min: CGFloat, max: CGFloat, value: CGFloat) -> CGFloat {
    if( value > max ) {
        return max
    } else if( value < min ) {
        return min
    } else {
        return value
    }
}