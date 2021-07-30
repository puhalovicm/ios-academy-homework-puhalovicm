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

    @IBOutlet weak var detailsTableView: UITableView!
    @IBOutlet weak var writeReviewButton: UIButton!

    var showId: String? = nil
    var authInfo: AuthInfo? = nil
    var show: Show? = nil

    // MARK: - Private

    private let reviewManager: ReviewManager = ReviewManager.sharedInstance
    private var items: [Review] = []
    private var currentPage = 1


    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupStatusBar()
        fetchShowsAndUpdate()
        setupTableView()
        writeReviewButton.layer.cornerRadius = 25
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height

        if (offsetY > contentHeight - scrollView.frame.height * 2) && !SVProgressHUD.isVisible() {
            fetchShowsAndUpdate()
        }
    }

    @IBAction func launchReviewWriteScreen(_ sender: Any) {
        let vc = UIStoryboard.init(name: "WriteReview", bundle: Bundle.main).instantiateViewController(withIdentifier: "WriteReviewViewController") as! WriteReviewViewController

        vc.authInfo = authInfo
        vc.showId = show?.id

        vc.delegate = self

        let navigationController = UINavigationController(rootViewController: vc)
        present(navigationController, animated: true)
    }
}

private extension ShowDetailsViewController {

    func setupNavigationBar() {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.hidesBackButton = false
        self.navigationController?.navigationBar.backgroundColor = UIColor(named: "Gray")
        self.title = show?.title
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

        guard
            let headers = authInfo?.headers,
            let showId = showId
        else {
            return
        }

        reviewManager.fetchReviews(
            page: currentPage,
            showId: showId,
            headers: headers
        ) { [weak self] result in
            SVProgressHUD.dismiss()

            switch result {
            case .success (let showResponse):
                let reviews = showResponse.0.reviews
                let meta = showResponse.0.meta

                self?.items += reviews
                self?.currentPage = (meta.pagination.page ?? self?.currentPage ?? 0) + 1

                self?.detailsTableView.reloadData()
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
}

// MARK: - UITableView

extension ShowDetailsViewController: UITableViewDelegate {

}

extension ShowDetailsViewController: UITableViewDataSource {

    // MARK: - UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

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

// MARK: - Private

private extension ShowDetailsViewController {

    func setupTableView() {
        detailsTableView.estimatedRowHeight = 120
        detailsTableView.rowHeight = UITableView.automaticDimension
        detailsTableView.tableFooterView = UIView()
        detailsTableView.delegate = self
        detailsTableView.dataSource = self
    }
}

extension ShowDetailsViewController: WriteReviewViewControllerDelegate {

    func onSuccessfulRatingSubmit() {
        currentPage = 0
        items = []
        detailsTableView.reloadData()
        fetchShowsAndUpdate()
    }
}
