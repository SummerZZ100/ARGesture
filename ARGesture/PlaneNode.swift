//
//  PlaneNode.swift
//  ARGesture
//
//  Created by Zhang xiaosong on 2018/4/26.
//  Copyright © 2018年 Zhang xiaosong. All rights reserved.
//

import Foundation
import ARKit


/// 平面
class PlaneNode: SCNNode {
    
    var planeGeometry: SCNPlane!
    var anchor: ARPlaneAnchor!
    
    
    init(withAnchor anchor:ARPlaneAnchor) {
        super.init()
        self.anchor = anchor
        
        //创建平面
        planeGeometry = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
        
        //创建材质并用于平面
        let material = SCNMaterial()
        let image = UIImage(named: "plane.png")
        material.diffuse.contents = image
        planeGeometry.materials = [material]
        
        //创建节点并作为当前节点的子节点
        let planeNode = SCNNode(geometry: planeGeometry)
        planeNode.position = SCNVector3Make(anchor.center.x, -0.05, anchor.center.z)
        // SceneKit 里的平面默认是垂直的，所以需要旋转90度来匹配 ARKit 中的平面
        planeNode.transform = SCNMatrix4MakeRotation((-.pi/2.0), 1.0, 0.0, 0.0)
        
        addChildNode(planeNode)
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updatePlane(anchor: ARPlaneAnchor) {
        // 随着用户移动，平面 plane 的 范围 extend 和 位置 location 可能会更新。
        // 需要更新 3D 几何体来匹配 plane 的新参数。
        planeGeometry.width = CGFloat(anchor.extent.x)
        planeGeometry.height = CGFloat(anchor.extent.z)
        
        // plane 刚创建时中心点 center 为 0,0,0，node transform 包含了变换参数。
        // plane 更新后变换没变 但 center 更新了，所以需要更新 3D 几何体的位置
        
        position  = SCNVector3Make(anchor.center.x, -0.05, anchor.center.z)
        
    }
    
    func removePlaneNode(WithAnchor anchor:ARPlaneAnchor) {
        removeFromParentNode()
    }
    
    
}

