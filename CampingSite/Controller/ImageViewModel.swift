//
//  ImageController.swift
//  CampingSite
//
//  Created by 여운칠 on 2022/11/17.
//

import Foundation
import SwiftUI

struct ImageViewModel {

	let netQueryService = URLSessionService.service

	let timeoutInterval = TimeInterval(20)

	func getImage(url:URL,  completion: @escaping (UIImage?, String?) -> ()? ){

		var urlRequest = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval:self.timeoutInterval)
		urlRequest.httpMethod = "GET"
		urlRequest.addValue("image/jpeg", forHTTPHeaderField: "Content-Type")

		self.netQueryService.sessionImageLoad( urlRequest: urlRequest){ result , error in

			completion(result, error)
		}

	}
	
}
