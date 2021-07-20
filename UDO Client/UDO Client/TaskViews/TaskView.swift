//
//  TaskView.swift
//  UDO Client
//
//  Created by 崔子寒 on 2021/7/20.
//

import SwiftUI
import UIKit

struct TaskView: View {
    @State var taskName: String = ""
    @State var taskTime: Date = Date()
    @State var taskAddr: String = ""
    @State var category: String = "default"
    @State var level: String = "default"
    @State var description: String = "please input task descripton."
    @State private var isShowImagePicker = false
    @State private var image = UIImage(named: "bg")!
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    var categoryOptions = [
        "default",
        "otherwise"
    ]
    
    var levelOptions = [
        "default",
        "emergency"
    ]
    
    init() {
        UITextView.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        ScrollView{
            VStack {
                VStack {
                    HStack{
                        Text("Task Name: ").font(.title2).bold()
                        Spacer(minLength: 30)
                        TextField("Enter task name", text: $taskName)
                            .padding(.init(top: 5, leading: 5, bottom: 5, trailing: 5))
                            .background(Color.init(UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)))
                            .cornerRadius(5.0)
                            .textContentType(.none)
                            .font(.title2)
                            .padding()
                        
                    }.padding(.init(top: 3, leading: 10, bottom: 3, trailing: 10))
                    
                    Divider()
                    
                    HStack {
                        Text("Task Time: ").font(.title2).bold()
                        Spacer(minLength: 35)
                        DatePicker("", selection: $taskTime)
                            .padding()
                            .font(.title2)
                            .cornerRadius(2.0)
                        
                    }.padding(.init(top: 3, leading: 10, bottom: 3, trailing: 10))
                    
                    Divider()
                    
                    HStack{
                        Text("Task Addr: ").font(.title2).bold()
                        Spacer(minLength: 45)
                        TextField("Enter task addr", text: $taskAddr)
                            .padding(.init(top: 5, leading: 5, bottom: 5, trailing: 5))
                            .background(Color.init(UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)))
                            .cornerRadius(5.0)
                            .textContentType(.none)
                            .font(.title2)
                            .padding()
                        
                    }.padding(.init(top: 3, leading: 10, bottom: 3, trailing: 10))
                    
                    Divider()
                    
                    HStack {
                        Text("Category:").bold().font(.title2)
                        Spacer(minLength: 75)
                        Picker("", selection: $category){
                            ForEach(self.categoryOptions, id: \.self){
                                Text($0)
                            }
                        }
                        .frame(minWidth: 0, idealWidth: 280, maxWidth: 280, minHeight: 0, idealHeight: 60, maxHeight: 70, alignment: .center)
                        .clipped()
                        .cornerRadius(5.0)
                        
                    }.padding(.init(top: 3, leading: 10, bottom: 3, trailing: 10))
                    
                    Divider()
                    
                    HStack {
                        Text("Level:").bold().font(.title2)
                        Spacer(minLength: 115)
                        Picker("", selection: $level){
                            ForEach(self.levelOptions, id: \.self){
                                Text($0)
                            }
                        }
                        .frame(minWidth: 0, idealWidth: 280, maxWidth: 280, minHeight: 0, idealHeight: 60, maxHeight: 70, alignment: .center)
                        .clipped()
                        .cornerRadius(5.0)
                        
                    }.padding(.init(top: 3, leading: 10, bottom: 3, trailing: 10))
                }
                
                Divider()
                
                HStack {
                    Text("Description: ").font(.title2).bold()
                    Spacer(minLength: 45)
                    TextEditor(text: $description)
                        .background(Color.init(UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)))
                        .cornerRadius(5.0)
                        .font(.title2)
                        .frame(minWidth: 0, idealWidth: 300, maxWidth: .infinity, minHeight: 0, idealHeight: 100, maxHeight: 150, alignment: .center)
                    
                    
                }.padding(.init(top: 3, leading: 10, bottom: 3, trailing: 10))
                
                Divider()
                
                Button(action: {
                    self.sourceType = .photoLibrary
                    self.isShowImagePicker = true
                }, label: {
                    Image(systemName: "photo")
                        .font(.system(size: 20))
                    Text("Photo Library")
                        .font(.headline)
                }).frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 50)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(20)
                .padding(.init(top: 5, leading: 15, bottom: 10, trailing: 15))
                
                Button(action: {
                    self.sourceType = .camera
                    self.isShowImagePicker = true
                }, label: {
                    Image(systemName: "photo")
                        .font(.system(size: 20))
                    Text("Camera")
                        .font(.headline)
                }).frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 50)
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(20)
                .padding(.init(top: 5, leading: 15, bottom: 10, trailing: 15))
                
                Image(uiImage: self.image)
                    .resizable()
                    .scaledToFit()
                    .padding()
                
                Spacer()
                
            }.sheet(isPresented: self.$isShowImagePicker, content: {
                ImagePicker(sourceType: self.sourceType, selectedImage: $image)
            })
            
            
        }
    }
}

struct TaskView_Previews: PreviewProvider {
    static var previews: some View {
        TaskView()
    }
}
