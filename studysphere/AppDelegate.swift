//
//  AppDelegate.swift
//  studysphere
//
//  Created by admin64 on 28/10/24.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UINavigationBar.appearance().tintColor = AppTheme.primary
        print(UILabel.appearance().textColor)
        //change tabbar color
        UITabBar.appearance().tintColor = AppTheme.primary
        FirebaseApp.configure()
                
                return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    private func checkAndNavigate() async {
        guard FirebaseAuthManager.shared.isUserLoggedIn == true else {
            return
        }
        let user = FirebaseAuthManager.shared.currentUser
        do {
            if let _ = try await userDB.findAll(where: ["email": user!.email!]).first {
                DispatchQueue.main.async {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    if let tabBarVC = storyboard.instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController {
                        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.rootViewController = tabBarVC
                    }
                }
            }
        } catch {
            print("Error checking user: \(error)")
        }
    }

}

