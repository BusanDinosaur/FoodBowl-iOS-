//
//  FilterButton.swift
//  FoodBowl
//
//  Created by COBY_PRO on 2023/09/16.
//

import UIKit

final class FilterButton: UIButton {
    // MARK: - init
    override init(frame _: CGRect) {
        super.init(frame: .init(origin: .zero, size: .init(width: 30, height: 30)))
        configureUI()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - life cycle
    private func configureUI() {
        setImage(ImageLiteral.btnFilter.resize(to: CGSize(width: 20, height: 20)), for: .normal)
        tintColor = .mainText
    }
}
