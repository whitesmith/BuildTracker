//
//  JobsViewController.swift
//  BuildTracker
//
//  Created by Ricardo Pereira on 14/12/2018.
//  Copyright © 2018 Whitesmith. All rights reserved.
//

import UIKit

class JobsViewController: UITableViewController {

    let build: Build
    var jobs: [Job] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    let travisService = TravisService()

    init(build: Build) {
        self.build = build
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Jobs: \(build.id)"

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Job")
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(self.handleRefresh), for: .valueChanged)
        loadContent()
    }

    func loadContent() {
        travisService.fetchJobs(build: build).done { [weak self] jobs in
            self?.jobs = jobs.jobs
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
        return jobs.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Job", for: indexPath)
        let job = jobs[indexPath.row]
        cell.textLabel?.text = "\(job.number): \(job.state)"
        switch job.state.lowercased() {
        case "passed":
            cell.contentView.backgroundColor = .systemGreen
        case "failed",
             "errored":
            cell.contentView.backgroundColor = .systemRed
        case "started":
            cell.contentView.backgroundColor = .systemYellow
        case "created",
             "received":
            cell.contentView.backgroundColor = .systemOrange
        default:
            cell.contentView.backgroundColor = .systemGray
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let job = jobs[indexPath.row]
        let alertController = UIAlertController(title: "Operations", message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        if job.state.lowercased() == "failed" || job.state.lowercased() == "canceled" || job.state.lowercased() == "errored" {
            alertController.addAction(UIAlertAction(title: "Restart Job", style: .default, handler: { [weak self] _ in
                self?.travisService.restart(job: job).done {
                    // Success
                    self?.loadContent()
                }.catch { error in
                    print(error)
                }
            }))
        }
        if job.state.lowercased() == "started" || job.state.lowercased() == "created" || job.state.lowercased() == "received" {
            alertController.addAction(UIAlertAction(title: "Cancel Job", style: .default, handler: { [weak self] _ in
                self?.travisService.cancel(job: job).done {
                    // Success
                    self?.loadContent()
                }.catch { error in
                    print(error)
                }
            }))
        }
        present(alertController, animated: true, completion: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
