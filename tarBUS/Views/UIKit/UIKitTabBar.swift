//
//  UIKitTabBar.swift
//  tarBUS
//
//  Created by Kuba Florek on 11/02/2021.
//

import UIKit
import SwiftUI

struct UIKitTabView: View {
    var viewControllers: [UIHostingController<AnyView>]

    init(_ tabs: [Tab]) {
        self.viewControllers = tabs.map {
            let host = UIHostingController(rootView: $0.view)
            host.tabBarItem = $0.barItem
            return host
        }
    }

    var body: some View {
        TabBarController(controllers: viewControllers).edgesIgnoringSafeArea(.all)
    }

    struct Tab {
        var view: AnyView
        var barItem: UITabBarItem

        init<V: View>(view: V, barItem: UITabBarItem) {
            self.view = AnyView(view)
            self.barItem = barItem
        }
    }
}


struct TabBarController: UIViewControllerRepresentable {
    var controllers: [UIViewController]

    func makeUIViewController(context: Context) -> UITabBarController {
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = controllers
        tabBarController.delegate = context.coordinator
        return tabBarController
    }

    func updateUIViewController(_ uiViewController: UITabBarController, context: Context) { }
}

extension TabBarController {
    func makeCoordinator() -> TabBarController.Coordinator {
        Coordinator(self)
    }
    class Coordinator: NSObject, UITabBarControllerDelegate {
        var parent: TabBarController
        init(_ parent: TabBarController){self.parent = parent}
        var previousController: UIViewController?
        private var shouldSelectIndex = -1
        
        func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
            shouldSelectIndex = tabBarController.selectedIndex
            return true
        }

        func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
            if shouldSelectIndex == tabBarController.selectedIndex {
                if let navVC = tabBarController.viewControllers![shouldSelectIndex].nearestNavigationController {
                    if (!(navVC.popViewController(animated: true) != nil)) {
                        navVC.viewControllers.first!.scrollToTop()
                    }
                }
            }
        }
    }
}

extension UIViewController {
    var nearestNavigationController: UINavigationController? {
        if let selfTypeCast = self as? UINavigationController {
            return selfTypeCast
        }
        if children.isEmpty {
            return nil
        }
        for child in self.children {
            return child.nearestNavigationController
        }
        return nil
    }
}

extension UIViewController {
    func scrollToTop() {
        func scrollToTop(view: UIView?) {
            guard let view = view else { return }
            switch view {
            case let scrollView as UIScrollView:
                if scrollView.scrollsToTop == true {
                    scrollView.setContentOffset(CGPoint(x: 0.0, y: -scrollView.safeAreaInsets.top), animated: true)
                    return
                }
            default:
                break
            }

            for subView in view.subviews {
                scrollToTop(view: subView)
            }
        }
        scrollToTop(view: view)
    }
}
