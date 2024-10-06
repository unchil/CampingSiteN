//
//  URLSessionService.swift
//  CampingSite
//
//  Created by 여운칠 on 2022/11/10.
//

import Foundation
import UIKit

enum CollectTimeCollum:String {
	case INSTALL = "install"
	case ADMINISTRATIVE = "administrative"
	case ADMINISTRATIVESIGUNGU = "administrativesigungu"
	case ALL_SITE = "allsite"
	case NEAR_SITE = "nearsite"
	case SITE_IMAGE = "siteimage"
	case WEATHER = "weather"

	// 86400 = 60 * 60 * 24
	var interval:Double {
		switch self {

			case .INSTALL:
				return -1
			case .ADMINISTRATIVE:
				return 86400 * 180  // 180 day
			case .ALL_SITE:
				return 86400 * 1  // 1 day
			case .NEAR_SITE:
				return 86400 / 24 / 4 // 15분
			case .SITE_IMAGE:
				return 86400
			case .WEATHER:
				return 86400 / 24  // 60분
			case .ADMINISTRATIVESIGUNGU:
				return 86400 * 180  // 180 day
		}
	}
}





class URLSessionService {

	static let service = URLSessionService()
	
	var session:URLSession?

	init(){
		self.session = URLSession(configuration: .default)
	}

	deinit{
		if self.session != nil {
			self.session = nil
		}
	}


	func sessionImageLoad( urlRequest:URLRequest, completion:@escaping (UIImage?, String?) -> ()) {

		self.session?.dataTask(with: urlRequest, completionHandler: { data, response, error in

			if let error = error {
				DispatchQueue.global(qos: .background).async {
					completion( nil, "sessionImageLoad dataTask error: \(error.localizedDescription) \n")
				}

			} else if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 {
				let result =  UIImage(data: data)
				DispatchQueue.global(qos: .background).async {
					completion( result, nil)
				}

			} else {
				 if let response = response as? HTTPURLResponse {
					DispatchQueue.global(qos: .background).async {
						completion( nil, "sessionImageLoad response error: \(response.description) \n")
					}
				 }
			}
		}).resume()

	}

	func sessionLoad<T:Decodable> (
			urlRequest:URLRequest,
			resultType:T ,
			completion:@escaping (T?, String?) -> ()) {

			self.session?.dataTask(with: urlRequest, completionHandler: { data, response, error in
				if let error = error {
					DispatchQueue.main.async {
						completion( nil, "sessionLoad dataTask error: \(error.localizedDescription) \n")
					}
				} else if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 {
					do {
						let result = try JSONDecoder().decode(T.self, from: data)
						DispatchQueue.main.async {
							completion( result, nil)
						}
					} catch let error as NSError {

						DispatchQueue.main.async {
							completion( nil, "sessionLoad JSONSerialization error:[ \(error.code) ]\(error.localizedDescription) \n")
						}
					}
				} else {
					 if let response = response as? HTTPURLResponse {
						DispatchQueue.main.async {
							completion( nil, "sessionLoad response error: \(response.description) \n")
						}
					 }
				}
			}).resume()

	}


	static func load<T: Decodable>(_ filename: String) -> T {

		let data: Data

		guard let file =  Bundle.main.url(forResource: filename, withExtension: nil)
		else {
			fatalError("Couldn't find \(filename) in main bundle.")
		}

		do {
			data = try Data(contentsOf: file)
		} catch {
			fatalError("Couldn't load \(filename) in main bundle:\n\(error)")
		}

		do{
			let decoder = JSONDecoder()
			return try decoder.decode(T.self, from: data)
		} catch {
			fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
		}

	}

}
