//
//  DeviceDetailView.swift
//  UDO Client
//
//  Created by 崔子寒 on 2021/6/15.
//

import SwiftUI
import MapKit


struct CircleImage: View {
    var body: some View {
        Image("air-purifier2")
            .resizable()
            .frame(width: 200, height: 200, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.white))
            .shadow(radius: 7)
    }
}

struct DeviceDetailView: View {
    var device: UDODevice?
    
    let mapView = MKMapView()
    
    init(device:UDODevice) {
        self.device = device
    }
    
    let chartDatas = [
        ("Temperature", [14.0,13.0,54.0,62.0,12.5,4.5,7.6,55.5]),
        ("Humidity", [14.1,23.3,34.5,66.3,22.4,44.6,73.5,5.9]),
    ]
    
    var body: some View {
        VStack {
            let region = MKCoordinateRegion(center: self.mapView.userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.4, longitudeDelta: 0.4))
            MapView(region: region).frame(height:250).ignoresSafeArea(edges: .top)
            CircleImage()
                .offset(y:-190)
                .padding(.bottom, -190)
                
                
            
            VStack(alignment: .leading) {
                Text(self.device!.deviceName)
                    .font(.largeTitle)
                
                HStack {
                    Text("Device ID: ").font(.subheadline).foregroundColor(.gray)
                    Spacer(minLength: 10)
                    Text(String(self.device!.deviceID)).font(.subheadline).foregroundColor(.gray)
                }.padding(.top, 5)
                Divider()
                
//                Text("About Turtle Rock").font(.title2).padding(.top, 5)
//                Text("Descriptive text goes here.").padding(.top, 5)
                
            }.padding()
            
            HStack {
                TabView{
                    DeviceStatusView(device: self.device!).tabItem {
                        Image(systemName: "star.square")
                        Text("设备状态")
                    }.tag(1)
                    DeviceHistoryView(datas:self.chartDatas).tabItem {
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
            EnumAttribute(name: "Fan Speed", options: ["High", "Mid", "Low"], currentOption: 1, editable: false)
        ]
        previewDevice.switchAttrs = [
            SwitchAttribute(name: "On", on: true, editable: false)
        ]
        return DeviceDetailView(device: previewDevice)
    }
}
