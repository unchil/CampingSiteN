//
//  ContentView.swift
//  CampingSite
//
//  Created by 여운칠 on 2022/11/17.
//

import SwiftUI
import CoreData
import CoreLocation

struct ContentView: View {

    @Environment(\.managedObjectContext)
    private var viewContext

    @FetchRequest(sortDescriptors:[])
	private var resultSet_CollectTime: FetchedResults<Entity_CollectTime>

	@FetchRequest(
		sortDescriptors: [NSSortDescriptor(keyPath: \Entity_SiDo.ctprvn_cd, ascending: true)])
	private var resultSet_SiDo: FetchedResults<Entity_SiDo>

	@FetchRequest(
		sortDescriptors: [NSSortDescriptor(keyPath: \Entity_SiDo.ctprvn_cd, ascending: true)])
	private var resultSet_SiDo_Name: FetchedResults<Entity_SiDo>

	@FetchRequest(
		sortDescriptors: [NSSortDescriptor(keyPath: \Entity_SiGunGu.sig_cd , ascending: true)])
	private var resultSet_SiGunGu: FetchedResults<Entity_SiGunGu>

	@State var isLocationAuth = false
	@State var isSearchLoading = false
	@State var isDownLoading = false
	@State var selectionSIDO = "0"
	@State var selectionSIGG = "0"
	@State var isVisibleSIGG = false
	@State var searchText:String = ""
	@State var beforeText:String = ""
	@State var selection: String?
	@State var isErrorLoad = false
	@State var isDelayView = false
	@State var administrativeSGG: [Administrative_SGG] = []
	@State var chkDelayView = [
		CheckDelayView.AllSiGunGu:false,
		CheckDelayView.EmptySearchKeyword:false,
		CheckDelayView.NotSeJong:false
	]

	let timeInterval:TimeInterval = 3.0
	let firstCode:String = "0"
	let frameWidthPicker:CGFloat = 160
	let frameHeightPicker:CGFloat = 140
	let frameWidthRoundedRectangle:CGFloat = 350
	let frameHeightRoundedRectangle:CGFloat = 400
	let frameWidthTextField:CGFloat = 200

	let frameWidthInstall = 200.0
	let frameHeightInstall = 160.0

	let backgroundImg =  "forest"
	let title = "Search Camping Site"
	let titleImage = "magnifyingglass"
	let searchFieldText = "검색어"
	let searchFieldImage = "rectangle.and.pencil.and.ellipsis"
	let searchButtonText = "검색"
	let searchButtonImage = "magnifyingglass"
	let navigationTag = "search"
	let titleCampingSitesView = "검색 결과"
	let titleContentView = "검색"
	let loadingText = "CampingSite Data DownLoading..."
	let weatherController = WeatherController.controller
	let vWorldController = VWorldController.controller
	let goCampingController = GoCampingController.controller

	var body: some View {

		NavigationView{

			ZStack{

				if self.isLocationAuth {
					VStack{
						ErrorLoadView.locationAuthMsg
						.padding(.top, 20)
						Spacer()
					}
				}

				if self.isErrorLoad {
					VStack{
						ErrorLoadView.errorMsg
						.padding(.top, 20)
						Spacer()
					}
				}

				if self.isDelayView{
					VStack{
						ErrorLoadView.delayMsg
						.padding(.top, 20)
						Spacer()
					}
				}

				if self.self.isDownLoading {
					VStack{
						ErrorLoadView.downLoadMsg
						.padding(.top, 20)
						Spacer()
					}
				}

				RoundedRectangle(cornerRadius: 8)
				.frame(width: self.frameWidthRoundedRectangle, height: self.frameHeightRoundedRectangle)
				.foregroundColor(Color.white.opacity(0.6))
				.background(Color.clear)
				.overlay {
					VStack(alignment:.center, spacing: 6) {
						Label(self.title, systemImage: self.titleImage)
						.labelStyle(.titleOnly)
						.font(.system(size: 28, weight: .bold, design:.default))
						.padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))

						WeatherView()
						.padding(2)
						.modifier(CardModifier(lineWidth: 1))

						TextField(text: $searchText) {
							Label(self.searchFieldText, systemImage: searchFieldImage)
						}
						.textFieldStyle(.roundedBorder)
						.frame(width: self.frameWidthTextField, alignment: .center)
						.modifier(CardModifier(lineWidth: 1, radius: 4))
						.overlay {
							if self.isSearchLoading {
								ProgressView()
								.scaleEffect(2)
							}
						}
						.overlay {
							if self.isDownLoading {
								ProgressView()
								.scaleEffect(2)
							}
						}
						.onChange(of: self.searchText) { newValue in
							if ( (self.beforeText.isEmpty && !newValue.isEmpty)
								|| (!self.beforeText.isEmpty && newValue.isEmpty) ){
								self.chkDelayView.updateValue( newValue.isEmpty, forKey: CheckDelayView.EmptySearchKeyword)
							}
							self.beforeText = newValue
						}

						Button {

							if  self.selectionSIDO.elementsEqual(self.firstCode) {

								if self.weatherController.locationService.authStatus == .authorizedWhenInUse
									|| self.weatherController.locationService.authStatus == .authorizedAlways {
									self.selection = self.navigationTag
									self.isSearchLoading = true
									UISelectionFeedbackGenerator().selectionChanged()
								} else {
									self.isLocationAuth = true
								}

							} else {
								self.selection = self.navigationTag
								self.isSearchLoading = true
								UISelectionFeedbackGenerator().selectionChanged()
							}



						} label: {
							Label {
								Text(self.searchButtonText)
								.font(.system(size: 20, weight: .bold, design: .rounded))
								.foregroundColor(.black)
							} icon: {
								Image(systemName: self.searchButtonImage)
								.foregroundColor(Color.blue)
							}.labelStyle(.titleOnly)
						}
						.buttonStyle(.bordered)
						.modifier(CardModifier(lineWidth: 1))
						.padding(.vertical,6)

						HStack(spacing:0){
							self.sidoPicker()
							if self.isVisibleSIGG  {
								self.siggPicker()
							}
						}.padding(.vertical)
						.modifier(CardModifier(lineWidth: 1))
					}
					.background(.clear)
				}

				NavigationLink(
					destination:
						CampingSitesView(param:self.makeParam())
						.navigationBarTitleDisplayMode(.inline)
						.navigationTitle(self.titleCampingSitesView),
					tag: self.navigationTag ,
					selection: $selection
				){ EmptyView() }

			}
			.background{
				Image(self.backgroundImg)
			}
			.onAppear() {
				self.startJob()
			}
			.onChange(of: self.isLocationAuth, perform: { newValue in
				if newValue {
					let _ = Timer.scheduledTimer(withTimeInterval: self.timeInterval, repeats: false) { timer in
						self.isLocationAuth = false
						timer.invalidate()
					}
				}
			})
			.onChange(of: self.isErrorLoad, perform: { newValue in
				if newValue {
					let _ = Timer.scheduledTimer(withTimeInterval: self.timeInterval, repeats: false) { timer in
						self.isErrorLoad = false
						timer.invalidate()
					}
				}
			})

