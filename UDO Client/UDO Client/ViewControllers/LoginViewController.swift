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
        let userViewController = (tabBarController.viewControllers?[0] as! UINavigationController).viewControllers.first as! UserViewController
        let resourceViewController = (tabBarController.viewControllers?[1] as! UINavigationController).viewControllers.first as! ResourceViewController
        let contextViewController = (tabBarController.viewControllers?[2] as! UINavigationController).viewControllers.first as! ContextViewController
        DataManager.shared.resourceFoundDelegate = resourceViewController
        DataManager.shared.contextFoundDelegate = contextViewController
        MQTTClient.shared.delegate = DataManager.shared
        userViewController.startTimer()
        tabBarController.modalPresentationStyle = .fullScreen
        self.present(tabBarController, animated: true, completion: nil)
    }
}


