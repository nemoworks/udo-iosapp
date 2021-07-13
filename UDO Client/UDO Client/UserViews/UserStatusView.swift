//
//  UserStatusView.swift
//  UDO Client
//
//  Created by 崔子寒 on 2021/7/3.
//

import SwiftUI
import MapKit

protocol UserStatusChangeDelegate:AnyObject {
    func changeAvaliable(to value: Bool)
}

struct UserStatusView: View {
    
    var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 31, longitude: 118), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
    var userName: String = "udo-user"
    
    var userEmail = MQTTClient.USER_EMAIL

    @State var isAvailable: Bool = false
    
    private var locationManager = CLLocationManager()
    
    weak var delegate: UserStatusChangeDelegate?
    
    var body: some View {
        VStack {
            
            Divider()
            
            HStack {
                Text("User").font(.title2).bold().padding()
                Spacer(minLength: 10)
                UserAvatar()
                Text(self.userName).font(.title2).padding().foregroundColor(.gray)
            }
            
            Divider()
            
            HStack {
                Text("Email").font(.title2).bold().padding()
                Spacer(minLength: 10)
                Text(self.userEmail).font(.title2).foregroundColor(.gray)
            }
            
            Divider()
            
            HStack {
                Text("Available").font(.title2).bold().padding()
                Spacer()
                Toggle("", isOn: self.$isAvailable).onChange(of: self.isAvailable, perform: { value in
                    self.delegate?.changeAvaliable(to: value)
                })
            }
            
            Spacer()
        }.padding().onAppear{
            if locationManager.authorizationStatus != .authorizedWhenInUse {
                locationManager.requestWhenInUseAuthorization()
            }
        }
    }
}

struct UserStatusView_Previews: PreviewProvider {
    static var previews: some View {
        UserStatusView()
    }
}