			.onChange(of: self.chkDelayView, perform: { newValue in
				withAnimation(.default) {
					self.isDelayView =  newValue.values.filter({ value in
						value == false }).isEmpty

					if self.isDelayView {
						let _ = Timer.scheduledTimer(withTimeInterval: self.timeInterval, repeats: false) { timer in
							self.isDelayView = false
							timer.invalidate()
						}
					}
				}
			})
			.onChange(of: self.weatherController.locationService.authStatus, perform: { newValue in
				if newValue == .authorizedWhenInUse || newValue == .authorizedAlways {
					self.weatherController.locationService.getCurrentLocation { location in
						self.goCampingController.getNearCampSiteData(
							beforeTime: 0,
							viewContext: self.viewContext,
							coordinate: location.coordinate
						){ result, _ in
							self.isErrorLoad = !result
						}
					}
				}

			})


			.navigationBarHidden(true)
			.navigationBarTitleDisplayMode(.inline)
			.navigationTitle(self.titleContentView)


		}

    }
}

extension ContentView {

	enum CheckDelayView:String {
		case AllSiGunGu = "AllSiGunGu"
		case EmptySearchKeyword = "EmptySearchKeyword"
		case NotSeJong = "NotSeJong"
	}

}

extension ContentView {


	private func startJob(){
		self.isSearchLoading = false
		self.isErrorLoad = false
		self.searchText.removeAll()
		self.beforeText.removeAll()
		self.chkDelayView.updateValue(self.searchText.isEmpty, forKey: CheckDelayView.EmptySearchKeyword)

//		let beforeTime = self.resultSet_CollectTime.first?.nearsite ?? 0
//		let currentTime = trunc(Date().timeIntervalSince1970)
//		if (beforeTime + CollectTimeCollum.NEAR_SITE.interval) < currentTime {
			self.getData()
//		}
	}


