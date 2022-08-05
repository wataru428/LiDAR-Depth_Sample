//
//  ContentView.swift
//  LiDAR-Depth_Sample
//
//  Created by 西本渉 on 2022/07/20.
//

import SwiftUI

/// 起動して最初の画面
struct ContentView: View {
    /// 画面遷移フラグ
    @State private var isMoveNextView = false
    
    var body: some View {
        NavigationView {
            
            VStack(alignment: .center, spacing: 20) {
                
                Button("カメラ起動",
                       action: {
                    isMoveNextView.toggle()
                }).padding()
                
            }
            .navigationBarTitle("深度計測テスト", displayMode: .automatic)
            .fullScreenCover(isPresented: $isMoveNextView,
                             content: { CameraView(isDisplayView: $isMoveNextView) })
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
