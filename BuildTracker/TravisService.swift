//
//  TravisService.swift
//  BuildTracker
//
//  Created by Ricardo Pereira on 14/12/2018.
//  Copyright © 2018 Whitesmith. All rights reserved.
//

import Foundation
import PromiseKit

struct Builds: Codable {
    let builds: [Build]
}

struct Build: Codable {
    let id: Int
    let eventType: String
    let state: String
    let repository: Repository
    let branch: Branch
    let commit: Commit
}

struct Jobs: Codable {
    let jobs: [Job]
}

struct Job: Codable {
    let id: Int
    let number: String
    let state: String
}

struct Repository: Codable {
    let id: Int
    let name: String
    let slug: String
}

struct Branch: Codable {
    let name: String
}

struct Commit: Codable {
    let sha: String
    let message: String
}

enum ResponseError: Error {
    case unknown
}

class TravisService {

    let baseURL = URL(string: "https://api.travis-ci.org")!

    let apiVersion = "3"
    let token = <token>

    func fetchBuilds() -> Promise<Builds> {
        let promiser = Promise<Builds>.pending()
        let url = baseURL.appendingPathComponent("builds")

        var request = URLRequest(url: url)
        request.setValue(apiVersion, forHTTPHeaderField: "Travis-API-Version")
        request.setValue("token \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse else {
                promiser.resolver.reject(ResponseError.unknown)
                return
            }
            guard let data = data, httpResponse.statusCode == 200 else {
                promiser.resolver.reject(ResponseError.unknown)
                return
            }
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let decodedBuilds = try decoder.decode(Builds.self, from: data)
                promiser.resolver.fulfill(decodedBuilds)
            }
            catch {
                print(#file, #function, error)
                promiser.resolver.reject(error)
            }
        }.resume()

        return promiser.promise
    }

    func fetchJobs(build: Build) -> Promise<Jobs> {
        let promiser = Promise<Jobs>.pending()
        let url = baseURL.appendingPathComponent("build/\(String(build.id))/jobs")

        var request = URLRequest(url: url)
        request.setValue(apiVersion, forHTTPHeaderField: "Travis-API-Version")
        request.setValue("token \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse else {
                promiser.resolver.reject(ResponseError.unknown)
                return
            }
            guard let data = data, httpResponse.statusCode == 200 else {
                promiser.resolver.reject(ResponseError.unknown)
                return
            }
            do {
                let decodedJobs = try JSONDecoder().decode(Jobs.self, from: data)
                promiser.resolver.fulfill(decodedJobs)
            }
            catch {
                print(#file, #function, error)
                promiser.resolver.reject(error)
            }
        }.resume()

        return promiser.promise
    }

    func cancel(job: Job) -> Promise<Void> {
        if job.state.lowercased() == "passed" {
            return Promise.value(())
        }

        let promiser = Promise<Void>.pending()
        let url = baseURL.appendingPathComponent("job/\(String(job.id))/cancel")

        var request = URLRequest(url: url)
        request.setValue(apiVersion, forHTTPHeaderField: "Travis-API-Version")
        request.setValue("token \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse else {
                promiser.resolver.reject(ResponseError.unknown)
                return
            }
            guard httpResponse.statusCode == 202 else {
                promiser.resolver.reject(ResponseError.unknown)
                return
            }
            promiser.resolver.fulfill(())
        }.resume()

        return promiser.promise
    }

    func restart(job: Job) -> Promise<Void> {
        if job.state.lowercased() == "passed" {
            return Promise.value(())
        }

        let promiser = Promise<Void>.pending()
        let url = baseURL.appendingPathComponent("job/\(String(job.id))/restart")

        var request = URLRequest(url: url)
        request.setValue(apiVersion, forHTTPHeaderField: "Travis-API-Version")
        request.setValue("token \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse else {
                promiser.resolver.reject(ResponseError.unknown)
                return
            }
            guard httpResponse.statusCode == 202 else {
                promiser.resolver.reject(ResponseError.unknown)
                return
            }
            promiser.resolver.fulfill(())
        }.resume()

        return promiser.promise
    }

}
