//
//  CameraView.swift
//  LiDAR-Depth_Sample
//
//  Created by 西本渉 on 2022/07/20.
//

import SwiftUI

/// カメラ画面
struct CameraView: View {
    
    /// ARSessionのObject
    @ObservedObject private var arSessionObject = ARSessionObject()
    
    /// この画面の表示フラグ
    @Binding var isDisplayView: Bool
    
    /// アラート表示フラグ
    @State private var isDisplayAlert = false
    
    var body: some View {
        ZStack(alignment:.topLeading) {
            VStack {
                Spacer()
                
                if let layer = arSessionObject.previewLayer {
                    CALayerView(caLayer: layer)
                        .gesture(
                            DragGesture(minimumDistance: 0, coordinateSpace: .global)
                                .onChanged { value in
                                    arSessionObject.onTouchLayer(position: value.location)
                                }
                    )
                }
                
                Spacer()
            }
            .onAppear {
                if !self.arSessionObject.startSession() {
                    DispatchQueue.main.async {
                        isDisplayAlert.toggle()
                    }
                }
            }
            .onDisappear {
                self.arSessionObject.endSession()
            }
            
            // 深度のテキスト(単位はメートル)
            Text(arSessionObject.targerPositionDepth.description)
                .position(x: (UIScreen.main.bounds.size.width  * arSessionObject.targerPositionRatioX),
                          y: (UIScreen.main.bounds.size.height  * arSessionObject.targerPositionRatioY))
            
            // 閉じるボタン
            Button(action: {
                self.arSessionObject.endSession()
                isDisplayView.toggle()
            }) {
                Image(systemName: "xmark")
                    .renderingMode(.original)
                    .resizable()
                    .frame(width: 40, height: 40, alignment: .center)
                    .padding()
            }
            
        }
        .alert(isPresented: $isDisplayAlert) {
            Alert(title: Text("エラー"),
                  message: Text("未対応の端末です"),
                  dismissButton: .default(Text("OK"), action: { isDisplayView.toggle() }))
        }
    }
}

struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView(isDisplayView: .constant(true))
    }
}
