import SwiftUI
import SceneKit
import ModelIO

/// SceneKit-based 3D model viewer with gesture controls
struct SceneKitPreview: UIViewRepresentable {
    let meshURL: URL?

    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        sceneView.backgroundColor = .systemBackground
        sceneView.autoenablesDefaultLighting = true
        sceneView.allowsCameraControl = true // Pinch zoom, pan, rotate

        let scene = SCNScene()
        sceneView.scene = scene

        // Camera
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.automaticallyAdjustsZRange = true
        cameraNode.position = SCNVector3(0, 0.3, 1.0)
        scene.rootNode.addChildNode(cameraNode)

        // Load mesh if available
        if let url = meshURL {
            loadMesh(url: url, into: scene)
        } else {
            addPlaceholder(to: scene)
        }

        return sceneView
    }

    func updateUIView(_ uiView: SCNView, context: Context) {}

    private func loadMesh(url: URL, into scene: SCNScene) {
        let asset = MDLAsset(url: url)
        asset.loadTextures()

        for i in 0..<asset.count {
            let mdlObject = asset.object(at: i)
            let node = SCNNode(mdlObject: mdlObject)
            scene.rootNode.addChildNode(node)
        }
    }

    private func addPlaceholder(to scene: SCNScene) {
        let box = SCNBox(width: 0.3, height: 0.3, length: 0.3, chamferRadius: 0.02)
        box.firstMaterial?.diffuse.contents = UIColor.systemBlue.withAlphaComponent(0.3)
        box.firstMaterial?.isDoubleSided = true
        let node = SCNNode(geometry: box)
        node.runAction(.repeatForever(.rotateBy(x: 0, y: .pi, z: 0, duration: 4)))
        scene.rootNode.addChildNode(node)
    }
}
