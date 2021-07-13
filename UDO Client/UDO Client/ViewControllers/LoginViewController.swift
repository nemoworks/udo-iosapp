//
//  LoginViewController.swift
//  UDO Client
//
//  Created by 崔子寒 on 2021/7/13.
//

import UIKit
import SwiftUI

class LoginViewController: UIViewController {
    @IBOutlet weak var theContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let loginView = LoginView(delegate: self)
        let childView = UIHostingController(rootView: loginView)
        childView.view.frame = self.theContainer.bounds
        self.theContainer.addSubview(childView.view)
        childView.didMove(toParent: self)
    }

}

extension LoginViewController: LoginProtocol {
    func login(email: String, password: String) {
        print(email)
        print(password)
        // TODO: validate email and password
        MQTTClient.USER_EMAIL = email
        // self.dismiss(animated: true, completion: nil)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tabBarController = storyboard.instantiateViewController(withIdentifier: "mainTabBarController") as! UITabBarController
        let deviceViewController = (tabBarController.viewControllers?.first as! UINavigationController).viewControllers.first as! DeviceViewController
        let userViewController = (tabBarController.viewControllers?[1] as! UINavigationController).viewControllers.first as! UserViewController
        MQTTClient.shared.delegate = deviceViewController
        userViewController.startTimer()
        tabBarController.modalPresentationStyle = .fullScreen
        self.present(tabBarController, animated: true, completion: nil)
    }
}


