//
//  SceneDelegate.swift
//  studysphere
//
//  Created by admin64 on 28/10/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).

        guard let windowScene = (scene as? UIWindowScene) else { return }
                
                window = UIWindow(windowScene: windowScene)
                let loadingVC = LoadingViewController()
                window?.rootViewController = loadingVC
                window?.makeKeyAndVisible()
                
                Task {
                    await checkAndNavigate()
                }
    }
        
    private func checkAndNavigate() async {
        guard FirebaseAuthManager.shared.isUserLoggedIn  && FirebaseAuthManager.shared.currentUser!.isEmailVerified else {
                navigateToLogin()
                return
            }
            
            do {
                let user = FirebaseAuthManager.shared.currentUser
                if let _ = try await userDB.findAll(where: ["email": user!.email!]).first {
                    navigateToMain()
                } else {
                    navigateToLogin()
                }
            } catch {
                print("Error checking user: \(error)")
                navigateToLogin()
            }
        }
        
        private func navigateToMain() {
            DispatchQueue.main.async {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let tabBarVC = storyboard.instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController {
                    self.window?.rootViewController = tabBarVC
                }
            }
        }
        
        private func navigateToLogin() {
            DispatchQueue.main.async {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let loginVC = storyboard.instantiateInitialViewController()
                self.window?.rootViewController = loginVC
            }
        }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        if let rootVC = window?.rootViewController {
                refreshViewController(rootVC)
            }
    }
    private func refreshViewController(_ viewController: UIViewController) {
        // Refresh labels in the view controller
        for subview in viewController.view.subviews {
            if let label = subview as? UILabel {
                label.setNeedsDisplay()
            }
            // Recursive search for labels
            findAndRefreshLabels(in: subview)
        }
        
        // Handle navigation controllers, tab bar controllers, etc.
        if let navController = viewController as? UINavigationController {
            navController.viewControllers.forEach { refreshViewController($0) }
        } else if let tabController = viewController as? UITabBarController {
            tabController.viewControllers?.forEach { refreshViewController($0) }
        } else if let presented = viewController.presentedViewController {
            refreshViewController(presented)
        }
    }

    private func findAndRefreshLabels(in view: UIView) {
        for subview in view.subviews {
            if let label = subview as? UILabel {
                // Force redraw
                label.setNeedsDisplay()
                // Ensure text color is set
                if label.textColor == nil || label.textColor == .clear {
                    label.textColor = .black
                }
            }
            findAndRefreshLabels(in: subview)
        }
    }



    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

