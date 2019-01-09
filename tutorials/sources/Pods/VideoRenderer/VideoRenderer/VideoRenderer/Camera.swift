//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import GLKit

extension SphereView {
    class Camera {
        private var viewMatrix = GLKMatrix4()
        
        let fovRadians: Float = GLKMathDegreesToRadians(60.0)
        let nearZ: Float = 1
        let farZ: Float = 1000
        
        var aspect: Float = (320.0 / 480.0)
        
        var yaw: Double = 0.0 { // swiftlint:disable:this variable_name
            didSet { self.updateViewMatrix() }
        }
        
        var pitch: Double = 0.0 {
            didSet { self.updateViewMatrix() }
        }
        
        // MARK: - Matrix getters
        var projection: GLKMatrix4 {
            let fov = aspect < 1 ? self.fovRadians / aspect : self.fovRadians
            
            return GLKMatrix4MakePerspective(
                fov, self.aspect, self.nearZ, self.farZ
            )
        }
        
        var view: GLKMatrix4 {
            get { return self.viewMatrix }
        }
        
        // MARK: - Init
        init() {
            self.updateViewMatrix()
        }
        
        // MARK: - Updaters
        
        private func updateViewMatrix() {
            let cosPitch = cos(pitch)
            let sinPitch = sin(pitch)
            let cosYaw = cos(yaw + .pi / 2)
            let sinYaw = sin(yaw + .pi / 2)
            
            let xaxis = GLKVector3(
                v: (Float(cosYaw), 0, Float(-sinYaw))
            )
            let yaxis = GLKVector3(
                v: (Float(sinYaw * sinPitch), Float(cosPitch), Float(cosYaw * sinPitch))
            )
            let zaxis = GLKVector3(
                v: (Float(sinYaw * cosPitch), Float(-sinPitch), Float(cosPitch * cosYaw))
            )
            
            self.viewMatrix = GLKMatrix4(m:
                (
                    xaxis.x, yaxis.x, zaxis.x, 0,
                    xaxis.y, yaxis.y, zaxis.y, 0,
                    xaxis.z, yaxis.z, zaxis.z, 0,
                    0, 0, 0, 1
            ))
        }
    }
}
