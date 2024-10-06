//
//  MapContainerView.swift
//  campsite
//
//  Created by 여운칠 on 2022/09/28.
//

import SwiftUI
import GoogleMaps

struct MapContainerView: View {

    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [
			NSSortDescriptor(keyPath: \Entity_Site_Image.contentId, ascending: true),
			NSSortDescriptor(keyPath: \Entity_Site_Image.serialnum, ascending: true)],
        animation: .default)
    private var entity_Site_Image: FetchedResults<Entity_Site_Image>

	@StateObject var controllerCampingSites = GoCampingController.controller
	@StateObject var markerController = GMSMarkerController.controller

	@Binding var isDescPage:Bool
	@Binding var isMapView:Bool
	@Binding var isErrorLoad:Bool

	@State var isDidTap:Bool = false

    var body: some View {

		GeometryReader { geometry in

			ZStack {

				GoogleMapControllerBridge(
					markers: self.$markerController.markers,
					selectedMarker: self.$markerController.currentMarker,
					isDidTap: self.$isDidTap)
			}

			.onChange(of: self.isDidTap, perform: { newValue in
				if newValue {
					if let userData = self.markerController.currentMarker?.userData as? CampingSiteData {
						self.controllerCampingSites.currentCampSite = userData
						self.isDescPage.toggle()
						self.isMapView.toggle()
						self.isDidTap.toggle()

						self.controllerCampingSites.imageUrlPathList.removeAll()

						DispatchQueue.global(qos:.default).async {

							self.controllerCampingSites.getCampSiteImageList(
								context: self.viewContext ){ result in

								self.controllerCampingSites.currentCampSite.isImageListLoaded = true

								if result == false {
									self.isDescPage.toggle()
									self.isErrorLoad.toggle()
								}else {
									self.setImageUrlPathList()
								}
							}
						}
					}
				}
			})
			.onAppear{
				switch self.controllerCampingSites.locationService.authStatus {
					case .notDetermined, .restricted, .denied:
						return
					case .authorizedAlways, .authorizedWhenInUse: do {
						if self.markerController.currentMarker == nil {
							self.startJob()
						}
					}
					@unknown default:
						return
				}


			}

		}
    }
}




extension MapContainerView {

	private func startJob() {
		self.controllerCampingSites.locationService.getCurrentLocation { location in
			self.markerController.setCurrentMarker(location: location.coordinate)
		}
	}

	private func setImageUrlPathList(){

		var imgList:[URL] = []
		self.entity_Site_Image.nsPredicate = NSPredicate(format: "contentId = %@", self.controllerCampingSites.currentCampSite.contentId )
		self.entity_Site_Image.nsSortDescriptors =
			[NSSortDescriptor(keyPath: \Entity_Site_Image.serialnum, ascending: true)]

		self.entity_Site_Image.forEach { item in
			if let url = item.imageUrl, let imgUrl = URL(string: url) {
				imgList.append( imgUrl )
			}
		}
		self.controllerCampingSites.imageUrlPathList = imgList
	}


}


struct MapContainerView_Previews: PreviewProvider {

	@State static var isMapView:Bool = false
	@State static var isDescPage:Bool = false

    static var previews: some View {
        MapContainerView(
			isDescPage: $isDescPage	,
			isMapView: $isMapView,
			isErrorLoad: .constant(false)
		)
    }
}

