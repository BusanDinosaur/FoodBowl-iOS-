//
//  OnboardingViewController.swift
//  FoodBowl
//
//  Created by COBY_PRO on 2023/01/23.
//

import AuthenticationServices
import UIKit

import SnapKit
import Then

final class OnboardingViewController: BaseViewController {
    private var viewModel = SignInViewModel()

    private var nonce: String {
        @Configurations(key: ConfigurationsKey.nonce, defaultValue: "")
        var nonce: String
        return nonce
    }

    // MARK: - property
    private let titleLabel = UILabel().then {
        $0.font = .font(.regular, ofSize: 50)
        $0.textColor = .mainTextColor
        $0.text = "FoodBowl"
    }

    private let subTitleLabel = UILabel().then {
        $0.font = .font(.regular, ofSize: 30)
        $0.textColor = .mainTextColor
        $0.text = "Just Do Eat"
    }

    private let guideLabel = UILabel().then {
        $0.font = UIFont.preferredFont(forTextStyle: .title3, weight: .medium)
        $0.textColor = .mainTextColor
        $0.text = "친구들과 함께 만들어가는 맛집지도"
    }

    private lazy var appleLoginButton = ASAuthorizationAppleIDButton(
        type: .signIn,
        style: traitCollection.userInterfaceStyle == .dark ? .white : .black
    ).then {
        let action = UIAction { [weak self] _ in
            self?.appleSignIn()
        }
        $0.addAction(action, for: .touchUpInside)
        $0.cornerRadius = 30
    }

    // MARK: - life cycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }

    override func setupLayout() {
        view.addSubviews(titleLabel, subTitleLabel, guideLabel, appleLoginButton)

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(100)
            $0.centerX.equalToSuperview()
        }

        subTitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(40)
            $0.centerX.equalToSuperview()
        }

        guideLabel.snp.makeConstraints {
            $0.top.equalTo(subTitleLabel.snp.bottom).offset(100)
            $0.centerX.equalToSuperview()
        }

        appleLoginButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(BaseSize.horizantalPadding)
            $0.bottom.equalToSuperview().inset(BaseSize.bottomPadding)
            $0.height.equalTo(60)
        }
    }

    override func configureUI() {
        view.backgroundColor = .mainBackgroundColor
    }

    private func appleSignIn() {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()

        request.requestedScopes = [.fullName, .email]
        request.nonce = nonce.sha256

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
}

extension OnboardingViewController: ASAuthorizationControllerDelegate {
    func authorizationController(
        controller _: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let userIdentifier = appleIDCredential.user
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            appleIDProvider.getCredentialState(forUserID: userIdentifier) { credentialState, _ in
                switch credentialState {
                case .authorized:
                    // The Apple ID credential is valid. Show Home UI Here
                    guard let token = appleIDCredential.identityToken else { return }
                    guard let tokenToString = String(data: token, encoding: .utf8) else { return }

                    Task {
                        await self.viewModel.signIn(appleToken: tokenToString)
                        await self.viewModel.getMyProfile()
                    }

                    DispatchQueue.main.async {
                        let tabbarViewController = UINavigationController(rootViewController: TabBarController())
                        tabbarViewController.modalPresentationStyle = .fullScreen
                        tabbarViewController.modalTransitionStyle = .crossDissolve
                        self.present(tabbarViewController, animated: true)
                    }
                case .revoked:
                    // The Apple ID credential is revoked. Show SignIn UI Here.
                    break
                case .notFound:
                    // No credential was found. Show SignIn UI Here.
                    break
                default:
                    break
                }
            }
        }
    }

    func authorizationController(controller _: ASAuthorizationController, didCompleteWithError _: Error) {}
}

extension OnboardingViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for _: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
}
