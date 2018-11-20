//
//  ViewController.swift
//  Cubo Flotando
//
//  Created by Daniel  on 14/09/2018.
//  Copyright © 2018 UPM. All rights reserved.
//

import UIKit

class ViewController: UIViewController,ParametricFunctionViewDataSource {
    
    let cuboModel = CuboModel()

    @IBOutlet weak var posZFuncView: ParametricFunctionView!
    @IBOutlet weak var velFuncView: ParametricFunctionView!
    @IBOutlet weak var acelFuncView: ParametricFunctionView!
    
    @IBOutlet weak var vel_posFuncView: ParametricFunctionView!
    
    @IBOutlet weak var ladoSlider: UISlider!
    @IBOutlet weak var tiempoSlider: UISlider!
    
    @IBOutlet weak var ladoLabel: UILabel!
    @IBOutlet weak var tiempoLabel: UILabel!
    
    @IBOutlet weak var posZLabel: UILabel!
    @IBOutlet weak var velLabel: UILabel!
    @IBOutlet weak var acelLabel: UILabel!
    
    
    // Longitud de la arista del cubo
    var lado: Double = 0.0 {
        didSet{                                 // Si se cambia el valor de lado
            posZFuncView.setNeedsDisplay()      // se vuelven a dibujar las funciones
            velFuncView.setNeedsDisplay()
            acelFuncView.setNeedsDisplay()
            vel_posFuncView.setNeedsDisplay()
        }
    }
    
    // Instante de tiempo que se resaltará como punto de interés en las 3 primeras gráficas
    var tiempoPOI: Double = 0.0 {
        didSet{
            posZFuncView.setNeedsDisplay()
            velFuncView.setNeedsDisplay()
            acelFuncView.setNeedsDisplay()
        }
    }
    
