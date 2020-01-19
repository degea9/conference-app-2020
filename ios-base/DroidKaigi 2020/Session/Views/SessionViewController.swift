//
//  SessionViewController.swift
//  DroidKaigi 2020
//
//  Created by takahiro menju on 2019/12/10.
//  Copyright © 2019 DroidKaigi. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import MaterialComponents

final class SessionViewController: UIViewController {

    private let disposeBag = DisposeBag()

    @IBOutlet weak var filteredSessionCountLabel: UILabel! {
        didSet {
            filteredSessionCountLabel.font = ApplicationScheme.shared.typographyScheme.caption
        }
    }
    @IBOutlet weak var filterButton: MDCButton! {
        didSet {
            filterButton.isSelected = true
            filterButton.applyTextTheme(withScheme: ApplicationScheme.shared.buttonScheme)
            let filterListImage = UIImage(named: "ic_filter_list")
            let templateFilterListImage = filterListImage?.withRenderingMode(.alwaysTemplate)
            filterButton.setImage(templateFilterListImage, for: .selected)
            let arrowUpImage = UIImage(named: "ic_keyboard_arrow_up")
            let templateArrowUpImage = arrowUpImage?.withRenderingMode(.alwaysTemplate)
            filterButton.setImage(templateArrowUpImage, for: .normal)
            filterButton.setTitle("Filter", for: .selected)
            filterButton.setTitle("", for: .normal)
        }
    }
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.register(UINib(nibName: "SessionCell", bundle: nil), forCellWithReuseIdentifier: SessionCell.identifier)
            let layout = UICollectionViewFlowLayout()
            layout.estimatedItemSize = .init(width: UIScreen.main.bounds.width, height: SessionCell.rowHeight)
            collectionView.collectionViewLayout = layout
        }
    }

    private let viewModel: SessionViewModel

    init(viewModel: SessionViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.viewDidLoad.accept(())

        filterButton.rx.tap.asSignal()
            .emit(to: viewModel.toggleEmbddedView)
            .disposed(by: disposeBag)
        viewModel.isFocusedOnEmbeddedView
            .drive(filterButton.rx.isSelected)
            .disposed(by: disposeBag)

        let dataSource = SessionViewDataSource()
        viewModel.sessions
            .drive(collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
}

