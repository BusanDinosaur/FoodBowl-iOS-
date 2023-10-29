//
//  FeedCollectionViewCell.swift
//  FoodBowl
//
//  Created by COBY_PRO on 2022/12/23.
//

import Combine
import UIKit

import SnapKit
import Then

final class FeedCollectionViewCell: UICollectionViewCell, BaseViewType {
    
    // MARK: - ui component
    
    let userInfoView = UserInfoView()
    lazy var commentLabel = UILabel().then {
        $0.font = UIFont.preferredFont(forTextStyle: .subheadline, weight: .light)
        $0.textColor = .mainTextColor
        $0.numberOfLines = 0
    }
    let photoListView = PhotoListView()
    let storeInfoView = StoreInfoView()
    
    // MARK: - property
    
    let userButtonDidTapPublisher: PassthroughSubject<Void, Never> = PassthroughSubject()
    let optionButtonDidTapPublisher: PassthroughSubject<Void, Never> = PassthroughSubject()
    let storeButtonDidTapPublisher: PassthroughSubject<Void, Never> = PassthroughSubject()
    let bookmarkButtonDidTapPublisher: PassthroughSubject<Void, Never> = PassthroughSubject()
    
    // MARK: - init

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.baseInit()
        self.setupAction()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupLayout() {
        contentView.addSubviews(userInfoView, commentLabel, photoListView, storeInfoView)
        
        userInfoView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(64)
        }
        
        commentLabel.snp.makeConstraints {
            $0.top.equalTo(userInfoView.snp.bottom)
            $0.leading.trailing.equalToSuperview().inset(SizeLiteral.horizantalPadding)
            $0.bottom.equalTo(photoListView.snp.top).offset(-10)
        }
        
        photoListView.snp.makeConstraints {
            $0.top.equalTo(commentLabel.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(100)
        }
        
        storeInfoView.snp.makeConstraints {
            $0.top.equalTo(photoListView.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(SizeLiteral.horizantalPadding)
            $0.bottom.equalToSuperview().inset(20)
            $0.height.equalTo(54)
        }
    }
    
    func configureUI() {
        self.backgroundColor = .mainBackgroundColor
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes)
    -> UICollectionViewLayoutAttributes {
        super.preferredLayoutAttributesFitting(layoutAttributes)
        
        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 0)
        
        layoutAttributes.frame.size = contentView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        return layoutAttributes
    }
    
    // MARK: - func
    
    private func setupAction() {
        let userButtonTapAction = UIAction { [weak self] _ in
            self?.userButtonDidTapPublisher.send()
        }
        self.userInfoView.userImageButton.addAction(userButtonTapAction, for: .touchUpInside)
        self.userInfoView.userNameButton.addAction(userButtonTapAction, for: .touchUpInside)
        
        let optionButtonTapAction = UIAction { [weak self] _ in
            self?.optionButtonDidTapPublisher.send()
        }
        self.userInfoView.optionButton.addAction(optionButtonTapAction, for: .touchUpInside)
        
        let storeButtonTapAction = UIAction { [weak self] _ in
            self?.storeButtonDidTapPublisher.send()
        }
        self.storeInfoView.storeNameButton.addAction(storeButtonTapAction, for: .touchUpInside)
        
        let bookmarkButtonTapAction = UIAction { [weak self] _ in
            self?.bookmarkButtonDidTapPublisher.send()
        }
        self.storeInfoView.bookmarkButton.addAction(bookmarkButtonTapAction, for: .touchUpInside)
    }
}

// MARK: - Public - func
extension FeedCollectionViewCell {    
    func configureCell(_ data: Review) {
        let writer = data.writer
        let store = data.store
        let review = data.review
        
        self.userInfoView.comfigureUser(writer)
        self.storeInfoView.configureStore(store)
        self.commentLabel.text = review.content
        self.photoListView.photos = review.imagePaths
        
        if review.imagePaths.isEmpty {
            self.photoListView.isHidden = true
            
            self.storeInfoView.snp.remakeConstraints {
                $0.top.equalTo(self.commentLabel.snp.bottom).offset(10)
                $0.leading.trailing.equalToSuperview().inset(SizeLiteral.horizantalPadding)
                $0.bottom.equalToSuperview().inset(14)
                $0.height.equalTo(54)
            }
        } else {
            self.photoListView.isHidden = false
            self.storeInfoView.snp.remakeConstraints {
                $0.top.equalTo(self.photoListView.snp.bottom).offset(10)
                $0.leading.trailing.equalToSuperview().inset(SizeLiteral.horizantalPadding)
                $0.bottom.equalToSuperview().inset(14)
                $0.height.equalTo(54)
            }
        }
    }
}