	private func getData(){

		self.resultSet_CollectTime.first.map { item in

			DispatchQueue.global(qos: .userInitiated).async {
				self.vWorldController.getAdministrativeSiDoData(
					beforeTime: item.administrative,
					viewContext: self.viewContext
				){ result, _ in

					if !result {

						let dataSiDo:VWorldResponse = URLSessionService.load("SiDo.json")
						batchDelete(context:  self.viewContext, entityName: "Entity_SiDo") {
							dataSiDo.response?.result?.featureCollection.features.forEach {item in
								let valueSiDo = Administrative_SD(
										ctprvn_cd:item.properties.ctprvn_cd,
										ctp_kor_nm: item.properties.ctp_kor_nm,
										ctp_eng_nm: item.properties.ctp_eng_nm)

								valueSiDo.toEntity_SiDo(context: self.viewContext)
							}
						}

					}
					self.isErrorLoad =  !result
				}
			}

			DispatchQueue.global(qos: .userInitiated).async {
				self.vWorldController.getAdministrativeSiGunGuData(
					beforeTime: item.administrativesigungu,
					viewContext: self.viewContext
				){ result, _ in
					if !result {
						let dataSiGunGu:VWorldResponse = URLSessionService.load("SiGunGu.json")
						batchDelete(context:  self.viewContext, entityName: "Entity_SiGunGu") {
							dataSiGunGu.response?.result?.featureCollection.features.forEach {item in
								let valueSiGunGu = Administrative_SGG(
									full_nm: item.properties.full_nm,
									sig_cd:item.properties.sig_cd,
									sig_kor_nm: item.properties.sig_kor_nm,
									sig_eng_nm: item.properties.sig_eng_nm)

								valueSiGunGu.toEntity_SiGunGu(context: self.viewContext)
							}
						}
					}
					self.isErrorLoad =  !result
				}
			}


			DispatchQueue.global(qos: .background).async {
				self.isDownLoading = true
				self.goCampingController.getCampSiteData(
					beforeTime: item.allsite,
					viewContext: self.viewContext
				){ result, _ in
					self.isErrorLoad = !result
					self.isDownLoading = false
				}
			}

			DispatchQueue.global(qos: .userInitiated).async {

				if self.weatherController.locationService.authStatus == .authorizedWhenInUse
					|| self.weatherController.locationService.authStatus == .authorizedAlways {
					self.weatherController.locationService.getCurrentLocation { location in
						self.goCampingController.getNearCampSiteData(
							beforeTime: item.nearsite,
							viewContext: self.viewContext,
							coordinate: location.coordinate
						){ result, _ in
							self.isErrorLoad = !result
						}
					}
				}

			}

		}

	}


}


extension ContentView {


	private func makeParam() -> ItemListParam {

		if self.selectionSIDO.elementsEqual(self.firstCode) {
			return ItemListParam(sidoName: VWorldService.CURRENT.labelName, searchKeyword: searchText)
		} else {
			self.resultSet_SiDo_Name.nsPredicate = NSPredicate(format: "ctprvn_cd = %@", self.selectionSIDO )
			let sidoName = self.resultSet_SiDo_Name.first?.ctp_kor_nm ?? ""
			var sigunguName:String = ""
			if self.selectionSIGG.elementsEqual(self.firstCode) {
				sigunguName = VWorldService.SIGGF.labelName
			} else {
				self.resultSet_SiGunGu.nsPredicate = NSPredicate(format: "sig_cd = %@", self.selectionSIGG )
				sigunguName = self.resultSet_SiGunGu.first?.sig_kor_nm ?? ""
			}
			return ItemListParam(sidoName: sidoName, sigunguName: sigunguName, searchKeyword: searchText, sidoCode: self.selectionSIDO)
		}
	}

	private func sidoPicker() -> some View {

		return Picker(selection: $selectionSIDO, label:Text(VWorldService.SIDO.labelName)){
			Text(VWorldService.CURRENT.labelName).tag(self.firstCode)
			ForEach(self.resultSet_SiDo) { item in
				if let name = item.ctp_kor_nm, let code = item.ctprvn_cd {
					Text(name).tag(code)
				}
			}
		}.pickerStyle(WheelPickerStyle())
		.frame(width: self.frameWidthPicker, height: self.frameHeightPicker)
		.clipped()
		.onChange(of: self.selectionSIDO) { newValue in

			if newValue == self.firstCode {
				isVisibleSIGG = false
			} else {
				self.administrativeSGG.removeAll()
				var administrativeSGG: [Administrative_SGG] = []
				self.resultSet_SiGunGu.nsPredicate = NSPredicate(format: "sig_cd BEGINSWITH %@", newValue )
				self.resultSet_SiGunGu.nsSortDescriptors = [NSSortDescriptor(keyPath: \Entity_SiGunGu.sig_kor_nm , ascending: true)]
				self.resultSet_SiGunGu.forEach { item in
					administrativeSGG.append(item.toAdministrative_SGG())
				}
				self.administrativeSGG = administrativeSGG
				self.selectionSIGG = self.administrativeSGG.first?.sig_cd ?? self.firstCode
				self.isVisibleSIGG = true
			}

			self.chkDelayView.updateValue(!newValue.elementsEqual( MergeSiDoName.세종특별자치시.ctprvn_cd ), forKey: CheckDelayView.NotSeJong)

		}
	}

	private func siggPicker() -> some View {
		return Picker(selection: $selectionSIGG, label:Text(VWorldService.SIGG.labelName)){

			ForEach(self.administrativeSGG) { item in
				if let name = item.sig_kor_nm   , let code = item.sig_cd {
					Text(name).tag(code)
				}
			}
			Text(VWorldService.SIGGF.labelName).tag(self.firstCode)
		}
		.pickerStyle(WheelPickerStyle())
		.frame(width: self.frameWidthPicker, height: self.frameHeightPicker)
		.clipped()
		.onChange(of: self.selectionSIGG) { newValue in
			self.chkDelayView.updateValue(newValue.elementsEqual(self.firstCode), forKey: CheckDelayView.AllSiGunGu)
		}

	}

}


struct ContentViewNew_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
