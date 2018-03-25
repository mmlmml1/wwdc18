import QuartzCore
import SceneKit
import SpriteKit
import ARKit
import UIKit

public class ForkScene: UIViewController {
    
    internal let cameraNode = SCNNode()
    internal let scene = SCNScene(named: "art.scnassets/fork.obj")!
    internal let particle = SCNParticleSystem(named: "art.scnassets/wave.scnp", inDirectory: nil)!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        let size = view.frame
        self.setUpCamera()
        self.setUpLight()
        self.setUpScene()
        self.setUpAdditionalView(size)
    }
    
    internal func setUpCamera() {
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        cameraNode.position = SCNVector3(x: 1, y: 1, z: 2)
        cameraNode.eulerAngles = SCNVector3(x: -15/180*Float.pi, y: 28/180*Float.pi, z: 0/180*Float.pi)
    }

    internal func setUpLight() {
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .ambient
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
    }
    
    internal func setUpScene() {
        let scnView = SCNView()
        scnView.scene = scene
        scnView.allowsCameraControl = false
        scnView.showsStatistics = true
        scnView.backgroundColor = UIColor.black
        self.view = scnView
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
    }
    
    internal func setUpAdditionalView(_ frame: CGRect) {}
    
    @objc public func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        let scnView = self.view as! SCNView
        let p = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: [:])
        if hitResults.count > 0 {
            cameraNode.removeAction(forKey: "audio")
            scene.rootNode.removeParticleSystem(particle)
            scene.rootNode.addParticleSystem(particle)
            self.addWavesToOss()
            let audio = SCNAudioSource(fileNamed: "art.scnassets/440.wav")!
            cameraNode.runAction(SCNAction.playAudio(audio, waitForCompletion: true), forKey: "audio", completionHandler: {
                self.scene.rootNode.removeParticleSystem(self.particle)
                self.removeWavesFromOss()
            })
   
            let result = hitResults[0]
            let material = result.node.geometry!.firstMaterial!
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            SCNTransaction.completionBlock = {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                material.emission.contents = UIColor.black
                SCNTransaction.commit()
            }
            material.emission.contents = UIColor.red
            SCNTransaction.commit()
        }
    }
    
    internal func addWavesToOss() {}
    internal func removeWavesFromOss() {}
    
    override public var prefersStatusBarHidden: Bool {
        return true
    }
}
