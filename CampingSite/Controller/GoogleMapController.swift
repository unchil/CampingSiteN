//
//  GoogleMapController.swift
//  campsite
//
//  Created by 여운칠 on 2022/09/28.
//
import Foundation
import SwiftUI
import GoogleMaps

class GoogleMapController: UIViewController {

	let setKey = GMSServices.provideAPIKey("provideAPIKey")
	let map =  GMSMapView(frame: .zero)

	override func loadView() {
		super.loadView()
		GMSServices.setMetalRendererEnabled(true)
		self.view = map
	}
	
}

struct GoogleMapControllerBridge : UIViewControllerRepresentable {

	@Binding var markers: [GMSMarker]
	@Binding var selectedMarker: GMSMarker?
	@Binding var isDidTap:Bool
	var zoomLevel:Float = 12

	func makeUIViewController(context: Context) -> GoogleMapController {

	  let uiViewController = GoogleMapController()
		uiViewController.map.delegate = context.coordinator
	  return uiViewController

	}

	func updateUIViewController(_ uiViewController: GoogleMapController, context: Context) {

		self.markers.forEach {
			$0.map = uiViewController.map
		}
		self.selectedMarker?.map = uiViewController.map
		self.updateSelectedMarker(viewController: uiViewController)
	}

	private func updateSelectedMarker(viewController: GoogleMapController) {

		guard let selectedMarker = self.selectedMarker else { return }

		if viewController.map.selectedMarker != selectedMarker {
			viewController.map.selectedMarker = selectedMarker
			viewController.map.moveCamera(GMSCameraUpdate.setTarget(selectedMarker.position, zoom: self.zoomLevel))
		}
	}


	final class MapViewCoordinator: NSObject, GMSMapViewDelegate {

		var mapViewControllerBridge: GoogleMapControllerBridge

		init(_ mapViewControllerBridge: GoogleMapControllerBridge) {
			self.mapViewControllerBridge = mapViewControllerBridge
		}

		func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {

		}

		func mapView(_ mapView: GMSMapView, didCloseInfoWindowOf marker: GMSMarker) {

		}

		func mapView(_ mapView: GMSMapView, didLongPressInfoWindowOf marker: GMSMarker) {
			UISelectionFeedbackGenerator().selectionChanged()
			self.mapViewControllerBridge.isDidTap.toggle()
		}

		func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
			mapView.selectedMarker = nil
		}

		//마커가 선택되려고 할 때 호출
		func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
			marker.tracksInfoWindowChanges = true
			let frameWidth:CGFloat = 190
			let frameHeight:CGFloat = 170
			let radius:CGFloat = 6
			let view = UIView(frame: CGRect(x: 0, y: 0, width: frameWidth, height: frameHeight))
			view.layer.cornerRadius = radius
			view.layer.masksToBounds = true

			let infoWindowView = InfoWindowView(frameWidth: frameWidth, frameHeight: frameHeight, radius: radius)

			if let infoView = UIHostingController(rootView:infoWindowView).view {
				infoView.translatesAutoresizingMaskIntoConstraints = false
				infoView.frame = view.bounds
				view.addSubview(infoView)
			}

			marker.infoWindowAnchor = CGPoint(x: 0.5, y: -0.1)
			return view
		}

		func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
			self.mapViewControllerBridge.selectedMarker = marker
			return true
		}

	}

	func makeCoordinator() -> MapViewCoordinator {
	  return MapViewCoordinator(self)
	}

}


