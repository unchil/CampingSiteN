//
//  GoCampingController.swift
//  campsite
//
//  Created by 여운칠 on 2022/09/24.
//
import SwiftUI
import Foundation
import CoreData
import CoreLocation

class GoCampingController: ObservableObject{

	static let controller = GoCampingController()

	let GoCampingApiKey = "GoCampingApiKey"
	let GoCampingEndPoint = "https://apis.data.go.kr/B551011/GoCamping"

	let netQueryService = URLSessionService.service
	let locationService = LocationService.service
	let nearMaxRadius = "15000"  // 반경 15Km
	let timeoutInterval = TimeInterval(60)

	@Published var currentCampSite:CampingSiteData = CampingSiteData.makeDefaultValue()
	@Published var imageUrlPathList:[URL] = []
	@Published var campingSiteList:[CampingSiteData] = []
	@Published var returnImageUrlPathList:Bool = false

	var completionHandler:((Bool, String)->())?
	var completionHandlerNear:((Bool, String)->())?

	func getCampSiteData( beforeTime:Double,
			viewContext: NSManagedObjectContext,
			completion: @escaping (Bool, String) -> () ){

		self.completionHandler = completion

		let currentTime = trunc(Date().timeIntervalSince1970)

		if ( ( beforeTime + CollectTimeCollum.ALL_SITE.interval) < currentTime ) {
			self.getGoCampingData(context: viewContext, service: GoCampingService.DEFAULT)
		} else {
			completion(true, CheckService.CampSite.returnFuncName)
		}
	}

	func getNearCampSiteData(beforeTime:Double,
			viewContext: NSManagedObjectContext,
			coordinate:CLLocationCoordinate2D,
			completion: @escaping (Bool,String) -> ()) {
			
		self.completionHandlerNear = completion

		let currentTime = trunc(Date().timeIntervalSince1970)
		

		if ( ( beforeTime + CollectTimeCollum.NEAR_SITE.interval) < currentTime ) {
			self.getGoCampingData(
					context: viewContext,
					service: GoCampingService.LOCATION,
					mapX: String(coordinate.longitude),
					mapY: String(coordinate.latitude),
					radius:  self.nearMaxRadius)
		} else {
			completion(true, CheckService.NearCampSite.returnFuncName)
		}
	}

	func getDefaultParam() -> GoCampingDefaultParam {
		return GoCampingDefaultParam (
				numOfRows: 10000,
				pageNo: 1,
				MobileOS: "IOS",
				MobileApp: "campsite",
				serviceKey: self.GoCampingApiKey ,
				_type: "json")
	}

	func getGoCampingURL(
					service:GoCampingService,
					mapX:String? = nil,
					mapY:String? = nil,
					radius:String? = nil,
					keyword:String? = nil,
					contentId:String? = nil,
					syncStatus:String? = nil,
					syncModTime:String? = nil) -> String {

		let defaultParam = getDefaultParam()

		var param:String = self.GoCampingEndPoint
			+ service.rawValue
			+ "?serviceKey=" + defaultParam.serviceKey
			+ "&numOfRows=" + String(defaultParam.numOfRows)
			+ "&pageNo=" + String(defaultParam.pageNo)
			+ "&MobileOS=" + defaultParam.MobileOS
			+ "&MobileApp=" + defaultParam.MobileApp
			+ "&_type=" + defaultParam._type

		switch service {
			case .LOCATION :  do {
			// (*) 경도 : GPS X좌표(WGS84 경도 좌표),  위도 : GPS Y좌표(WGS84 위도 좌표), 거리 반경 : 거리 반경(단위:m) ,Max값 20000m=20Km
				guard let x = mapX, let y = mapY, let r = radius else { break }
				param += "&mapX=" + x + "&mapY=" + y + "&radius=" + r
			}
			case .SYNC : do {
			// 컨텐츠상태 : (A=신규,U=수정,D=삭제) , 수정일 : 컨텐츠변경일자 (수정년도,수정년월,수정년월일 입력)
				guard let status = syncStatus, let modTime = syncModTime else { break }
				param += "&syncStatus=" + status + "&syncModTime=" + modTime
			}
			case .SEARCH : do {
			// (*) 요청 키워드 : (인코딩 필요)
				guard let text = keyword else { break }
				param += "&keyword=" + text
			}
			case .IMAGE : do {
			// (*) 콘텐츠ID
				guard let id = contentId else { break }
				param += "&contentId=" + id
			}
			case .DEFAULT:
				break
		}

		return  param

	}

