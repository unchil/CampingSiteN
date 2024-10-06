//
//  VWorldController.swift
//  campsite
//
//  Created by 여운칠 on 2022/09/22.
//

import Foundation
import CoreData
import SwiftUI
import RegexBuilder

class VWorldController: ObservableObject {

	static let controller = VWorldController()

	//공간정보오픈플랫폼 2D 데이터API 2.0
	//인증키 정보
	//만료일		2022-12-16  [ 인증키 연장 횟수 : 총 3회 중 0회 진행 ]
	//인증키 상태		개발
	let VWorldApiKey = "VWorldApiKey"
	let VWorldEndPoint = "https://api.vworld.kr/req/data"

	let netQueryService = URLSessionService.service
	let timeoutInterval = TimeInterval(60)

	var completionHandler: ((Bool,String) -> (Void))?
	var completionHandlerSiDo: ((Bool,String) -> (Void))?
	var completionHandlerSiGunGu: ((Bool,String) -> (Void))?

	func getDefaultParam(service:VWorldService) -> VWorldDefaultParam {

		let reqData = service.rawValue == VWorldService.SIGGF.rawValue ? VWorldService.SIGG.rawValue : service.rawValue

		return VWorldDefaultParam(
					request: "getfeature",
					key: self.VWorldApiKey,
					data: reqData,
					geomFilter: "BOX(13663271.680031825,3894007.9689600193,14817776.555251127,4688953.0631258525)",
					size: 1000,
					geometry: false,
					crs: "EPSG:3857")
	}

	func getVWorldURL(service:VWorldService, code:String?) -> String {

		let defaultParam = getDefaultParam(service:service)

		var param:String = "?key=" + defaultParam.key
			+ "&request=" + defaultParam.request
			+ "&data=" + defaultParam.data
			+ "&geomfilter=" + defaultParam.geomFilter
			+ "&size=" + String(defaultParam.size)
			+ "&geometry=" + ( defaultParam.geometry ? "true" : "false" )
			+ "&crs=" + defaultParam.crs

		switch service {
			case .CURRENT, .SIDO , .SIGGF: break
			case .SIGG : do {
				guard let upCode = code else { break }
				param += "&attrFilter=" + service.filterCodeName + ":LIKE:" + upCode
			}
		}

		 return self.VWorldEndPoint + param
	}
/*
	func getVWorldData(context: NSManagedObjectContext, service:VWorldService, code:String?) {


		let urlString:String = getVWorldURL(service: service, code: code)

		guard let url =  URL(string: urlString) else { return }

		var urlRequest = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: self.timeoutInterval)
		urlRequest.httpMethod = "GET"
		urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")


		self.netQueryService.sessionLoad(
			urlRequest:urlRequest,
			resultType: VWorldResponse()
		){ result,error in

			if let _ = error,  let completion = self.completionHandler, service == VWorldService.SIGGF {
				completion(false,  CheckService.Administrative.returnFuncName)
			}

			if let result = result {

				switch service {
					case .CURRENT, .SIGG: break
					case .SIDO:
						batchDelete(context: context, entityName: "Entity_SiDo") {}
					case .SIGGF:
						batchDelete(context: context, entityName: "Entity_SiGunGu") {}
				}

				result.response?.result?.featureCollection.features.forEach {item in

					switch service {

						case .CURRENT, .SIGG: break
						case .SIDO : do {
							Administrative_SD(
									ctprvn_cd:item.properties.ctprvn_cd,
									ctp_kor_nm: item.properties.ctp_kor_nm,
									ctp_eng_nm: item.properties.ctp_eng_nm)
							.toEntity_SiDo(context: context)
						}
						case .SIGGF: do {

							Administrative_SGG(
								full_nm: item.properties.full_nm,
								sig_cd:item.properties.sig_cd,
								sig_kor_nm: item.properties.sig_kor_nm,
								sig_eng_nm: item.properties.sig_eng_nm)
							.toEntity_SiGunGu(context: context)
						}
					}
				}


				if let completion = self.completionHandler, service == VWorldService.SIGGF {
					updateEntityCollectTime( context: context,
											collum: CollectTimeCollum.ADMINISTRATIVE ){
						completion(true,  CheckService.Administrative.returnFuncName)
					}
				}
			}

		}

	}
*/

func getVWorldSiDoData(context: NSManagedObjectContext, service:VWorldService, code:String?) {

		let urlString:String = getVWorldURL(service: service, code: code)

		guard let url =  URL(string: urlString) else { return }

		var urlRequest = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: self.timeoutInterval)
		urlRequest.httpMethod = "GET"
		urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")


