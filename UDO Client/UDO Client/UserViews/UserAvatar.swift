//
//  UserAvatar.swift
//  UDO Client
//
//  Created by 崔子寒 on 2021/7/11.
//

import SwiftUI
import UIKit

struct UserAvatar: View {
    var body: some View {
        Image("default-avatar")
            .resizable()
            .frame(width: 50, height: 50, alignment: .center)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.white))
            .shadow(radius: 7)
            
    }
}

struct UserAvatar_Previews: PreviewProvider {
    static var previews: some View {
        UserAvatar()
    }
}
