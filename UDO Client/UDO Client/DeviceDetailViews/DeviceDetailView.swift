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
    
    init(device:UDODevice) {
        self.device = device
    }
    
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Text(self.device.deviceName)
                    .font(.largeTitle)
                
                HStack {
                    Text("Device ID: ").font(.subheadline).foregroundColor(.gray)
                    Spacer(minLength: 10)
                    Text(String(self.device.deviceID)).font(.subheadline).foregroundColor(.gray)
                }.padding(.top, 5)
                Divider()
            }.padding()
            
            HStack {
                TabView{
                    DeviceStatusView(device: self.device).tabItem {
                        Image(systemName: "star.square")
                        Text("设备状态")
                    }.tag(1)
                    DeviceHistoryView(datas:self.device.history).tabItem {
                        Image(systemName: "chart.bar")
                        Text("历史数据")
                    }.tag(2)
                }
                Spacer()
            }
        }
    }
        
}

struct DeviceDetailView_Previews: PreviewProvider {
    
    static var previews: some View {
        let previewDevice = UDODevice(id: 0x12345678, name: "XiaoMi Air Purifier")
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
        return DeviceDetailView(device: previewDevice)
    }
}
