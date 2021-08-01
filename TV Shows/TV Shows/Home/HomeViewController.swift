//
//  HomeViewController.swift
//  TV Shows
//
//  Created by Mateo Puhalović on 16.07.2021..
//

import Foundation
import UIKit
import SVProgressHUD

final class HomeViewController: UIViewController {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .default
        }
    }

    var userResponse: UserResponse? = nil
    var authInfo: AuthInfo? = nil

    private var activtiyIndicatorFooter: UIActivityIndicatorView? = nil
    @IBOutlet weak var showsTableView: UITableView!

    // MARK: - Private

    private let homeService: HomeService = HomeService.sharedInstance
    private var items: [TVShowItem] = []
    private var currentPage = 1
    private var pages: Int? = nil
    private var isLoading = false

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupStatusBar()
        setupProfileButton()
        setupTableView()
        fetchShowsAndUpdate()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}

private extension HomeViewController {

    func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.hidesBackButton = true
        navigationController?.navigationBar.backgroundColor = UIColor(named: "Gray")
        title = "Shows"
    }

    func setupProfileButton() {
        let segmentBarItem = UIBarButtonItem(
            image: UIImage(named: "ic-profile"),
            style: .plain,
            target: self,
            action: #selector(didSelectProfileIcon)
        )
        segmentBarItem.tintColor = UIColor(named: "Purple")

        navigationItem.rightBarButtonItem = segmentBarItem
    }

    @objc private func didSelectProfileIcon() {
        // TODO
    }

    func fetchShowsAndUpdate() {
        guard
            let headers = authInfo?.headers
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
        
        homeService.fetchShows(
            page: currentPage,
            headers: headers
        ) { [weak self] result in
            guard let self = self else { return }

            self.hideActivityIndicatorFooter()
            self.isLoading = false

            switch result {
            case .success (let showResponse):
                let shows = showResponse.0.shows
                let meta = showResponse.0.meta

                guard
                    meta.pagination.page == self.currentPage
                else {
                    return
                }

                self.items += self.mapShowsToItems(shows: shows)
                self.currentPage = meta.pagination.page + 1
                self.pages = meta.pagination.pages

                self.showsTableView.reloadData()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }

    func mapShowsToItems(shows: [Show]) -> [TVShowItem] {
        return shows.map { show in
            TVShowItem(
                showId: show.id,
                name: show.title,
                imageUrl: show.imageUrl,
                showTitle: show.title,
                showDescription: show.description,
                noOfReviews: show.noOfReviews,
                averageRating: show.averageRating
            )
        }
    }

    func showDetailsScreen(item: TVShowItem) {
        let vc = UIStoryboard.init(name: "ShowDetails", bundle: Bundle.main).instantiateViewController(withIdentifier: "ShowDetailsViewController") as! ShowDetailsViewController

        guard let authInfo = authInfo else {
            return
        }

        vc.authInfo = authInfo
        vc.show = item

        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - UITableView

extension HomeViewController: UITableViewDelegate {

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showsTableView.deselectRow(at: indexPath, animated: true)
        let item = items[indexPath.row]
        showDetailsScreen(item: item)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height

        if (offsetY > contentHeight - scrollView.frame.height * 2) && !isLoading {
            fetchShowsAndUpdate()
        }
    }
}

extension HomeViewController: UITableViewDataSource {

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: TVShowTableViewCell.self),
            for: indexPath
        ) as! TVShowTableViewCell

        cell.configure(with: items[indexPath.row])

        return cell
    }
}

// MARK: - Private

private extension HomeViewController {

    func setupTableView() {
        showsTableView.estimatedRowHeight = 120
        showsTableView.rowHeight = 120
        showsTableView.delegate = self
        showsTableView.dataSource = self
        showsTableView.tableFooterView = createActivityIndicatorFooter()
    }

    func createActivityIndicatorFooter() -> UIActivityIndicatorView {
        let activtiyIndicatorFooter = UIActivityIndicatorView(style: .gray)
        activtiyIndicatorFooter.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: showsTableView.bounds.width, height: CGFloat(44))
        activtiyIndicatorFooter.backgroundColor = UIColor(named: "Gray")
        return activtiyIndicatorFooter
    }

    func showActivityIndicatorFooter() {
        if let activtiyIndicatorFooter = activtiyIndicatorFooter {
            showsTableView.tableFooterView = activtiyIndicatorFooter
        } else {
            activtiyIndicatorFooter = createActivityIndicatorFooter()
            showsTableView.tableFooterView = activtiyIndicatorFooter
        }

        activtiyIndicatorFooter?.startAnimating()
        showsTableView.isHidden = false
        showsTableView.layoutIfNeeded()
    }

    func hideActivityIndicatorFooter() {
        activtiyIndicatorFooter?.stopAnimating()
        showsTableView.tableHeaderView?.frame = CGRect.zero
        showsTableView.sectionFooterHeight = 0
        showsTableView.tableFooterView = UIView(frame: CGRect.zero)
        showsTableView.layoutIfNeeded()
    }
}
