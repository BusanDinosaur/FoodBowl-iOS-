//
//  StoreDetailViewModel.swift
//  FoodBowl
//
//  Created by COBY_PRO on 10/16/23.
//

import Combine
import UIKit

import CombineMoya
import Moya

final class StoreDetailViewModel: BaseViewModelType {
    
    // MARK: - property

    let providerReview = MoyaProvider<ReviewAPI>()
    let providerFollow = MoyaProvider<FollowAPI>()
    
    private var cancellable = Set<AnyCancellable>()
    
    private let pageSize: Int = 10
    private let size: Int = 15
    var storeId: Int
    var isFriend: Bool
    private var lastReviewId: Int?
    private var currentpageSize: Int?
    
    private let reviewsSubject = PassthroughSubject<[ReviewByStore], Error>()
    
    struct Input {
        let viewDidLoad: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let reviews: PassthroughSubject<[ReviewByStore], Error>
    }
    
    // MARK: - init

    init(storeId: Int, isFriend: Bool) {
        self.storeId = storeId
        self.isFriend = isFriend
    }
    
    // MARK: - Public - func
    
    func transform(from input: Input) -> Output {
        self.getReviewsPublisher()
        
        return Output(
            reviews: reviewsSubject
        )
    }
    
    // MARK: - network
    
    private func getReviewsPublisher() {
        let filter = isFriend ? "FRIEND" : "ALL"
        
        providerReview.requestPublisher(
            .getReviewsByStore(
                form: GetReviewByStoreRequest(storeId: storeId, filter: filter),
                lastReviewId: lastReviewId,
                pageSize: pageSize
            )
        )
        .sink { completion in
            switch completion {
            case let .failure(error):
                self.reviewsSubject.send(completion: .failure(error))
            case .finished:
                self.reviewsSubject.send(completion: .finished)
            }
        } receiveValue: { recievedValue in
            guard let responseData = try? recievedValue.map(ReviewByStoreResponse.self) else { return }
            self.reviewsSubject.send(responseData.storeReviewContentResponses)
        }
        .store(in : &cancellable)
    }
}
