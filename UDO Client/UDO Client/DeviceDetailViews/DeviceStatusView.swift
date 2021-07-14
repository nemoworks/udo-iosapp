//
//  DeviceStatusView.swift
//  UDO Client
//
//  Created by 崔子寒 on 2021/6/15.
//

import SwiftUI
import UIKit


protocol DeviceStatusSendDelegate: AnyObject {
    func sendDeviceStatus(deviceStatus: DeviceStatus)
}

struct DeviceStatusView: View {
    var numericalAttrs : [NumericalAttribute]
    var textAttrs : [TextAttribute]
    let deviceID: String
    @State var enumAttrs : [EnumAttribute]
    @State var booleanAttrs : [BooleanAttribute]
    var delegate: DeviceStatusSendDelegate?
    
    init(device: UDODevice, deviceViewController: DeviceDetailViewController) {
        self.deviceID = device.deviceID
        self.numericalAttrs = device.numericalAttrs
        self.textAttrs = device.textAttrs
        self.enumAttrs = device.enumAttrs
        self.booleanAttrs = device.booleanAttrs
        self.delegate = deviceViewController
    }
    
    @ViewBuilder
    var body: some View {
        HStack {
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
                                .foregroundColor(.gray)
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
                                .foregroundColor(.gray)
                                .padding(.trailing, 5)
                        }
                    }.padding(.top, 3)
                    
                    if(self.numericalAttrs.count > 0) {
                        Divider().padding(.top, 5)
                    }
                    
                    
                    ForEach(self.enumAttrs.indices) { index in
                        HStack {
                            Text(self.enumAttrs[index].name)
                                .font(.title2)
                                .bold()
                            
                            Spacer()
                            
                            Picker("", selection: self.$enumAttrs[index].currentOption) {
                                ForEach(self.enumAttrs[index].options, id:\.self) {
                                    Text($0)
                                }
                            }.frame(minWidth: 0, idealWidth: 80, maxWidth: 80, minHeight: 0, idealHeight: 90, maxHeight: 120, alignment: .center)
                            .disabled(!self.enumAttrs[index].editable)
                            .clipped()
                            .cornerRadius(20)
                        }
                    }
                    
                    if(self.enumAttrs.count > 0) {
                        Divider().padding(.top, 5)
                    }
                    
                    ForEach(self.booleanAttrs.indices) { index in
                        HStack {
                            Text(self.booleanAttrs[index].name)
                                .font(.title2)
                                .bold()
                            Spacer()
                            Toggle("", isOn: self.$booleanAttrs[index].on).disabled(!self.booleanAttrs[index].editable)
                        }
                    }
                    
                    Divider()
                    
                    Button(action: {
                        print("Done")
                        let userID = (UIDevice.current.identifierForVendor?.uuidString)!
                        var deviceEnumAttributes: [String:String] = [:]
                        var deviceBooleanAttributes: [String:Bool] = [:]
                        for enumAttr in self.enumAttrs {
                            if enumAttr.editable {
                                deviceEnumAttributes[enumAttr.name] = enumAttr.currentOption
                            }
                        }
                        
                        for booleanAttr in self.booleanAttrs {
                            if booleanAttr.editable {
                                deviceBooleanAttributes[booleanAttr.name] = booleanAttr.on
                            }
                        }
                        
                        let deviceStatus = DeviceStatus(device_id: self.deviceID, sender: userID, enum_status: deviceEnumAttributes, boolean_status: deviceBooleanAttributes)
                        self.delegate?.sendDeviceStatus(deviceStatus: deviceStatus)
                        
                    }) {
                        Text("Done").font(.title2).bold().foregroundColor(.blue)
                    }
                    
                }.padding()
            }
        }
    }
}

struct DeviceStatus: Encodable {
    let device_id: String
    let sender: String
    let enum_status: [String: String]
    let boolean_status: [String: Bool]
}



struct DeviceStatusView_Previews: PreviewProvider {
    static var previews: some View {
        let previewDevice = UDODevice(id: "0x12345678", name: "XiaoMi Air Purifier", avatarUrl: "", uri: "123")
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
        return DeviceStatusView(
            device: previewDevice, deviceViewController: DeviceDetailViewController()
        )
            
    }
}
