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
        // First check if user has seen onboarding
        let hasSeenOnboarding = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
        
        if !hasSeenOnboarding {
            // User hasn't seen onboarding, show it first
            navigateToOnboarding()
            return
        }
        
        // User has seen onboarding, proceed with normal auth flow
        guard FirebaseAuthManager.shared.isUserLoggedIn else {
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
    
    private func navigateToOnboarding() {
        DispatchQueue.main.async {
            let onboardingVC = OnboardingViewController()
            self.window?.rootViewController = onboardingVC
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
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
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
    }
}
