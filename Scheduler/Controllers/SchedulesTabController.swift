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
            let schedulesListContorller = navController.viewControllers.first as? ScheduleListController else {
                fatalError("could not load nav controller")
        }
   //     schedulesListContorller.dataPersistence = DataPersistence
        // Set dataPersistence property
        return navController
    }()
    // first we got access to the UINavigationController
    // then we access the first view controller
    private lazy var completedLabController: UINavigationController = {
        guard let labController = storyboard?.instantiateViewController(identifier: "CompletedNavController") as? UINavigationController,
            let completedNavController = labController.viewControllers.first as? CompletedScheduleController else {
                fatalError("could not get controller")
        }
        // Set dataPersistence property
        return labController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        viewControllers = [schedulesNavController, completedLabController]

    }
    
}