	func getGoCampingData(context: NSManagedObjectContext,
					service:GoCampingService,
					mapX:String? = nil,
					mapY:String? = nil,
					radius:String? = nil,
					keyword:String? = nil,
					contentId:String? = nil,
					syncStatus:String? = nil,
					syncModTime:String? = nil)  {

		var urlString:String = ""

		switch service {

			case .DEFAULT: do {
				urlString = getGoCampingURL(service: service)
			}
			case .LOCATION: do {
				if let mapX = mapX, let mapY = mapY, let radius = radius {
					urlString = getGoCampingURL(service: service, mapX:mapX, mapY:mapY, radius: radius)
				}
			}
			case .SEARCH:do {
				if let keyword = keyword {
					urlString = getGoCampingURL(service: service, keyword: keyword)
				}
			}
			case .SYNC:do {
				if let syncStatus = syncStatus, let syncModTime = syncModTime {
					urlString = getGoCampingURL(service: service, syncStatus: syncStatus, syncModTime: syncModTime)
				}
			}
			case .IMAGE:do {
				if let contentId = contentId {
					urlString = getGoCampingURL(service: service, contentId: contentId)
				}
			}
		}



		guard let url =  URL(string: urlString) else { return }

		var urlRequest = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: self.timeoutInterval)
		urlRequest.httpMethod = "GET"
		urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")

		switch service {
			case .DEFAULT, .LOCATION : do {
				self.getCampSiteList(context: context, service:service, urlRequest: urlRequest )
			}
			case .IMAGE, .SEARCH, .SYNC :break
		}

	}


	private func getCampSiteList(context: NSManagedObjectContext, service:GoCampingService,urlRequest:URLRequest){

		self.netQueryService.sessionLoad(
			urlRequest: urlRequest,
			resultType: GoCampingResponse()
		){ result,error in

			if let _ = error {

				switch service {
					case .DEFAULT: do{
						if let completion = self.completionHandler {
							completion(false, #function + ":" + service.rawValue)
						}
					}
					case .LOCATION: do{
						if let completion = self.completionHandlerNear {
							completion(false, #function + ":" + service.rawValue)
						}
					}
					case .SEARCH, .IMAGE, .SYNC: break
				}

			}

			if let result = result {

				let responseStatus = GoCampingRecvHeader.responseStatus.first { status in
					status.rawValue == result.response?.header.resultCode
				} ?? GoCampingResponseStatus.UNSIGNED_CALL_ERROR

				switch responseStatus {

					case	.INVALID_REQUEST_PARAMETER_ERROR,
							.NO_MANDATORY_REQUEST_PARAMETERS_ERROR,
							.TEMPORARILY_DISABLE_THE_SERVICEKEY_ERROR,
							.UNSIGNED_CALL_ERROR,
							.DB_ERROR,
							.NODATA_ERROR,
							.SERVICETIMEOUT_ERROR,
							.SUCCESS,
							.NORMAL_CODE : break

					case .OK: do {

						switch service {

							case .DEFAULT: do {

								batchDelete(context: context, entityName: "Entity_Camp_Site") {
									result.response?.body.items.item.forEach { goCampingRecvItem in
										goCampingRecvItem.toEntity_Camp_Site(context: context)
									}
								}

								if let completion = self.completionHandler {

									updateEntityCollectTime(
										context: context,
										collum: CollectTimeCollum.ALL_SITE ){
										completion(true, CheckService.CampSite.returnFuncName)
									}
								}

							}
							case .LOCATION: do {

								batchDelete(context: context, entityName: "Entity_Camp_Site_Near") {
									result.response?.body.items.item.forEach { goCampingRecvItem in
										goCampingRecvItem.toEntity_Camp_Site_Near(context: context)
									}
								}

								if let completion = self.completionHandlerNear {

									updateEntityCollectTime(
										context: context,
										collum: CollectTimeCollum.NEAR_SITE ){
										completion(true, CheckService.NearCampSite.returnFuncName)
									}
								}

							}

							case .SEARCH, .SYNC, .IMAGE: break
						}
					}
				}

			}

		}

	}


	func getCampSiteImageList( context: NSManagedObjectContext, completion: @escaping (Bool) -> ()?  )  {

		let urlString = getGoCampingURL(service: GoCampingService.IMAGE, contentId: self.currentCampSite.contentId)

		guard let url =  URL(string: urlString) else { return }

		var urlRequest = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: self.timeoutInterval)
		urlRequest.httpMethod = "GET"
		urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")


		self.netQueryService.sessionLoad(
			urlRequest: urlRequest,
			resultType: GoCampingResponseImage()){ result,error in

			if let err = error {
				if err.contains(" 4864 ") {
					completion(true)
				}else {
					completion(false)
				}
			}

			if let result = result {

				let resultCode = result.response?.header.resultCode
				let responseStatus:GoCampingResponseStatus = GoCampingRecvHeader.responseStatus.first { status in
					status.rawValue == resultCode
				} ?? GoCampingResponseStatus.UNSIGNED_CALL_ERROR

				switch responseStatus {
					case	.INVALID_REQUEST_PARAMETER_ERROR,
							.NO_MANDATORY_REQUEST_PARAMETERS_ERROR,
							.TEMPORARILY_DISABLE_THE_SERVICEKEY_ERROR,
							.UNSIGNED_CALL_ERROR,
							.DB_ERROR,
							.NODATA_ERROR,
							.SERVICETIMEOUT_ERROR: break
					case .SUCCESS, .NORMAL_CODE: break
					case .OK: do {

						let ret = result.response?.body.items?.item ?? []

						batchDelete(context: context, entityName: "Entity_Site_Image") {
							ret.forEach { item in
								item.toEntity_Site_Image(context: context)
							}
						}
					}
				}
				completion(true)
			}
		}

	}


}
