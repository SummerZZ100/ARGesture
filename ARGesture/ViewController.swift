//
//  ViewController.swift
//  ARGesture
//
//  Created by Zhang xiaosong on 2018/4/26.
//  Copyright © 2018年 Zhang xiaosong. All rights reserved.
//

import UIKit
import ARKit
import SceneKit

/// AR手势
class ViewController: UIViewController {
    
    var scnView = ARSCNView()//AR视图
    var sessionConfig: ARConfiguration? //会话配置
    var maskView = UIView() // 遮罩视图
    var tipLabel = UILabel()//提示标签
    var currentSelectNode: SCNNode?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self .layoutMySubItems()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupConfig()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        scnView.session.pause()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /// 初始化子视图
    func layoutMySubItems()
    {
        scnView.frame = self.view.frame
        self.view.addSubview(scnView)
        scnView.delegate = self
//        scnView.showsStatistics = true
        scnView.autoenablesDefaultLighting = true
        scnView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        maskView.frame = self.view.frame
        maskView.backgroundColor = UIColor.white
        maskView.alpha = 0.6
        self.view.addSubview(maskView)
        
        self.view.addSubview(tipLabel)
        tipLabel.frame = CGRect(x: 0, y: 40, width: self.view.frame.size.width, height: 50)
        tipLabel.textColor = UIColor.black
        tipLabel.numberOfLines = 0
        
        addGestureOfScnView()
        
    }
    
    /// 添加配置
    func setupConfig() {
        if ARWorldTrackingConfiguration.isSupported {//判断是否支持6个自由度
            let worldTracking = ARWorldTrackingConfiguration()//6DOF【3个旋转轴 3个平移轴】
            worldTracking.planeDetection = .horizontal
            worldTracking.isLightEstimationEnabled = true
            sessionConfig = worldTracking
        }
        else {
            let orientationTracking = AROrientationTrackingConfiguration()//3DOF 【3个旋转轴】
            sessionConfig = orientationTracking
            tipLabel.text = "当前设备不支持6DOF跟踪"
        }
        scnView.session.run(sessionConfig!)
    }
    
    /// 添加手势
    func addGestureOfScnView() {
//        添加单击手势
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureEventFrom(tapGestureRecognizer:)))
        tapGesture.numberOfTapsRequired = 1
        self.scnView.addGestureRecognizer(tapGesture)
        
//        添加长按手势
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(longGestureEventFrom(longGestureRecognizer:)))
        longGesture.minimumPressDuration = 1
        self.scnView.addGestureRecognizer(longGesture)
        
//        添加华滑动手势
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureEventFrom(panGestureRecognizer:)))
        panGesture.maximumNumberOfTouches = 1
        self.scnView.addGestureRecognizer(panGesture)
        
//        添加捏合手势
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchGestureEventFrom(pinchGestureRecognizer:)))
        self.scnView.addGestureRecognizer(pinchGesture)
        
