//
//  ViewController.swift
//  MitmproxyiOS
//
//  Created by Rafael Lucena on 3/6/21.
//

import UIKit

private struct TodoModel: Codable {
    let title: String
    let resolved: Bool
}

private struct TodosResponse: Codable {
    let resolved: [TodoModel]
    let unresolved: [TodoModel]
}

final class TodoViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView!
    private var response = TodosResponse(resolved: [], unresolved: []) {
        didSet {
            DispatchQueue.main.async {
                self.tableView.refreshControl?.endRefreshing()
                self.tableView.reloadData()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()

        configureNavigationBar()
        fetchData()
    }
}

extension TodoViewController: UITableViewDelegate, UITableViewDataSource {

    private func configureNavigationBar() {
        title = "Mitmproxy To Dos"
    }

    private func configureTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        tableView.delegate = self
        tableView.dataSource = self

        var refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(fetchData), for: .primaryActionTriggered)
        tableView.refreshControl = refreshControl
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return response.unresolved.count
        }

        return response.resolved.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Unresolved"
        }

        return "Resolved"
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell") ?? UITableViewCell()
        let todos = indexPath.section == 0 ? response.unresolved : response.resolved

        cell.textLabel?.text = todos[indexPath.row].title
        cell.accessoryType = indexPath.section == 0 ? .none : .checkmark

        return cell
    }
}

private extension TodoViewController {

    @objc
    func fetchData() {
        guard let url = URL(string: "http://com.rlmg.mitmproxy.server.com/todos") else { return }
        URLSession.shared.dataTask(with: URLRequest(url: url)) { [weak self] (data, response, error) in
//            if let response = response {
//                print(response)
//            }
            if let data = data {
                do {
//                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    self?.response = try JSONDecoder().decode(TodosResponse.self, from: data)
                } catch {
                    print(error)
                }
            }
        }.resume()
    }
}
