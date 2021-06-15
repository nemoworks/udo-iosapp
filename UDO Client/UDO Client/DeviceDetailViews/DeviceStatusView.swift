//
//  DeviceStatusView.swift
//  UDO Client
//
//  Created by 崔子寒 on 2021/6/15.
//

import SwiftUI

struct DeviceStatusView: View {
    var numericalAttrs : [NumericalAttribute]
    var textAttrs : [TextAttribute]
    var enumAttrs : [EnumAttribute]
    @State var switchAttrs : [SwitchAttribute]
    
    init(device:UDODevice) {
        self.numericalAttrs = device.numericalAttrs ?? []
        self.textAttrs = device.textAttrs ?? []
        self.enumAttrs = device.enumAttrs ?? []
        self.switchAttrs = device.switchAttrs ?? []
    }
    
    @ViewBuilder
    var body: some View {
        ScrollView {
            VStack {
                ForEach(self.textAttrs) { textAttr in
                    HStack {
                        Text(textAttr.name)
                            .font(.title2)
                            .bold()
                        Spacer(minLength: 20)
                        Text(textAttr.content)
                            .font(.headline)
                            .foregroundColor(.blue)
                            .multilineTextAlignment(.leading)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }.padding(.top, 3)
                
                if(self.textAttrs.count > 0) {
                 Divider().padding(.top, 5)
                }
            
                ForEach(self.numericalAttrs) { numericalAttr in
                    HStack {
                        Text(numericalAttr.name)
                            .font(.title2)
                            .bold()
                        Spacer()
                        Text(String(numericalAttr.value))
                            .font(.title2)
                            .foregroundColor(.blue)
                            .padding(.trailing, 5)
                    }
                }.padding(.top, 3)
                
                if(self.numericalAttrs.count > 0) {
                    Divider().padding(.top, 5)
                }
                
                ForEach(self.enumAttrs) { enumAttr in
                    HStack {
                        Text(enumAttr.name)
                            .font(.title2)
                            .bold()
                        Spacer()
                        Text(String(enumAttr.options[enumAttr.currentOption]))
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }.padding(.top, 3)
                
                if(self.enumAttrs.count > 0) {
                    Divider().padding(.top, 5)
                }
                
                ForEach(self.switchAttrs.indices) { index in
                    HStack {
                        Text(self.switchAttrs[index].name)
                            .font(.title2)
                            .bold()
                        Spacer()
                        Toggle("", isOn: self.$switchAttrs[index].on)
                    }
                }
                
            }.padding()
        }
    }
}

struct DeviceStatusView_Previews: PreviewProvider {
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
        return DeviceStatusView(device: previewDevice)
            
    }
}
