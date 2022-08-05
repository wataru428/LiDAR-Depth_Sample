//
//  ARSessionObject.swift
//  LiDAR-Depth_Sample
//
//  Created by 西本渉 on 2022/07/20.
//

import ARKit
import VideoToolbox

/// ARSessionをSwiftUIで使用するためのクラス
class ARSessionObject: NSObject,
                       ARSessionDelegate,
                       ObservableObject {
    /// プレビュー用レイヤー
    public var previewLayer: CALayer?
    
    /// ARSessionレンダリングをSceneKitに統合するView
    private let arSCNView = ARSCNView()
    
    /// ワールドトラッキングを実行するための構成情報
    private let arWorldTrackingConfiguration = ARWorldTrackingConfiguration()
    
    /// 深度データイメージのWidth
    private var depthImageWidth = 256
    
    /// 深度データイメージのHeight
    private var depthImageHeight = 192
    
    /// 測定する座標X(0~depthImageWidth)
    private var targetPosX = 128
    
    /// 測定する座標Y(0~depthImageHeight)
    private var targetPosY = 96
    
    /// 指定ポジションの画面上の割合(横方向)
    @Published public var targerPositionRatioX:CGFloat = 0.5
    
    /// 指定ポジションの画面上の割合(縦方向)
    @Published public var targerPositionRatioY:CGFloat = 0.5
    
    /// 指定ポジションの深度(単位はメートル)
    @Published public var targerPositionDepth:Float = 0.0
    
    override init() {
        super.init()
        
        // LiDARの深度情報が使用できるかチェック
        if type(of: arWorldTrackingConfiguration).supportsFrameSemantics(.sceneDepth) {
            arWorldTrackingConfiguration.frameSemantics = .sceneDepth
            
            arSCNView.session.delegate = self
            arSCNView.scene = SCNScene()
            previewLayer = arSCNView.layer
        }
    }
    
    /// セッションの開始
    /// - Returns: 開始処理を実行したかどうか
    public func startSession()-> Bool {
        if previewLayer == nil  {
            return false
        }
        
        arSCNView.session.run(arWorldTrackingConfiguration)
        return true
    }
    
    /// セッションの停止
    public func endSession() {
        arSCNView.session.pause()
    }
    
    /// 新しいカメラからの画像と付随するAR情報が取得できたときのイベント
    /// - Parameters:
    ///   - session: ARSession
    ///   - frame: ARFrame
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        guard let depthData = frame.sceneDepth else {
            return
        }
        
        let depthMap = depthData.depthMap
        CVPixelBufferLockBaseAddress(depthMap, .readOnly)
        
        depthImageWidth = CVPixelBufferGetWidth(depthMap)
        depthImageHeight = CVPixelBufferGetHeight(depthMap)

        // PixelBufferから深度の値を取得
        let floatBuffer = unsafeBitCast(CVPixelBufferGetBaseAddress(depthMap),
                                        to: UnsafeMutablePointer<Float32>.self)
        targerPositionDepth = floatBuffer[targetPosY * depthImageWidth + targetPosX]
        
        CVPixelBufferUnlockBaseAddress(depthMap, .readOnly)
    }
    
    /// プレビュー用レイヤーをタップした時
    /// - Parameter position: タップした座標
    public func onTouchLayer(position: CGPoint) {
        targerPositionRatioX = position.x / UIScreen.main.bounds.size.width
        targerPositionRatioY = position.y / UIScreen.main.bounds.size.height
        
        // 端末の向きがPortraitの時の座標設定
        targetPosX = Int(CGFloat(depthImageWidth) * targerPositionRatioY)
        targetPosY = depthImageHeight - Int(CGFloat(depthImageHeight) * targerPositionRatioX)
    }
}