		self.netQueryService.sessionLoad(
			urlRequest:urlRequest,
			resultType: VWorldResponse()
		){ result,error in

			if let _ = error,  let completion = self.completionHandlerSiDo {
				completion(false,  CheckService.Administrative.returnFuncName)
			}

			if let result = result {

				batchDelete(context: context, entityName: "Entity_SiDo") {
					result.response?.result?.featureCollection.features.forEach {item in
						Administrative_SD(
								ctprvn_cd:item.properties.ctprvn_cd,
								ctp_kor_nm: item.properties.ctp_kor_nm,
								ctp_eng_nm: item.properties.ctp_eng_nm)
						.toEntity_SiDo(context: context)
					}
				}
			}

			if let completion = self.completionHandlerSiDo {
				updateEntityCollectTime( context: context,
										collum: CollectTimeCollum.ADMINISTRATIVE ){
					completion(true,  CheckService.Administrative.returnFuncName)
				}
			}
		}

	}

	func getVWorldSiGunGuData(context: NSManagedObjectContext, service:VWorldService, code:String?) {


		let urlString:String = getVWorldURL(service: service, code: code)

		guard let url =  URL(string: urlString) else { return }

		var urlRequest = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: self.timeoutInterval)
		urlRequest.httpMethod = "GET"
		urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")


		self.netQueryService.sessionLoad(
			urlRequest:urlRequest,
			resultType: VWorldResponse()
		){ result,error in

			if let _ = error,  let completion = self.completionHandlerSiGunGu {
				completion(false,  CheckService.Administrative.returnFuncName)
			}

			if let result = result {

				batchDelete(context: context, entityName: "Entity_SiGunGu") {
					result.response?.result?.featureCollection.features.forEach {item in
						Administrative_SGG(
							full_nm: item.properties.full_nm,
							sig_cd:item.properties.sig_cd,
							sig_kor_nm: item.properties.sig_kor_nm,
							sig_eng_nm: item.properties.sig_eng_nm)
						.toEntity_SiGunGu(context: context)
					}
				}

				if let completion = self.completionHandlerSiGunGu{
					updateEntityCollectTime( context: context,
											collum: CollectTimeCollum.ADMINISTRATIVESIGUNGU ){
						completion(true,  CheckService.Administrative.returnFuncName)
					}
				}
			}

		}

	}

	func getAdministrativeData( beforeTime:Double,
								viewContext: NSManagedObjectContext,
								completion: @escaping (Bool, String) -> (Void) )   {

		self.completionHandler = completion

		let currentTime = trunc(Date().timeIntervalSince1970)

		if ( (beforeTime + CollectTimeCollum.ADMINISTRATIVE.interval) < currentTime ) {

			//self.getVWorldData(context:viewContext, service: VWorldService.SIDO, code:nil )
			//self.getVWorldData(context:viewContext, service: VWorldService.SIGGF, code:nil )
			//completion(false, CheckService.Administrative.returnFuncName)

		} else {
			completion(true, CheckService.Administrative.returnFuncName)
		}
	}

	func getAdministrativeSiDoData( beforeTime:Double,
								viewContext: NSManagedObjectContext,
								completion: @escaping (Bool, String) -> (Void) )   {

		self.completionHandlerSiDo = completion

		let currentTime = trunc(Date().timeIntervalSince1970)

		if ( (beforeTime + CollectTimeCollum.ADMINISTRATIVE.interval) < currentTime ) {
			self.getVWorldSiDoData(context:viewContext, service: VWorldService.SIDO, code:nil )
		} else {
			completion(true, CheckService.Administrative.returnFuncName)
		}
	}

	func getAdministrativeSiGunGuData( beforeTime:Double,
								viewContext: NSManagedObjectContext,
								completion: @escaping (Bool, String) -> (Void) )   {

		self.completionHandlerSiGunGu = completion

		let currentTime = trunc(Date().timeIntervalSince1970)

		if ( (beforeTime + CollectTimeCollum.ADMINISTRATIVESIGUNGU.interval) < currentTime ) {
			self.getVWorldSiGunGuData(context:viewContext, service: VWorldService.SIGGF, code:nil )
		} else {
			completion(true, CheckService.Administrative.returnFuncName)
		}
	}


}