    var trajectoryColor: UIColor = .red {
        didSet{
            posZFuncView.setNeedsDisplay()
            velFuncView.setNeedsDisplay()
            acelFuncView.setNeedsDisplay()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        posZFuncView.dataSource = self
        velFuncView.dataSource = self
        acelFuncView.dataSource = self
        vel_posFuncView.dataSource = self
        
        ladoSlider.sendActions(for: .valueChanged)      // Provoca que se ejecuten las acciones con el
        tiempoSlider.sendActions(for: .valueChanged)    // valor inicial (como si se hubiera cambiado)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Acciones
    
    //Acciones a realizar cuando se cambia el valor del slider de lado
    @IBAction func updateLado(_ sender: UISlider) {
        
        lado = Double(sender.value)
        cuboModel.lado = lado
        
        // Actualizamos las labels que muestran los valores instantáneos en t = tiempoPOI
        let z = cuboModel.getPosZ(time: tiempoPOI)
        let v = cuboModel.getVel(time: tiempoPOI)
        let a = cuboModel.getAcel(time: tiempoPOI)
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        
        posZLabel.text = ""
        velLabel.text = ""
        acelLabel.text = ""
        
        if let fz = formatter.string(from: z as NSNumber) {
            posZLabel.text = "\(fz) m"
        }
        
        if let fv = formatter.string(from: v as NSNumber) {
            velLabel.text = "\(fv) m/seg"
        }
        
        if let fa = formatter.string(from: a as NSNumber) {
            acelLabel.text = "\(fa) m/seg^2"
        }
        
        // Actualización de la label que indica el valor actual del slider
        if let fl = formatter.string(from: lado as NSNumber) {
            ladoLabel.text = "\(fl) m"
        }
        
    }
    
    //Acciones a realizar cuando se cambia el valor del slider de tiempo
    @IBAction func updateTiempoPOI(_ sender: UISlider) {
        
        // Redondeamos el valor del slider. El valor del step es el mismo que el del incremento de tiempo
        // en drawTrajectory(). Si estos valores no coinciden, no coincide la representación gráfica y
        // el POI se sale de la trayectoria
        let step = 0.05
        let roundedValue = round(Double(sender.value) / step) * step
        tiempoPOI = roundedValue
        
        // Actualización de las labels de las gráficas
        let z = cuboModel.getPosZ(time: tiempoPOI)
        let v = cuboModel.getVel(time: tiempoPOI)
        let a = cuboModel.getAcel(time: tiempoPOI)
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        
        if let fz = formatter.string(from: z as NSNumber) {
            posZLabel.text = "\(fz) m"
        }
        
        if let fv = formatter.string(from: v as NSNumber) {
            velLabel.text = "\(fv) m/seg"
        }
        
        if let fa = formatter.string(from: a as NSNumber) {
            acelLabel.text = "\(fa) m/seg^2"
        }
        
        // Actualización de la label que muestra el valor del slider
        tiempoLabel.text = "\(tiempoPOI) s"
        
    }
    
    // Alterna entre rojo y azul el color la trayectoria si se hace tap dentro del stack view con las 3 funciones superiores
    @IBAction func handleTap(_ sender: UITapGestureRecognizer) {
        print("TAP DETECTADO")
        if trajectoryColor == .red {
            print("color anterior ROJO")
        }
        if trajectoryColor == .blue {
            print("color anterior AZUL")
        }
        
        if trajectoryColor == UIColor.red {
           trajectoryColor = .blue
        } else {
            trajectoryColor = .red
        }
        
        if trajectoryColor == .red {
            print("color nuevo ROJO")
        }
        if trajectoryColor == .blue {
            print("color nuevo AZUL")
        }
        
        posZFuncView.trajectoryColor = trajectoryColor
        velFuncView.trajectoryColor = trajectoryColor
        acelFuncView.trajectoryColor = trajectoryColor

    }
    
    
    // Devuelve los sliders a sus valores iniciales
    @IBAction func handleSwipe(_ sender: UISwipeGestureRecognizer) {
        print("SWIPE DETECTADO")
        
        ladoSlider.value = 15
        ladoSlider.sendActions(for: .valueChanged)
        
        tiempoSlider.value = 10
        tiempoSlider.sendActions(for: .valueChanged)
        
        posZFuncView.setNeedsDisplay()      
        velFuncView.setNeedsDisplay()
        acelFuncView.setNeedsDisplay()
        vel_posFuncView.setNeedsDisplay()
        
        
    }
    
    // FunctionViewDataSource
    
    // Valor en el que se empieza a dibujar la gráfica
    func startIndexFor(_ functionView: ParametricFunctionView) -> Double {
        return 0
    }
    
    // Valor en el que se termina de dibujar la gráfica
    func endIndexFor(_ functionView: ParametricFunctionView) -> Double {
        return 25
    }
    
    // Puntos de las funciones que se van a representar
    func functionView(_ functionView: ParametricFunctionView, pointAt index: Double) -> FunctionPoint {
        switch functionView {
        case posZFuncView:
            let t = index
            let z = cuboModel.getPosZ(time: t)
            return FunctionPoint(x: t, y: z)
        case velFuncView:
            let t = index
            let v = cuboModel.getVel(time: t)
            return FunctionPoint(x: t, y: v)
        case acelFuncView:
           let t = index
           let a = cuboModel.getAcel(time: t)
           return FunctionPoint(x: t, y: a)
        case vel_posFuncView:
            let t = index
            let v = cuboModel.getVel(time: t)
            let z = cuboModel.getPosZ(time: t)
            return FunctionPoint(x: z, y: v)
        default:
            return FunctionPoint(x: 0, y: 0)
        }
    }
    
    // Puntos de interés
    func pointsOfInterestFor(_ functionView: ParametricFunctionView) -> [FunctionPoint] {
        switch functionView {
        case posZFuncView:
            let z = cuboModel.getPosZ(time: tiempoPOI)
            let t = tiempoPOI
            return [ FunctionPoint(x: t, y: z) ]
        case velFuncView:
            let v = cuboModel.getVel(time: tiempoPOI)
            let t = tiempoPOI
            return [ FunctionPoint(x: t, y: v) ]
        case acelFuncView:
            let a = cuboModel.getAcel(time: tiempoPOI)
            let t = tiempoPOI
            return [ FunctionPoint(x: t, y: a) ]
        default:
            return []
        }
    }


}

