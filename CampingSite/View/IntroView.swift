//
//  IntroView.swift
//  CampingSite
//
//  Created by 여운칠 on 2022/10/22.
//

import SwiftUI

import CoreLocation

struct IntroView: View {

    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(entity: Entity_CollectTime.entity(), sortDescriptors: [])
    private var resutlSet_CollectTime: FetchedResults<Entity_CollectTime>

	let weatherController = WeatherController.controller
	let vWorldController = VWorldController.controller
	let goCampingController = GoCampingController.controller

	@State private var selected:TagName?
	@State var location:CLLocation?
	@State var chkService = [
		CheckService.Administrative:false,
		CheckService.NearCampSite:false,
		CheckService.CampSite:false
	]
	@State var progressAmount : Double = 0.0
	@State var installAmount: Double = 100

	let backgroundImg = "forest"
	let loadingText = ""
	let frameWidthInstall = 200.0
	let frameHeightInstall = 120.0
	let frameWidthError = 300.0
	let frameHeightError = 200.0

    var body: some View {

		NavigationView{

			ZStack{

				if let contentTag = self.selected {

					switch contentTag {
						case .INSTALL : do {
							RoundedRectangle(cornerRadius: 8)
							.foregroundColor(.clear.opacity(0.6))
							.frame(width: self.frameWidthInstall, height: self.frameHeightInstall)

							.overlay {

								VStack{
									Text(self.loadingText)
									.font(.system(size: 24, weight: .bold, design: .serif))

									ProgressView()
									.scaleEffect(2)
								}


/*
								VStack{
									ProgressView()
									.scaleEffect(2)

									ProgressView(self.loadingText, value: self.progressAmount, total: self.installAmount )
									.padding()
									.frame(width: self.frameWidthInstall )
								}
*/
							}
						}
						case .ERROR : do {
							RoundedRectangle(cornerRadius: 8)
							.foregroundColor(.white.opacity(0.6))
							.frame(width: self.frameWidthError, height: self.frameHeightError)
							.overlay {
								ErrorLoadView(isErrorLoad: .constant(true),
												errorCallerView: "\(IntroView.self)",
												isDescPage: .constant(false) )
							}
						}
						case .NAVIGATION : do {
							NavigationLink(
								destination:
									ContentView()
									.navigationBarHidden(true)
									.navigationBarTitleDisplayMode(.inline)
									.environment(\.managedObjectContext, self.viewContext),

								tag: TagName.NAVIGATION,
								selection: self.$selected ){ EmptyView() }
						}

					}

				}
			}
			.background(content: {
				Image(self.backgroundImg)
			})
			.onAppear{
				self.selected = TagName.INSTALL

				let isInstall = ( self.resutlSet_CollectTime.first?.install ?? 0 ) == 0 ? true : false

				if isInstall {
					DispatchQueue.global(qos: .background).async {
						self.updateInstallTime()
					}
				} else {
					self.selected = TagName.NAVIGATION
				}
			}
			.onChange(of: self.chkService, perform: { newChkService in

				self.progressAmount += ( 1/Double(self.chkService.count) * 100 )

				let result =  newChkService.values.filter({ value in
					value == false }).isEmpty

				if result {
					self.updateInstallTime()
				}

			})
			.navigationBarHidden(true)
			.navigationBarTitleDisplayMode(.inline)
			.navigationTitle("Intro")

		}

    }
}

extension IntroView {

	enum TagName:String {
		case INSTALL = "install"
		case NAVIGATION = "navigation"
		case ERROR = "error"
	}
	
}



extension IntroView {

	func startJob()  {

		let installTime:Double = 0

		self.vWorldController.getAdministrativeData(
			beforeTime: installTime,
			viewContext: self.viewContext
		){ result, name in
			self.resultProcess(result: result, funcName:name)
		}



		self.goCampingController.getCampSiteData(
			beforeTime: installTime,
			viewContext: self.viewContext
		){ result, name in
			self.resultProcess(result: result, funcName:name)
		}

		DispatchQueue.global(qos: .background).async {
			self.weatherController.locationService.getCurrentLocation { location in
				self.goCampingController.getNearCampSiteData(
					beforeTime: installTime,
					viewContext: self.viewContext,
					coordinate: location.coordinate
				){ result, name in
					self.resultProcess(result: result, funcName:name)
				}
			}
		}

	}

	func resultProcess(result:Bool, funcName:String) {
		 if result {
			switch funcName {
				case CheckService.Administrative.returnFuncName:
					self.chkService.updateValue(true, forKey: CheckService.Administrative)
				case CheckService.CampSite.returnFuncName:
					self.chkService.updateValue(true, forKey: CheckService.CampSite)
				case CheckService.NearCampSite.returnFuncName:
					self.chkService.updateValue(true, forKey: CheckService.NearCampSite)
				default:
					self.selected = TagName.ERROR
			}
		} else {
			self.selected = TagName.ERROR
		}
	}


	func updateInstallTime() {
		updateEntityCollectTime(
			context: viewContext,
			collum: CollectTimeCollum.INSTALL ){
			self.selected = TagName.NAVIGATION
		}
	}

}

struct IntroView_Previews: PreviewProvider {
    static var previews: some View {
        IntroView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
