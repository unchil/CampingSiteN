//
//  CampingSiteApp.swift
//  CampingSite
//
//  Created by 여운칠 on 2022/09/29

import SwiftUI

@main
struct CampingSiteApp: App {
    let persistenceController = PersistenceController.shared
    var body: some Scene {
        WindowGroup {
        
			IntroView()
			.onAppear{
				LocationService.service.cLLocationManager.requestLocation()
			}
			.environment(\.managedObjectContext, persistenceController.container.viewContext)


		}
    }
}


