//
//  ViewController.swift
//  MitmproxyiOS
//
//  Created by Rafael Lucena on 3/6/21.
//

import UIKit

private struct TodoModel {
    let title: String
    let description: String
    let resolved: Bool
}

final class TodoViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView!
    private var data = [String]() {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
    }
}

extension TodoViewController: UITableViewDelegate, UITableViewDataSource {

    private func configureTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell") ?? UITableViewCell()

        cell.textLabel?.text = data[indexPath.row]
        return cell
    }
}

private extension TodoViewController {

    @objc
    func fetchData() {
        guard let url = URL(string: "https://com.rlmg.mitmproxy.server.com/data") else { return }
        URLSession.shared.dataTask(with: URLRequest(url: url)) { (data, response, error) in
            if let response = response {
                print(response)
            }
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    print(json)
                } catch {
                    print(error)
                }
            }
        }.resume()
    }
}
