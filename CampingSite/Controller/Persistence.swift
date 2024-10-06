//
//  Persistence.swift
//  CampingSite
//
//  Created by 여운칠 on 2022/09/29.
//

import CoreData



struct PersistenceController {

	let container: NSPersistentContainer

	init(inMemory:Bool = false) {

		container = NSPersistentContainer(name: "CampingSite")

		if inMemory {
			container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
		}

		container.viewContext.automaticallyMergesChangesFromParent = true

		container.loadPersistentStores { nsPersistentStoreDescription, error in
			if let error = error as NSError? {
				fatalError("Unresolved error \(error), \(error.userInfo)")
			}
		}


		initCollectTime()

	}

	static var shared: PersistenceController {
		return PersistenceController(inMemory: false)
	}

	static var preview: PersistenceController {
		return PersistenceController(inMemory: true)
	}

	private func initCollectTime()  {

		guard let entityCollectTime =
			NSEntityDescription.entity ( forEntityName: "Entity_CollectTime", in: self.container.viewContext) else { return  }

		let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityCollectTime.name!)

		do {

			let results = try self.container.viewContext.fetch(fetchRequest)

			if (results.isEmpty) {
				let object = NSManagedObject(entity: entityCollectTime, insertInto:  self.container.viewContext)
				object.setValue(0, forKeyPath: "install")
				object.setValue(0, forKeyPath: "administrative")
				object.setValue(0, forKeyPath: "administrativesigungu")				
				object.setValue(0, forKeyPath: "allsite")
				object.setValue(0, forKeyPath: "nearsite")
				object.setValue(0, forKeyPath: "siteimage")
				object.setValue(0, forKeyPath: "weather")
				try self.container.viewContext.save()
			}
		} catch {
			let nsError = error as NSError
			fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
		}
	}

}


func commitTrans(context: NSManagedObjectContext) {

	do {
		try context.save()
	}catch {
		print(#function, error.localizedDescription)
	}

}

func truncateEntity(context: NSManagedObjectContext,  entityName: String, completion: @escaping () -> (Void)? ) {

	let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)

	do{
		let objects = try context.fetch(fetchRequest)

		objects.forEach { it in
			context.delete(it)
		}
		try context.save()

	} catch {
		print(#function, error.localizedDescription)
	}

	completion()
}


func deleteEntity(context: NSManagedObjectContext,  entityName: String, predicate: NSPredicate, completion: @escaping () -> (Void)? )  {

	let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
	fetchRequest.predicate = predicate

	do {
		let objects = try context.fetch(fetchRequest)
		objects.forEach { it in
			context.delete(it)
		}
		try context.save()
	} catch {
		print(#function, error.localizedDescription)
	}

	completion()
}

func updateEntityCollectTime(context: NSManagedObjectContext, collum:CollectTimeCollum, completion: @escaping () -> ()?)  {

	let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Entity_CollectTime")
	fetchRequest.fetchLimit = 1
	let value = trunc(Date().timeIntervalSince1970)
	do {
		let objects = try context.fetch(fetchRequest)
		if let it = objects.first {
			switch collum {
				case .INSTALL: do{
					it.setValue(value, forKey: CollectTimeCollum.INSTALL.rawValue)
				//	it.setValue(value, forKey: CollectTimeCollum.ALL_SITE.rawValue)
				//	it.setValue(value, forKey: CollectTimeCollum.NEAR_SITE.rawValue)
				//	it.setValue(value, forKey: CollectTimeCollum.ADMINISTRATIVE.rawValue)
				}
				case .ADMINISTRATIVE,.ADMINISTRATIVESIGUNGU, .ALL_SITE, .NEAR_SITE, .WEATHER: do {
					it.setValue(value, forKey: collum.rawValue)
				}
				case .SITE_IMAGE: break

			}
		}
		try context.save()
	} catch {
		print(#function, error.localizedDescription)
	}

	completion()
}

func batchDelete (context: NSManagedObjectContext,  entityName: String, completion: @escaping () -> (Void)?) {

	let fetchRequest:NSFetchRequest<NSFetchRequestResult>  = NSFetchRequest(entityName: entityName)
	let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
	do {
		try context.execute(deleteRequest)
		try context.save()
	}catch {
		print(#function, error.localizedDescription)
	}

	completion()
}

