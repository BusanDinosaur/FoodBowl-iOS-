//
//  ProfileViewModel.swift
//  FoodBowl
//
//  Created by COBY_PRO on 2023/09/09.
//

import UIKit

import Moya

final class ProfileViewModel {
    var userProfile: MemberProfileResponse?

    private let provider = MoyaProvider<UserAPI>()

    func getProfile(id: Int) async {
        let response = await provider.request(.getMemberProfile(id: id))
        switch response {
        case .success(let result):
            guard let data = try? result.map(MemberProfileResponse.self) else { return }
            userProfile = data
        case .failure(let err):
            print(err.localizedDescription)
        }
    }

    func updateProfile(profile: UpdateProfileRequest) async {
        let response = await provider.request(.updateProfile(form: profile))
        switch response {
        case .success:
            if var currentUser = UserDefaultsManager.currentUser {
                currentUser.nickname = profile.nickname
                currentUser.introduction = profile.introduction
                UserDefaultsManager.currentUser = currentUser
            }
        case .failure(let err):
            print(err.localizedDescription)
        }
    }
}
