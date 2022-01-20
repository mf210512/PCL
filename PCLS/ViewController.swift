//
//  ViewController.swift
//  snowPCL
//
//  Created by pi on 2021/12/31.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    // Struct to hold currently captured Point Cloud data
    private var pointCloud = PointCloud()
    private let addPointRatio = 3 // Show 1 / [addPointRatio] of the points
    private let scanningInterval = 0.5 // Capture points every [scanningInterval] seconds when user is touching screen
    private lazy var pointMaterial: SCNMaterial = createPointMaterial()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
//        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
//        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
        scheduledTimerWithTimeInterval()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    // MARK: - capturePoints 点群を取得
    private func capturePoints() {
            
            // Store Points
            guard let rawFeaturePoints = sceneView.session.currentFrame?.rawFeaturePoints else {
                return
            }
            let currentPoints = rawFeaturePoints.points
            pointCloud.points += currentPoints
            pointCloud.framePointsSizes.append(Int32(currentPoints.count))
            
            // Display points
            var i = 0
            for rawPoint in currentPoints {
                if i % addPointRatio == 0 {
                    addPointToView(position: rawPoint)
                }
                i += 1
            }
            
            // Add viewpoint
            let camera = sceneView.session.currentFrame?.camera
            if let transform = camera?.transform {
                let position = SCNVector3(
                    transform.columns.3.x,
                    transform.columns.3.y,
                    transform.columns.3.z
                )
                pointCloud.frameViewpoints.append(position)
            }
        //mesh 表示
//        print("aaomg:\(performSurfaceReconstruction())")
        }
    /**
         Helper function to add points to the view at the given position.
         */
    private func addPointToView(position: vector_float3) {
        let sphere = SCNSphere(radius: 0.00066)
        sphere.segmentCount = 8
        sphere.firstMaterial = pointMaterial

        let sphereNode = SCNNode(geometry: sphere)
        sphereNode.orientation = (sceneView.pointOfView?.orientation)!
        sphereNode.pivot = SCNMatrix4MakeRotation(-Float.pi / 2, 0, 1, 0)
        sphereNode.position = SCNVector3(position)
//        pointsParentNode.addChildNode(sphereNode)
        sceneView.scene.rootNode.addChildNode(sphereNode)
    }
    
    private var timer = Timer()
    
    private func scheduledTimerWithTimeInterval() {
            // Scheduling timer to call the function "updateCounting" every [scanningInteval] seconds
            timer = Timer.scheduledTimer(timeInterval: scanningInterval, target: self, selector: #selector(updateCounting), userInfo: nil, repeats: true)
        }
    
    @objc func updateCounting() {
        capturePoints()
    }
    
        //ボタン押されたら形表示
//    func reconstructButtonTapped() {
//
//            // Prepare Point Cloud data structures in C struct format
//
//            let pclPoints = pointCloud.points.map { PCLPoint3D(x: Double($0.x), y: Double($0.y), z: Double($0.z)) }
//            let pclViewpoints = pointCloud.frameViewpoints.map { PCLPoint3D(x: Double($0.x), y: Double($0.y), z: Double($0.z)) }
//
//            let pclPointCloud = PCLPointCloud(
//                numPoints: Int32(pointCloud.points.count),
//                points: pclPoints,
//                numFrames: Int32(pointCloud.frameViewpoints.count),
//                pointFrameLengths: pointCloud.framePointsSizes,
//                viewpoints: pclViewpoints)
//
//            // Call C++ Surface Reconstruction function using C Wrapper
//            let pclMesh = performSurfaceReconstruction(pclPointCloud)
//            defer {
//                // The mesh points and polygons pointers were allocated in C++ so need to be freed here
//                free(pclMesh.points)
//                free(pclMesh.polygons)
//            }
//
//            // Remove current surfaces before displaying new surface
//            surfaceParentNode.enumerateChildNodes { (node, stop) in
//                node.removeFromParentNode()
//                node.geometry = nil
//            }
//
//            // Display surface
//            displaySurfaceSwitch.isOn = true
//            isSurfaceDisplayOn = true
//            let surfaceNode = constructSurfaceNode(pclMesh: pclMesh)
//            surfaceParentNode.addChildNode(surfaceNode)
//
//            isCapturingPoints = false
//            showAlert(title: "Surface Reconstructed", message: "\(pclMesh.numFaces) faces")
//        }
    /**
         Creates a the SCNMaterial to be used for points in the displayed Point Cloud.
         */
    private func createPointMaterial() -> SCNMaterial {
        let textureImage = #imageLiteral(resourceName: "WhiteBlack")
        UIGraphicsBeginImageContext(textureImage.size)
        let width = textureImage.size.width
        let height = textureImage.size.height
        textureImage.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        let pointMaterialImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let pointMaterial = SCNMaterial()
        pointMaterial.diffuse.contents = pointMaterialImage
        return pointMaterial
    }
}

