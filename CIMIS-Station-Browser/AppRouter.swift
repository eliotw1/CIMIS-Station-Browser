//
//  AppRouter.swift
//  CIMIS-Station-Browser
//
//  Created by Eliot Williams on 7/25/23.
//

import UIKit
import SwiftUI

enum AppDestination {
    case base
    case list(StationListView)
    case detail(StationDetailsView)
}

protocol RouterInterface {
    func navigate(to destination: AppDestination, animated: Bool)
}

final class AppRouter: ObservableObject, RouterInterface {
    
    weak var navigationController: UINavigationController?
    
    func navigate(to destination: AppDestination, animated: Bool = true) {
        switch destination {
        case .base:
            navigationController?
                .popToRootViewController(
                    animated: animated
                )
        case .list(let listView):
            navigationController?
                .setViewControllers(
                    [
                        UIHostingController(rootView: listView),
                    ],
                    animated: animated)
        case .detail(let stationDetailsView):
            guard let controller = navigationController,
                  controller.topViewController is UIHostingController<StationListView> else { return }
            controller
                .pushViewController(
                    UIHostingController(
                        rootView: stationDetailsView
                    ),
                    animated: animated
                )
        }
    }
}

#if DEBUG
struct MockRouter: RouterInterface {
    func navigate(to destination: AppDestination, animated: Bool) {
        // Nothing
    }
}
#endif
