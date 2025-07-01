//
//  SessionsViewController.swift
//  PokerBuyin
//
//  Created by NARESH KUMAR - Vendor on 6/30/25.
//


import UIKit

class SessionsViewController: UITableViewController {
    private let store = DataStore.shared
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Sessions"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SessionCell")
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    override func tableView(_ tv: UITableView, numberOfRowsInSection section: Int) -> Int {
        return store.sessions.count
    }
    override func tableView(_ tv: UITableView, cellForRowAt ip: IndexPath) -> UITableViewCell {
        let cell = tv.dequeueReusableCell(withIdentifier: "SessionCell", for: ip)
        let session = store.sessions[ip.row]
        let df = DateFormatter(); df.dateStyle = .short; df.timeStyle = .short
        cell.textLabel?.text = df.string(from: session.date)
        cell.detailTextLabel?.text = "\(session.playerIds.count) players"
        return cell
    }
    override func tableView(_ tv: UITableView, didSelectRowAt ip: IndexPath) {
        tv.deselectRow(at: ip, animated: true)
        let vc = SessionDetailViewController(session: store.sessions[ip.row])
        navigationController?.pushViewController(vc, animated: true)
    }
}
