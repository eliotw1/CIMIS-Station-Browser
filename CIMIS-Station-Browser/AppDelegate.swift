//
//  AppDelegate.swift
//  CIMIS-Station-Browser
//
//  Created by Eliot Williams on 7/25/23.
//

import CoreData
import UIKit
import SwiftUI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    let persistenceController = PersistenceController.shared
    let context: NSManagedObjectContext
    var services: ServicesInterface
    var store: SavedStationStore
    
    weak var listController: StationListController?
    var window: UIWindow?
    
    private(set)
    var router: AppRouter
    
    override init() {
        let context = persistenceController.container.viewContext
        self.context = context
        self.router = AppRouter()
        self.services = ServicesContainer(
            fetchService: FetchStationsService(),
            savedService: SavedStationServiceContainer(
                getService: FetchSavedStationsService(context: context),
                addService: AddSavedStationService(context: context),
                removeService: RemoveSavedStationService(context: context)
            ),
            stationDataService: StationDataService()
        )
        self.store = SavedStationStore()
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let listController = StationListController(
            router: router,
            services: services,
            store: store
        )
        self.listController = listController
        
        let stationView = listController.createStationListView()

        let rootVC = UIHostingController(rootView: stationView)
        let rootNavigationController = UINavigationController(rootViewController: rootVC)
        router.navigationController = rootNavigationController

        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window
        self.window?.rootViewController = rootNavigationController
        self.window?.makeKeyAndVisible()

        return true
    }
}
