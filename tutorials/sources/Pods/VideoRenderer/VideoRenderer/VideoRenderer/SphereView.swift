//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import GLKit
import CoreGraphics
import QuartzCore

class SphereView: GLKView {
    let camera = Camera()
    
    private let effect = GLKBaseEffect()
    private var vertices = [TextureVertex]()
    private var indices = [UInt32]()
    private var vertexArray: GLuint = 0
    private var vertexBuffer: GLuint = 0
    private var indexBuffer: GLuint = 0
    private var texture: GLuint = 0
    
    // swiftlint:disable function_body_length
    func buildSphere() {
        /* prepare effect */ do {
            self.effect.colorMaterialEnabled = GLboolean(GL_TRUE)
            self.effect.useConstantColor = GLboolean(GL_FALSE)
        }
        
        /* load */ do {
            let radius = 600 as Float
            let rows = 90
            let columns = 90
            
            /* generate vertices */ do {
                let deltaAlpha = 2.0 * Float.pi / .init(columns)
                let deltaBeta = Float.pi / .init(rows)
                for row in 0...rows {
                    let beta = Float(row) * deltaBeta
                    let y = radius * cosf(beta)
                    let tv = Float(row) / Float(rows)
                    for col in 0...columns {
                        let alpha = Float(col) * deltaAlpha
                        let x = radius * sinf(beta) * cosf(alpha)
                        let z = radius * sinf(beta) * sinf(alpha)
                        
                        let position = GLKVector3(v: (x, y, z))
                        let tu = Float(col) / Float(columns)
                        
                        let vertex = TextureVertex(position: position.v, texture: (tu, tv))
                        self.vertices.append(vertex)
                    }
                }
            }
            
            /* generate indices*/ do {
                for row in 1...rows {
                    let topRow = row - 1
                    let topIndex = (columns + 1) * topRow
                    let bottomIndex = topIndex + (columns + 1)
                    for col in 0...columns {
                        self.indices.append(UInt32(topIndex + col))
                        self.indices.append(UInt32(bottomIndex + col))
                    }
                    
                    self.indices.append(UInt32(topIndex))
                    self.indices.append(UInt32(bottomIndex))
                }
            }
            
            // Create OpenGL's buffers
            glGenVertexArraysOES(1, &self.vertexArray)
            glBindVertexArrayOES(self.vertexArray)
            
            glGenBuffers(1, &self.vertexBuffer)
            glBindBuffer(GLenum(GL_ARRAY_BUFFER), self.vertexBuffer)
            glBufferData(GLenum(GL_ARRAY_BUFFER),
                         MemoryLayout<TextureVertex>.size * self.vertices.count,
                         self.vertices,
                         GLenum(GL_STATIC_DRAW))
            
            glGenBuffers(1, &self.indexBuffer)
            glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), self.indexBuffer)
            glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER),
                         MemoryLayout<UInt32>.size * self.indices.count,
                         self.indices,
                         GLenum(GL_STATIC_DRAW))
            
            
            // Describe vertex format to OpenGL
            let sizeOfVertex = GLsizei(MemoryLayout<TextureVertex>.size)
            
            glEnableVertexAttribArray(GLuint(GLKVertexAttrib.position.rawValue))
            glVertexAttribPointer(GLuint(GLKVertexAttrib.position.rawValue),
                                  GLint(3),
                                  GLenum(GL_FLOAT),
                                  GLboolean(GL_FALSE),
                                  sizeOfVertex,
                                  nil)
            
            glEnableVertexAttribArray(GLuint(GLKVertexAttrib.texCoord0.rawValue))
            glVertexAttribPointer(GLuint(GLKVertexAttrib.texCoord0.rawValue),
                                  GLint(2),
                                  GLenum(GL_FLOAT),
                                  GLboolean(GL_FALSE),
                                  sizeOfVertex,
                                  UnsafeRawPointer(bitPattern: MemoryLayout<GLfloat>.size * 3))
            
            glBindVertexArrayOES(0)
        }
    }
    
    deinit {
        self.vertices.removeAll()
        self.indices.removeAll()
        
        glDeleteBuffers(1, &self.vertexBuffer)
        glDeleteBuffers(1, &self.indexBuffer)
        glDeleteVertexArraysOES(1, &self.vertexArray)
        glDeleteTextures(1, &self.texture)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.camera.aspect = fabsf(Float(self.bounds.size.width / self.bounds.size.height))
    }
    
    override func display() {
        super.display()
        glClearColor(0, 0, 0, 1)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        
        guard self.texture != 0 else { return }
        
        glBindVertexArrayOES(self.vertexArray)
        
        self.effect.transform.projectionMatrix = camera.projection
        self.effect.transform.modelviewMatrix = camera.view
        self.effect.texture2d0.enabled = GLboolean(GL_TRUE)
        self.effect.texture2d0.name = self.texture
        self.effect.prepareToDraw()
        
        let bufferOffset = UnsafePointer<UInt>(bitPattern: 0)
        glDrawElements(GLenum(GL_TRIANGLE_STRIP),
                       GLsizei(self.indices.count - 2),
                       GLenum(GL_UNSIGNED_INT), bufferOffset)
        
        glBindVertexArrayOES(0)
    }
    
    func updateTexture(size: CGSize, imageData: UnsafeMutableRawPointer) {
        if self.texture == 0 {
            glGenTextures(1, &self.texture)
            glBindTexture(GLenum(GL_TEXTURE_2D), self.texture)
            
            glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GLint(GL_REPEAT))
            glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GLint(GL_REPEAT))
            glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GLint(GL_LINEAR))
            glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GLint(GL_LINEAR))
        }
        
        glBindTexture(GLenum(GL_TEXTURE_2D), self.texture)
        glTexImage2D(GLenum(GL_TEXTURE_2D), 0, GLint(GL_RGBA),
                     GLsizei(size.width), GLsizei(size.height), 0,
                     GLenum(GL_BGRA), GLenum(GL_UNSIGNED_BYTE), imageData)
        
    }
}

private struct TextureVertex {
    let position: (GLfloat, GLfloat, GLfloat)
    let texture: (GLfloat, GLfloat)
}
