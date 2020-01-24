//
//  SchedulesTabController.swift
//  Scheduler
//
//  Created by Christian Hurtado on 1/24/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit

class SchedulesTabController: UITabBarController {
    
    private let dataPersistence = DataPersistence<Event>(filename: "schedules.plist")
    
    // get instances of the two tabs from storyboard
    
    private lazy var schedulesNavController: UINavigationController = {
        guard let navController = storyboard?.instantiateViewController(identifier: "SchedulesNavController") as? UINavigationController,
            let schedulesListController = navController.viewControllers.first as? ScheduleListController else {
                fatalError("could not load nav controller")
        }
        schedulesListController.dataPersistence = dataPersistence
            
//            .dataPersistence = dataPersistence
        // Set dataPersistence property
        return navController
    }()
    // first we got access to the UINavigationController
    // then we access the first view controller
    private lazy var completedLabController: UINavigationController = {
        guard let navController = storyboard?.instantiateViewController(identifier: "CompletedNavController") as? UINavigationController,
            let completedNavController = navController.viewControllers.first as? CompletedScheduleController else {
                fatalError("could not get controller")
        }
        // Set dataPersistence property
        completedNavController.dataPersistence = dataPersistence
        // step 4: set custom delegate - set delegate object
        completedNavController.dataPersistence.delegate = completedNavController
        return navController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        viewControllers = [schedulesNavController, completedLabController]

    }
    
}

extension SchedulesTabController: DataPersistenceDelegate {
    func didDeleteItem<T>(_ persistenceHelper: DataPersistence<T>, item: T) where T : Decodable, T : Encodable, T : Equatable {
        print("Item was deleted")
    }
}
