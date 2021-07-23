//
//  LoginView.swift
//  UDO Client
//
//  Created by 崔子寒 on 2021/7/13.
//

import SwiftUI

protocol LoginProtocol:AnyObject {
    func login(email: String, password: String)
}

struct LoginView: View {
    
    @State private var email = "test@udo.com"
    @State private var password = ""
    let delegate: LoginProtocol?
    
    var body: some View {
        VStack {
            
            Text("Welcome!")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .padding(.bottom, 20)
            
            Image("cloud").resizable()
                .frame(width: 180, height: 180, alignment: .center)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.init(.sRGB, red: 0.8, green: 0.8, blue: 0.9, opacity: 1.0)))
                .shadow(radius: 3)
                .padding(.bottom, 75)
            
            
            VStack {
                TextField("Enter your email", text: $email)
                    .padding()
                    .background(Color.init(UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)))
                    .cornerRadius(5.0)
                    .textContentType(.emailAddress)
                    .frame(width: 300, height: 60, alignment: .center)
                    .font(.title2)
                    .padding(.bottom, 20)
                
                
                
                SecureField("Enter your password", text: $password)
                    .padding()
                    .background(Color.init(UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)))
                    .cornerRadius(5.0)
                    .padding(.bottom,20)
                    .font(.title2)
                    .frame(width: 300, height: 60, alignment: .center)
            }.padding(.bottom, 40)
            
            Button(action: {
                self.delegate?.login(email: self.email, password: self.password)
                
            }) {
                VStack {
                    Text("LOGIN")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 220, height: 60)
                        .background(buttonColor)
                        .cornerRadius(15.0)
                }
            }.disabled(self.email.isEmpty || self.password.isEmpty)
            
            
            
            
        }.padding()
    }
    
    var buttonColor: Color {
        if self.email.isEmpty || self.password.isEmpty {
            return Color.gray
        } else {
            return Color.green
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(delegate: nil)
    }
}
