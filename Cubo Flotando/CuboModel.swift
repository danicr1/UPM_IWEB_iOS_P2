//
//  CuboModel.swift
//  Cubo Flotando
//
//  Created by Daniel  on 24/09/2018.
//  Copyright © 2018 UPM. All rights reserved.
//

import Foundation

// Modelo de datos para representar el movimiento
// vertical de un cubo flotando en el agua.
class CuboModel {
    
    // Longitud de la arista del cubo
    var lado: Double = 1.0 {
        didSet{
            update()
        }
    }
    
    // Gravedad
    private let g: Double = 9.8
    
    // Velocidad angular
    private var w = 0.0
    
    // Función que actualiza los valores cada vez que se modifica el lado
    private func update() {
        w = sqrt((2*g)/lado)
    }
    
    // Devuelve la posición del cubo en el eje Z
    func getPosZ(time: Double) -> Double {
        return 0.5 * lado * cos(w * time)
    }
    
    // Devuelve la velocidad del cubo
    func getVel(time: Double) -> Double {
        return -0.5 * lado * w * sin(w * time)
    }
    
    // Devuelve la aceleración del cubo
    func getAcel(time: Double) -> Double {
        return -g * cos(w * time)
    }
    
}
