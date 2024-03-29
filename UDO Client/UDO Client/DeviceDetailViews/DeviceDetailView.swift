//
//  DeviceDetailView.swift
//  UDO Client
//
//  Created by 崔子寒 on 2021/6/15.
//

import SwiftUI
import MapKit



struct DeviceDetailView: View {
    var device: UDODevice
    var vc: DeviceDetailViewController
    @State var refresh = true
    
    
    init(device:UDODevice, vc: DeviceDetailViewController) {
        self.device = device
        self.vc = vc
    }
    
    
    var body: some View {
        
        TabView{
            DeviceStatusView(device: self.device, delegate: self.vc)
                .tabItem {
                    Image(systemName: "star.square")
                    Text("Status")
                }.tag(1)
            
            DeviceHistoryView(datas:self.device.history).tabItem {
                Image(systemName: "chart.bar")
                Text("History")
            }.tag(2)
        }.edgesIgnoringSafeArea(.all)
        
    }
    
}

struct DeviceDetailView_Previews: PreviewProvider {
    
    static var previews: some View {
        let previewDevice = UDODevice(uri: "1234", name: "XiaoMi Air Purifier", context: "office-409", avatarUrl: "")
        previewDevice.textAttrs = [
            TextAttribute(name: "Description", content: "Xiaomi air purifier can purify the air")
        ]
        previewDevice.numericalAttrs = [
            NumericalAttribute(name: "Temperature", value: 25.5),
            NumericalAttribute(name: "Humidity", value: 0.5)
        ]
        previewDevice.enumAttrs = [
            EnumAttribute(name: "Fan Speed", options: ["High", "Mid", "Low"], currentOption: "Mid", editable: false)
        ]
        previewDevice.booleanAttrs = [
            BooleanAttribute(name: "On", on: true, editable: false)
        ]
        return DeviceDetailView(device: previewDevice, vc: DeviceDetailViewController())
    }
}
