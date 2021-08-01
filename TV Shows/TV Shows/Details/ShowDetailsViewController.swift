//
//  ShowDetailsViewController.swift
//  TV Shows
//
//  Created by Mateo Puhalović on 27.07.2021..
//

import Foundation
import UIKit
import SVProgressHUD

final class ShowDetailsViewController: UIViewController {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .default
        }
    }

    var show: TVShowItem? = nil
    var authInfo: AuthInfo? = nil

    @IBOutlet private weak var detailsTableView: UITableView!
    @IBOutlet private weak var writeReviewButton: UIButton!

    private var activtiyIndicatorFooter: UIActivityIndicatorView? = nil

    // MARK: - Private

    private let reviewService: ReviewService = ReviewService.sharedInstance
    private var items: [Review] = []
    private var currentPage = 1
    private var pages: Int? = nil
    private var isLoading = false

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupStatusBar()
        fetchReviewsAndUpdate()
        setupTableView()
        writeReviewButton.layer.cornerRadius = 25
        configureRefreshControl()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    @IBAction func launchReviewWriteScreen(_ sender: Any) {
        let vc = UIStoryboard.init(name: "WriteReview", bundle: Bundle.main).instantiateViewController(withIdentifier: "WriteReviewViewController") as! WriteReviewViewController

        vc.authInfo = authInfo
        vc.showId = show?.showId
        vc.delegate = self

        let navigationController = UINavigationController(rootViewController: vc)
        present(navigationController, animated: true)
    }
}

private extension ShowDetailsViewController {

    func configureRefreshControl() {
        detailsTableView.refreshControl = UIRefreshControl()
        detailsTableView.refreshControl?.addTarget(
            self,
            action: #selector(handleRefreshControl),
            for: .valueChanged
        )
    }

    @objc func handleRefreshControl() {
        resetReviewData()
    }

    func resetReviewData() {
        currentPage = 1
        items = []
        detailsTableView.reloadData()
        fetchReviewsAndUpdate()
    }

    func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.hidesBackButton = false
        navigationController?.navigationBar.backgroundColor = UIColor(named: "Gray")
        title = show?.showTitle
        navigationController?.navigationBar.tintColor = UIColor(named: "Purple")
    }

    func fetchReviewsAndUpdate() {
        guard
            let headers = authInfo?.headers,
            let showId = show?.showId
        else {
            return
        }

        if
            let pages = pages,
            currentPage > pages {
            return
        }

        showActivityIndicatorFooter()
        isLoading = true

        reviewService.fetchReviews(
            page: currentPage,
            showId: showId,
            headers: headers
        ) { [weak self] result in
            guard let self = self else { return }

            self.hideActivityIndicatorFooter()
            self.isLoading = false

            // Dismiss the refresh control.
            DispatchQueue.main.async {
               self.detailsTableView.refreshControl?.endRefreshing()
            }

            switch result {
            case .success (let showResponse):
                let reviews = showResponse.0.reviews
                let meta = showResponse.0.meta

                guard
                    meta.pagination.page == self.currentPage
                else {
                    return
                }

                self.items += reviews
                self.currentPage = meta.pagination.page + 1
                self.pages = meta.pagination.pages

                self.detailsTableView.reloadData()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

// MARK: - UITableView

extension ShowDetailsViewController: UITableViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height

        if (offsetY > contentHeight - scrollView.frame.height * 2) && !isLoading {
            fetchReviewsAndUpdate()
        }
    }
}

extension ShowDetailsViewController: UITableViewDataSource {

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            return createDetailsTopPartViewCell(tableView: tableView, indexPath: indexPath)
        } else {
            return createReviewViewCell(tableView: tableView, indexPath: indexPath)
        }
    }
}

// MARK: - Private

private extension ShowDetailsViewController {

    func setupTableView() {
        detailsTableView.rowHeight = UITableView.automaticDimension
        detailsTableView.tableFooterView = UIView()
        detailsTableView.delegate = self
        detailsTableView.dataSource = self
        detailsTableView.tableFooterView = createActivityIndicatorFooter()
    }

    func createActivityIndicatorFooter() -> UIActivityIndicatorView {
        let activtiyIndicatorFooter = UIActivityIndicatorView(style: .gray)
        activtiyIndicatorFooter.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: detailsTableView.bounds.width, height: CGFloat(44))
        activtiyIndicatorFooter.backgroundColor = UIColor(named: "Gray")
        return activtiyIndicatorFooter
    }

    func showActivityIndicatorFooter() {
        if let activtiyIndicatorFooter = activtiyIndicatorFooter {
            detailsTableView.tableFooterView = activtiyIndicatorFooter
        } else {
            activtiyIndicatorFooter = createActivityIndicatorFooter()
            detailsTableView.tableFooterView = activtiyIndicatorFooter
        }

        activtiyIndicatorFooter?.startAnimating()
        detailsTableView.isHidden = false
        detailsTableView.layoutIfNeeded()
    }

    func hideActivityIndicatorFooter() {
        activtiyIndicatorFooter?.stopAnimating()
        detailsTableView.tableHeaderView?.frame = CGRect.zero
        detailsTableView.sectionFooterHeight = 0
        detailsTableView.tableFooterView = UIView(frame: CGRect.zero)
        detailsTableView.layoutIfNeeded()
    }

    func createDetailsTopPartViewCell(tableView: UITableView, indexPath: IndexPath) -> ShowDetailsTopTableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: ShowDetailsTopTableViewCell.self),
            for: indexPath
        ) as! ShowDetailsTopTableViewCell

        cell.configure(with: show!)

        return cell
    }

    func createReviewViewCell(tableView: UITableView, indexPath: IndexPath) -> ReviewViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "ReviewViewCell",
            for: indexPath
        ) as! ReviewViewCell

        cell.configure(with: items[indexPath.row - 1])

        return cell
    }
}

extension ShowDetailsViewController: WriteReviewViewControllerDelegate {

    func onSuccessfulRatingSubmit() {
        resetReviewData()
    }
}
