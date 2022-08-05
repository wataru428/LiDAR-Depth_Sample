//
//  CALayerView.swift
//  LiDAR-Depth_Sample
//
//  Created by 西本渉 on 2022/07/20.
//

import SwiftUI

/// CALayerをSwiftUIで使用するためのクラス
struct CALayerView: UIViewControllerRepresentable {
    var caLayer: CALayer

    func makeUIViewController(context: UIViewControllerRepresentableContext<CALayerView>) -> UIViewController {
        let viewController = UIViewController()

        viewController.view.layer.addSublayer(caLayer)
        caLayer.frame = viewController.view.layer.frame

        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<CALayerView>) {
        caLayer.frame = uiViewController.view.layer.frame
    }
}