//        旋转手势
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(rotationGestureEventFrom(rotationGestureRecognizer:)))
        self.scnView.addGestureRecognizer(rotationGesture)
        
        
    }
    
    
    /// 单击手势触发动作
    ///
    /// - Parameter tapGestureRecongizer: 手势触发信息
    @objc func tapGestureEventFrom(tapGestureRecognizer : UITapGestureRecognizer) {
        let point = tapGestureRecognizer.location(in: self.scnView)
        
        if let result = self.scnView.hitTest(point, types: .existingPlaneUsingExtent).first {
            let vector = SCNVector3.positionTransform(result.worldTransform)
            
            //      添加3D立方体
            let boxGeometry = SCNBox(width: 0.2, height: 0.2, length: 0.2, chamferRadius: 0.0)
            let material = SCNMaterial()
            let img = UIImage(named: "gc.png")
            material.diffuse.contents = img
            material.lightingModel = .physicallyBased
            boxGeometry.materials = [material]
            
            let boxNode = SCNNode(geometry: boxGeometry)
            boxNode.position = vector
            self.scnView.scene.rootNode.addChildNode(boxNode)
            
        }
        
    }
    
    /// 长按手势触发动作
    ///
    /// - Parameter longGestureRecognizer: 手势触发信息
    @objc func longGestureEventFrom(longGestureRecognizer : UILongPressGestureRecognizer) {
        let point = longGestureRecognizer.location(in: self.scnView)
        if let result = self.scnView.hitTest(point, options: nil).first {
            if !(result.node.parent is PlaneNode) {
                if result.node.parent != nil {
                    result.node.removeFromParentNode()
                }
            }
        }
        
    }
    
    /// 滑动手势触发动作
    ///
    /// - Parameter panGestureRecognizer: 滑动手势触发信息
    @objc func panGestureEventFrom(panGestureRecognizer: UIPanGestureRecognizer) {
        if panGestureRecognizer.state == .began {//开始移动
            let point = panGestureRecognizer.location(in: self.scnView)
            if let result = self.scnView.hitTest(point, options: nil).first {
                if !(result.node.parent is PlaneNode)  {
                    self.currentSelectNode = result.node
                }
                
            }
            
        }
        if panGestureRecognizer.state == .changed {//正在移动
            if self.currentSelectNode != nil {
                let point = panGestureRecognizer.location(in: self.scnView)
                if let result = self.scnView.hitTest(point, types: .existingPlaneUsingExtent).first {
                    let vector = SCNVector3.positionTransform(result.worldTransform)
                    self.currentSelectNode?.position = vector
                }
            }
        }
        if panGestureRecognizer.state == .ended {//结束移动
            self.currentSelectNode = nil
        }
    }
    
    /// 捏合手势触发动作
    ///
    /// - Parameter pinchGestureRecognizer: 捏合手势信息
    @objc func pinchGestureEventFrom(pinchGestureRecognizer: UIPinchGestureRecognizer) {
        if pinchGestureRecognizer.state == .began {
            let point = pinchGestureRecognizer.location(in: self.scnView)
            if let result = self.scnView.hitTest(point, options: nil).first {

                if !(result.node.parent is PlaneNode) {
                    self.currentSelectNode = result.node
                }
            }
        }
        if pinchGestureRecognizer.state == .changed {
            if self.currentSelectNode != nil {
                // 根据每次捏合的比例来更新节点最新的比例
                let pinchScaleX = Float(pinchGestureRecognizer.scale) * (self.currentSelectNode?.scale.x)!
                let pinchScaleY = Float(pinchGestureRecognizer.scale) * (self.currentSelectNode?.scale.y)!
                let pinchScaleZ = Float(pinchGestureRecognizer.scale) * Float((self.currentSelectNode?.scale.y)!)
                let vector = SCNVector3Make(pinchScaleX, pinchScaleY, pinchScaleZ)
                self.currentSelectNode?.scale = vector
            }
            
            pinchGestureRecognizer.scale = 1.0
        }
        if pinchGestureRecognizer.state == .ended {
            self.currentSelectNode = nil
        }
    }
    
    @objc func rotationGestureEventFrom(rotationGestureRecognizer: UIRotationGestureRecognizer) {
        if rotationGestureRecognizer.state == .began {
            let point = rotationGestureRecognizer.location(in: self.scnView)
            if  let result = self.scnView.hitTest(point, options: nil).first {
                if !(result.node.parent is PlaneNode) {
                    self.currentSelectNode = result.node
                }
            }
        }
        if rotationGestureRecognizer.state == .changed {
            self.currentSelectNode?.eulerAngles.y -= Float(rotationGestureRecognizer.rotation)
            rotationGestureRecognizer.rotation = 0
        }
        if rotationGestureRecognizer.state == .ended {
            self.currentSelectNode = nil
        }
    }


}


