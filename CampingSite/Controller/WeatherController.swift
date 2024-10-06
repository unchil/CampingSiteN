//
//  WeatherController.swift
//  campsite
//
//  Created by 여운칠 on 2022/09/22.
//

import Foundation
import CoreData
import CoreLocation
import SwiftUI

class WeatherController: ObservableObject {

	static let controller = WeatherController()

	let OpenWeatherSdkApiKey = "OpenWeatherSdkApiKey"
	let OpenWeatherURL = "https://api.openweathermap.org/data/2.5/weather"
	let locationService = LocationService.service
	let netQueryService = URLSessionService.service
	let timeoutInterval = TimeInterval(60)
	var completionHandler:((Bool, String)->())?

	@Published var weatherData: WeatherData = WeatherData.makeDefaultValue()

	private func getCurrentWeather(context: NSManagedObjectContext)  {

		switch self.locationService.authStatus {
			case .notDetermined, .restricted, .denied: do {
				if let completion = self.completionHandler {
					completion(true, CheckService.Weather.returnFuncName )
				}
			}
			case .authorizedAlways, .authorizedWhenInUse:
				do {
					self.locationService.getCurrentLocation { location in

						let urlString = self.getOpenWeatherURL(coordinate: location.coordinate)

						guard let url =  URL(string: urlString) else { return }

						var urlRequest = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: self.timeoutInterval)
						urlRequest.httpMethod = "GET"
						urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")

						self.netQueryService.sessionLoad(
							urlRequest: urlRequest,
							resultType: WeatherData.makeDefaultValue()
						){ result,error in

							if let _ = error,  let completion = self.completionHandler {
								completion(false, CheckService.Weather.returnFuncName)
							}

							if let result = result {

								batchDelete(context: context, entityName: "Entity_Current_Weather") {
									result.toEntity_Current_Weather(context: context)
								}

								if let completion = self.completionHandler {

									updateEntityCollectTime(
										context: context,
										collum: CollectTimeCollum.WEATHER ){
										completion(true, CheckService.Weather.returnFuncName )
									}
								}

							}

						}
					}

				}
			@unknown default: do {
				if let completion = self.completionHandler {
					completion(true, CheckService.Weather.returnFuncName )
				}
			}
		}



	}

	private func getDefaultParam(coordinate: CLLocationCoordinate2D) -> OpendWeatherDefaultParam {
		return OpendWeatherDefaultParam(
				appid: self.OpenWeatherSdkApiKey,
				units: "metric",
				lat: String(coordinate.latitude),
				lon: String(coordinate.longitude))
	}

	func getOpenWeatherURL(coordinate: CLLocationCoordinate2D) -> String {
		let defaultParam = getDefaultParam(coordinate: coordinate)
		let param:String = "?appid=" + defaultParam.appid
			+ "&units=" + defaultParam.units
			+ "&lat=" + defaultParam.lat
			+ "&lon=" + defaultParam.lon

		return self.OpenWeatherURL + param
	}



	func refreshWeather( beforeTime:Double,
			viewContext: NSManagedObjectContext,
			completion: @escaping ((Bool, String) -> (Void))) {

		self.completionHandler = completion
	
		let currentTime = trunc(Date().timeIntervalSince1970)

		if ( (beforeTime + CollectTimeCollum.WEATHER.interval) < currentTime ) {
			self.getCurrentWeather(context: viewContext)
		}else {
			completion(true, CheckService.Weather.returnFuncName )
		}

	}

}


