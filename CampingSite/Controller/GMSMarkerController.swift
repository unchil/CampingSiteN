//
//  GMSMarkerController.swift
//  campsite
//
//  Created by 여운칠 on 2022/09/28.
//


import Foundation
import GoogleMaps

class GMSMarkerController: ObservableObject {

	static let controller = GMSMarkerController()

	@Published var currentMarker: GMSMarker?
	@Published var markers: [GMSMarker] = []

	func setMarkers(siteList:[CampingSiteData] ){

		var markers: [GMSMarker] = []
		siteList.forEach { item in
			let location = CLLocationCoordinate2D(latitude: item.latitude ,longitude: item.longitude )
			let marker = GMSMarker(position:location)
			marker.snippet = item.lineIntro
			marker.title = item.facltNm
			marker.userData = item
			markers.append(marker)
		}
		self.markers = markers

	}

	func setCurrentMarker(item: CampingSiteData){
		let location = CLLocationCoordinate2D(latitude: item.latitude, longitude: item.longitude)
		self.currentMarker = GMSMarker(position: location)
		self.currentMarker?.userData = item
	}

	func setCurrentMarker(location: CLLocationCoordinate2D){
		self.currentMarker = GMSMarker(position: location)
	}
}


