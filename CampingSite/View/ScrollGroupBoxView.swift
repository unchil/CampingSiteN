//
//  ScrollGroupBoxView.swift
//  CampingSite
//
//  Created by 여운칠 on 2022/10/27.
//

import SwiftUI

struct ScrollGroupBoxView: View {

	@Environment(\.managedObjectContext)
	private var viewContext
	
    @FetchRequest(
        sortDescriptors: [
			NSSortDescriptor(keyPath: \Entity_Site_Image.contentId, ascending: true),
			NSSortDescriptor(keyPath: \Entity_Site_Image.serialnum, ascending: true)])
    private var resultSet_SiteImage: FetchedResults<Entity_Site_Image>

	@Binding var campingSiteList:[CampingSiteData]
	@Binding var isDescPage:Bool
	@Binding var isMapView:Bool
	@Binding var isErrorLoad:Bool
	@Binding var labelText:String
	@Binding var labelImg:String

	@StateObject var controllerCampingSites = GoCampingController.controller

	let controllerMarker = GMSMarkerController.controller

	@State var currentImg:UIImage?

    var body: some View {

		GroupBox {
		
			ScrollView{

				ForEach(self.campingSiteList) { item in
					ItemHeaderView(item: item)
					.onTapGesture {
						UISelectionFeedbackGenerator().selectionChanged()
						self.controllerCampingSites.currentCampSite = item
						self.controllerMarker.setCurrentMarker(item: item)
						self.controllerMarker.setMarkers(siteList: self.campingSiteList)
						self.isMapView = true
					}
					.previewContextMenu( preview: ItemDetailView(item: item), presentAsSheet: true ){
						PreviewContextAction(title: PreviewContextMenu.DESC.title, systemImage: PreviewContextMenu.DESC.systemImage ){
							UISelectionFeedbackGenerator().selectionChanged()

							self.controllerCampingSites.currentCampSite = item
							self.isDescPage.toggle()
							self.controllerCampingSites.imageUrlPathList.removeAll()

							DispatchQueue.global(qos:.default).async {

								self.controllerCampingSites.getCampSiteImageList(context: self.viewContext ){ result in

									// Delay Test
									/*
									let _ = Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { timer in
										self.controllerCampingSites.currentCampSite.isImageListLoaded = true
										if result == false {
											self.isDescPage.toggle()
											self.isErrorLoad.toggle()
										}else {
											self.setImageUrlPathList()
										}
										timer.invalidate()
										
									 } */

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

					.padding([.bottom, .trailing], 10)
				}
			}.padding([ .horizontal,.bottom])

		} label: {
			Label( self.labelText , systemImage: self.labelImg)
		}
		.groupBoxStyle(ItemSCrollGroupBoxStyle())
		.modifier(CardModifier(lineWidth: 1))
		.padding([.bottom,.horizontal], 10)

    }
}


extension ScrollGroupBoxView {

	private func setImageUrlPathList(){

		var imgList:[URL] = []
		self.resultSet_SiteImage.nsPredicate =
			NSPredicate(format: "contentId = %@", self.controllerCampingSites.currentCampSite.contentId )
		self.resultSet_SiteImage.nsSortDescriptors =
			[NSSortDescriptor(keyPath: \Entity_Site_Image.serialnum, ascending: true)]

		self.resultSet_SiteImage.forEach { item in
			if let url = item.imageUrl, let imgUrl = URL(string: url) {
				imgList.append( imgUrl )
			}
		}

		self.controllerCampingSites.imageUrlPathList = imgList
	}
}

struct ScrollGroupBoxView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollGroupBoxView(
			campingSiteList:.constant([]),
			isDescPage: .constant(false),
			isMapView: .constant(false),
			isErrorLoad: .constant(false),
			labelText:.constant("경기도 군포시 : 4 건"),
			labelImg: .constant("signpost.right")
		)
    }
}