// MARK: - 代理方法
extension ViewController: ARSCNViewDelegate {
    //相机状态变化
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        //判断状态
        switch camera.trackingState{
        case .notAvailable:
            tipLabel.text = "跟踪不可用"
            UIView.animate(withDuration: 0.5) {
                self.maskView.alpha = 0.7
            }
        case .limited(ARCamera.TrackingState.Reason.initializing):
            let title = "有限的跟踪，原因是："
            let desc = "正在初始化，请稍后"
            tipLabel.text = title + desc
            UIView.animate(withDuration: 0.5) {
                self.maskView.alpha = 0.6
            }
        case .limited(ARCamera.TrackingState.Reason.relocalizing):
            tipLabel.text = "有限的跟踪，原因是：重新初始化"
            UIView.animate(withDuration: 0.5) {
                self.maskView.alpha = 0.6
            }
        case .limited(ARCamera.TrackingState.Reason.excessiveMotion):
            tipLabel.text = "有限的跟踪，原因是：设备移动过快请注意"
            UIView.animate(withDuration: 0.5) {
                self.maskView.alpha = 0.6
            }
        case .limited(ARCamera.TrackingState.Reason.insufficientFeatures):
            tipLabel.text = "有限的跟踪，原因是：提取不到足够的特征点，请移动设备"
            UIView.animate(withDuration: 0.5) {
                self.maskView.alpha = 0.6
            }
        case .normal:
            tipLabel.text = "跟踪正常"
            UIView.animate(withDuration: 0.5) {
                self.maskView.alpha = 0.0
            }
        }
    }
    
    //会话被中断
    func sessionWasInterrupted()
    {
        
        tipLabel.text = "会话中断"
    }
    
    //会话中断结束
    func sessionInterruptionEnded(_ session: ARSession) {
        tipLabel.text = "会话中断结束，已重置会话"
        scnView.session.run(self.sessionConfig!, options: .resetTracking)
    }
    
    
    //会话失败
    func session(_ session: ARSession, didFailWithError error: Error) {
        print(error.localizedDescription)
        tipLabel.text  = error.localizedDescription
    }
    
    /**
     实现此方法来为给定 anchor 提供自定义 node。
     
     @discussion 此 node 会被自动添加到 scene graph 中。
     如果没有实现此方法，则会自动创建 node。
     如果返回 nil，则会忽略此 anchor。
     @param renderer 将会用于渲染 scene 的 renderer。
     @param anchor 新添加的 anchor。
     @return 将会映射到 anchor 的 node 或 nil。
     */
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let anchor = anchor as? ARPlaneAnchor else {
            return nil
        }
        
        let node = PlaneNode(withAnchor: anchor)
        
        
        DispatchQueue.main.async(execute: {
            self.tipLabel.text = "检测到平面并已添加到场景中，点击屏幕可刷新会话"
        })
        
        return node
        
    }
    
    /**
     将新 node 映射到给定 anchor 时调用。
     
     @param renderer 将会用于渲染 scene 的 renderer。
     @param node 映射到 anchor 的 node。
     @param anchor 新添加的 anchor。
     */
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        
        
    }
    
    /**
     将要用给定 anchor 的数据来更新时 node 调用。
     
     @param renderer 将会用于渲染 scene 的 renderer。
     @param node 即将更新的 node。
     @param anchor 被更新的 anchor。
     */
    func renderer(_ renderer: SCNSceneRenderer, willUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let anchor = anchor as? ARPlaneAnchor else {
            return
        }
        guard let node = node as? PlaneNode else {
            return
        }
        node.updatePlane(anchor: anchor)
        DispatchQueue.main.async(execute: {
            self.tipLabel.text = "场景内有平面更新"
            self.tipLabel.text = "\(anchor.center.x) , \(anchor.center.y) ,\(anchor.center.z)"
        })
    }
    
    /**
     使用给定 anchor 的数据更新 node 时调用。
     
     @param renderer 将会用于渲染 scene 的 renderer。
     @param node 更新后的 node。
     @param anchor 更新后的 anchor。
     */
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
    }
    
    /**
     从 scene graph 中移除与给定 anchor 映射的 node 时调用。
     
     @param renderer 将会用于渲染 scene 的 renderer。
     @param node 被移除的 node。
     @param anchor 被移除的 anchor。
     */
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        guard let anchor = anchor as? ARPlaneAnchor else {
            return
        }
        guard let node = node as? PlaneNode else {
            return
        }
        node.removePlaneNode(WithAnchor: anchor)
        
        DispatchQueue.main.async(execute: {
            self.tipLabel.text = "场景内有平面被删除"
        })
        
    }
    
}

