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

    @IBOutlet weak var showsTableView: UITableView!

    // MARK: - Private

    private let homeManager: HomeManager = HomeManager.sharedInstance
    private var items: [TVShowItem] = []
    private var currentPage = 1


    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupStatusBar()
        setupProfileButton()
        setupTableView()
        fetchShowsAndUpdate()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height

        if (offsetY > contentHeight - scrollView.frame.height * 2) && !SVProgressHUD.isVisible() {
            fetchShowsAndUpdate()
        }
    }
}

private extension HomeViewController {

    func setupNavigationBar() {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.hidesBackButton = true
        self.navigationController?.navigationBar.backgroundColor = UIColor(named: "Gray")
        self.title = "Shows"
    }

    func setupProfileButton() {
        if #available(iOS 14.0, *) {
            let segmentBarItem = UIBarButtonItem(image: UIImage(named: "ic-profile"))
            segmentBarItem.tintColor = UIColor(named: "Purple")
            navigationItem.rightBarButtonItem = segmentBarItem
        } else {
            // Fallback on earlier versions
        }
    }

    func setupStatusBar() {
        if #available(iOS 13, *)
        {
            let statusBar = UIView(frame: (UIApplication.shared.keyWindow?.windowScene?.statusBarManager?.statusBarFrame)!)
            statusBar.backgroundColor = UIColor(named: "Gray")
            UIApplication.shared.keyWindow?.addSubview(statusBar)
        } else {
           // ADD THE STATUS BAR AND SET A CUSTOM COLOR
           let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
           if statusBar.responds(to:#selector(setter: UIView.backgroundColor)) {
              statusBar.backgroundColor = UIColor(named: "Gray")
           }
        }
    }

    func fetchShowsAndUpdate() {
        SVProgressHUD.show()

        guard let headers = authInfo?.headers else {
            return
        }

        homeManager.fetchShows(
            page: currentPage,
            headers: headers
        ) { [weak self] result in
            SVProgressHUD.dismiss()

            switch result {
            case .success (let showResponse):
                let shows = showResponse.0.shows
                let meta = showResponse.0.meta

                self?.items += self?.mapShowsToItems(shows: shows) ?? []
                self?.currentPage = (meta.pagination.page ?? self?.currentPage ?? 0) + 1

                self?.showsTableView.reloadData()
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
                show: show
            )
        }
    }

    func showDetailsScreen(item: TVShowItem) {
        let vc = UIStoryboard.init(name: "ShowDetails", bundle: Bundle.main).instantiateViewController(withIdentifier: "ShowDetailsViewController") as! ShowDetailsViewController

        guard let authInfo = authInfo else {
            return
        }

        vc.authInfo = authInfo
        vc.showId = item.showId
        vc.show = item.show

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
}

extension HomeViewController: UITableViewDataSource {

    // MARK: - UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

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
        showsTableView.tableFooterView = UIView()
        showsTableView.delegate = self
        showsTableView.dataSource = self
    }
}
