//
//  ReviewDetailRepositoryImpl.swift
//  FoodBowl
//
//  Created by Coby on 1/24/24.
//

import Foundation

import Moya

final class ReviewDetailRepositoryImpl: ReviewDetailRepository {

    private let provider = MoyaProvider<ServiceAPI>()
    
    func getReview(request: GetReviewRequestDTO) async throws -> ReviewItemDTO {
        let response = await provider.request(.getReview(request: request))
        return try response.decode()
    }
}
