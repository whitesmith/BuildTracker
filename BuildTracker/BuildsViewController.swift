//
//  BuildsViewController.swift
//  BuildTracker
//
//  Created by Ricardo Pereira on 14/12/2018.
//  Copyright © 2018 Whitesmith. All rights reserved.
//

import UIKit

class BuildsViewController: UITableViewController {

    var builds: [Build] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    let travisService = TravisService()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Builds"

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Build")
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(self.handleRefresh), for: .valueChanged)
        loadContent()
    }

    func loadContent() {
        travisService.fetchBuilds().done { [weak self] builds in
            self?.builds = builds.builds
        }.catch { error in
            print(error)
        }.finally { [weak self] in
            self?.tableView.refreshControl?.endRefreshing()
        }
    }

    @objc func handleRefresh() {
        loadContent()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return builds.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Build", for: indexPath)
        let build = builds[indexPath.row]
        cell.textLabel?.text = "\(build.repository.name): \(build.eventType)@\(build.branch.name) (\(build.commit.message))"
        switch build.state.lowercased() {
        case "passed":
            cell.contentView.backgroundColor = .systemGreen
        case "failed":
            cell.contentView.backgroundColor = .systemRed
        case "started":
            cell.contentView.backgroundColor = .systemYellow
        case "created":
            cell.contentView.backgroundColor = .systemOrange
        default:
            cell.contentView.backgroundColor = .systemGray
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let build = builds[indexPath.row]
        navigationController?.pushViewController(JobsViewController(build: build), animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }

}

