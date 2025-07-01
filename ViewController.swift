// MARK: – App Delegate & Tab Bar

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(
      _ application: UIApplication,
      didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let tab = UITabBarController()
        tab.viewControllers = [
            UINavigationController(rootViewController: CurrentSessionViewController()),
            UINavigationController(rootViewController: UsersViewController()),
            UINavigationController(rootViewController: SessionsViewController())
        ]
        tab.viewControllers?[0].tabBarItem = UITabBarItem(title: "Current", image: UIImage(systemName: "gamecontroller.fill"), tag: 0)
        tab.viewControllers?[1].tabBarItem = UITabBarItem(title: "Players", image: UIImage(systemName: "person.3.fill"), tag: 1)
        tab.viewControllers?[2].tabBarItem = UITabBarItem(title: "History", image: UIImage(systemName: "clock.fill"), tag: 2)
        
        // Customize tab bar appearance
        tab.tabBar.tintColor = .systemBlue
        tab.tabBar.backgroundColor = .systemBackground
        
        window?.rootViewController = tab
        window?.makeKeyAndVisible()
        return true
    }
}

// MARK: – Current Session Tab

class CurrentSessionViewController: UIViewController {
    private let store = DataStore.shared
    private let emptyStateView = EmptyStateView()
    private var sessionDetailVC: SessionDetailViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateCurrentSession()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        title = "Current Session"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "plus.circle.fill"),
            style: .plain,
            target: self,
            action: #selector(startNewSession)
        )
        
        // Setup empty state
        emptyStateView.configure(
            title: "No Active Session",
            subtitle: "Start a new poker session to track buy-ins and manage your game",
            buttonTitle: "Start New Session",
            action: { [weak self] in
                self?.startNewSession()
            }
        )
        
        view.addSubview(emptyStateView)
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
    }
    
    private func updateCurrentSession() {
        // Find the most recent session that doesn't have all players finished
        let activeSession = store.sessions
            .sorted { $0.date > $1.date }
            .first { session in
                session.finalChips.values.contains { $0 == nil }
            }
        
        if let session = activeSession {
            showSessionDetail(session)
        } else {
            showEmptyState()
        }
    }
    
    private func showSessionDetail(_ session: Session) {
        emptyStateView.isHidden = true
        
        if sessionDetailVC?.session.id != session.id {
            sessionDetailVC?.view.removeFromSuperview()
            sessionDetailVC?.removeFromParent()
            
            sessionDetailVC = SessionDetailViewController(session: session)
            addChild(sessionDetailVC!)
            view.addSubview(sessionDetailVC!.view)
            
            sessionDetailVC!.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                sessionDetailVC!.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                sessionDetailVC!.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                sessionDetailVC!.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                sessionDetailVC!.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
            
            sessionDetailVC!.didMove(toParent: self)
        }
    }
    
    private func showEmptyState() {
        emptyStateView.isHidden = false
        sessionDetailVC?.view.removeFromSuperview()
        sessionDetailVC?.removeFromParent()
        sessionDetailVC = nil
    }
    
    @objc private func startNewSession() {
        let vc = NewSessionViewController()
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }
}

// MARK: – Empty State View

class EmptyStateView: UIView {
    private let stackView = UIStackView()
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let actionButton = UIButton(type: .system)
    
    private var buttonAction: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // Icon
        iconImageView.image = UIImage(systemName: "gamecontroller")
        iconImageView.tintColor = .systemGray3
        iconImageView.contentMode = .scaleAspectFit
        
        // Title
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        
        // Subtitle
        subtitleLabel.font = .systemFont(ofSize: 16)
        subtitleLabel.textimport UIKit

// MARK: – Models & Persistence

struct Player: Codable {
    let id: UUID
    var name: String
}

struct Session: Codable {
    let id: UUID
    var date: Date
    var playerIds: [UUID]
    var firstBuyIn: Int
    var secondBuyIn: Int
    var additionalBuyIns: [UUID: Int] // Count of additional buy-ins per player
    var finalChips: [UUID: Double?]
    var highHandOwner: UUID?
    var highHandType: String
    var highHandCards: String? // Formatted display string
    var highHandValue: Double // Calculated high hand prize
}

class DataStore {
    static let shared = DataStore()
    private let usersKey = "users"
    private let sessionsKey = "sessions"
    private init() { load() }

    private(set) var users: [Player] = []
    private(set) var sessions: [Session] = []

    func addUser(name: String) {
        users.append(.init(id: .init(), name: name))
        saveUsers()
    }
    func deleteUser(id: UUID) {
        users.removeAll { $0.id == id }
        saveUsers()
    }

    func addSession(firstBuyIn: Int, secondBuyIn: Int, playerIds: [UUID]) {
        let highHandValue = Double(firstBuyIn + secondBuyIn) * Double(playerIds.count)
        let session = Session(
            id: .init(),
            date: .init(),
            playerIds: playerIds,
            firstBuyIn: firstBuyIn,
            secondBuyIn: secondBuyIn,
            additionalBuyIns: playerIds.reduce(into: [:]) { $0[$1] = 0 },
            finalChips: playerIds.reduce(into: [:]) { $0[$1] = nil },
            highHandOwner: nil,
            highHandType: "Full House",
            highHandCards: nil,
            highHandValue: highHandValue
        )
        sessions.append(session)
        saveSessions()
    }
    
    func updateSession(_ s: Session) {
        if let idx = sessions.firstIndex(where: { $0.id == s.id }) {
            sessions[idx] = s
            saveSessions()
        }
    }

    private func saveUsers() {
        if let data = try? JSONEncoder().encode(users) {
            UserDefaults.standard.set(data, forKey: usersKey)
        }
    }
    private func saveSessions() {
        if let data = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(data, forKey: sessionsKey)
        }
    }
    private func load() {
        if let data = UserDefaults.standard.data(forKey: usersKey), let arr = try? JSONDecoder().decode([Player].self, from: data) {
            users = arr
        }
        if let data = UserDefaults.standard.data(forKey: sessionsKey), let arr = try? JSONDecoder().decode([Session].self, from: data) {
            sessions = arr
        }
    }
}

// MARK: – App Delegate & Tab Bar

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(
      _ application: UIApplication,
      didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let tab = UITabBarController()
        tab.viewControllers = [
            UINavigationController(rootViewController: UsersViewController()),
            UINavigationController(rootViewController: SessionsViewController())
        ]
        tab.viewControllers?[0].tabBarItem = UITabBarItem(title: "Users", image: UIImage(systemName: "person.3"), tag: 0)
        tab.viewControllers?[1].tabBarItem = UITabBarItem(title: "Sessions", image: UIImage(systemName: "clock"), tag: 1)
        window?.rootViewController = tab
        window?.makeKeyAndVisible()
        return true
    }
}

// MARK: – Users Screen

class UsersViewController: UITableViewController {
    private let store = DataStore.shared
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Players"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UserCell")
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addUser))
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    override func tableView(_ tv: UITableView, numberOfRowsInSection section: Int) -> Int {
        return store.users.count
    }
    override func tableView(_ tv: UITableView, cellForRowAt ip: IndexPath) -> UITableViewCell {
        let cell = tv.dequeueReusableCell(withIdentifier: "UserCell", for: ip)
        cell.textLabel?.text = store.users[ip.row].name
        return cell
    }
    override func tableView(_ tv: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt ip: IndexPath) {
        if editingStyle == .delete {
            store.deleteUser(id: store.users[ip.row].id)
            tableView.deleteRows(at: [ip], with: .automatic)
        }
    }
    @objc private func addUser() {
        let ac = UIAlertController(title: "New Player", message: nil, preferredStyle: .alert)
        ac.addTextField { $0.placeholder = "Name" }
        ac.addAction(.init(title: "Cancel", style: .cancel))
        ac.addAction(.init(title: "Add", style: .default) { _ in
            if let name = ac.textFields?.first?.text, !name.isEmpty {
                self.store.addUser(name: name)
                self.tableView.reloadData()
            }
        })
        present(ac, animated: true)
    }
}

// MARK: – Sessions List

class SessionsViewController: UITableViewController {
    private let store = DataStore.shared
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Sessions"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SessionCell")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "New Session", style: .plain, target: self, action: #selector(addSession))
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
    @objc private func addSession() {
        let vc = NewSessionViewController()
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }
}

// MARK: – New Session Form

class NewSessionViewController: UIViewController {
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let store = DataStore.shared
    
    private let firstBuyInScrollView = HorizontalPickerView()
    private let secondBuyInScrollView = HorizontalPickerView()
    private let selectPlayersButton = UIButton(type: .system)
    private let selectedPlayersLabel = UILabel()
    
    private var firstBuyInValue = 5
    private var secondBuyInValue = 10
    private var selectedPlayers: Set<UUID> = []
    private let buyInValues = Array(1...20)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "New Session"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Start", style: .done, target: self, action: #selector(startSession))
        
        // Setup scroll view
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // First Buy-in
        let firstLabel = UILabel()
        firstLabel.text = "First Buy-in"
        firstLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        
        firstBuyInScrollView.configure(with: buyInValues, selectedValue: firstBuyInValue) { [weak self] value in
            self?.firstBuyInValue = value
        }
        
        // Second Buy-in
        let secondLabel = UILabel()
        secondLabel.text = "Additional Buy-in"
        secondLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        
        secondBuyInScrollView.configure(with: buyInValues, selectedValue: secondBuyInValue) { [weak self] value in
            self?.secondBuyInValue = value
        }
        
        // Players Selection
        let playersLabel = UILabel()
        playersLabel.text = "Players"
        playersLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        
        selectPlayersButton.setTitle("Select Players", for: .normal)
        selectPlayersButton.titleLabel?.font = .systemFont(ofSize: 16)
        selectPlayersButton.backgroundColor = .systemBlue
        selectPlayersButton.setTitleColor(.white, for: .normal)
        selectPlayersButton.layer.cornerRadius = 12
        selectPlayersButton.addTarget(self, action: #selector(selectPlayers), for: .touchUpInside)
        
        selectedPlayersLabel.text = "No players selected"
        selectedPlayersLabel.font = .systemFont(ofSize: 14)
        selectedPlayersLabel.textColor = .secondaryLabel
        selectedPlayersLabel.numberOfLines = 0
        
        [firstLabel, firstBuyInScrollView, secondLabel, secondBuyInScrollView, playersLabel, selectPlayersButton, selectedPlayersLabel].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    private func setupConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ])
        
        let stackView = UIStackView(arrangedSubviews: [
            contentView.subviews[0], contentView.subviews[1],
            contentView.subviews[2], contentView.subviews[3],
            contentView.subviews[4], contentView.subviews[5], contentView.subviews[6]
        ])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 30),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30),
            
            firstBuyInScrollView.heightAnchor.constraint(equalToConstant: 60),
            secondBuyInScrollView.heightAnchor.constraint(equalToConstant: 60),
            selectPlayersButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc private func cancel() {
        dismiss(animated: true)
    }
    
    @objc private func selectPlayers() {
        let vc = PlayerSelectionViewController(selectedPlayers: selectedPlayers) { [weak self] players in
            self?.selectedPlayers = players
            self?.updateSelectedPlayersLabel()
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func updateSelectedPlayersLabel() {
        if selectedPlayers.isEmpty {
            selectedPlayersLabel.text = "No players selected"
        } else {
            let names = selectedPlayers.compactMap { id in
                store.users.first { $0.id == id }?.name
            }
            selectedPlayersLabel.text = "\(names.count) players: \(names.joined(separator: ", "))"
        }
    }
    
    @objc private func startSession() {
        guard !selectedPlayers.isEmpty else {
            let alert = UIAlertController(title: "Error", message: "Please select at least one player", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        store.addSession(firstBuyIn: firstBuyInValue, secondBuyIn: secondBuyInValue, playerIds: Array(selectedPlayers))
        dismiss(animated: true)
    }
}

// MARK: – Horizontal Picker View

class HorizontalPickerView: UIView {
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private var valueButtons: [UIButton] = []
    private var selectedValue: Int = 0
    private var onValueChanged: ((Int) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .secondarySystemGroupedBackground
        layer.cornerRadius = 12
        
        addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 16
        stackView.alignment = .center
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])
    }
    
    func configure(with values: [Int], selectedValue: Int, onValueChanged: @escaping (Int) -> Void) {
        self.selectedValue = selectedValue
        self.onValueChanged = onValueChanged
        
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        valueButtons.removeAll()
        
        for value in values {
            let button = UIButton(type: .system)
            button.setTitle("$\(value)", for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
            button.layer.cornerRadius = 8
            button.backgroundColor = value == selectedValue ? .systemBlue : .clear
            button.setTitleColor(value == selectedValue ? .white : .label, for: .normal)
            button.tag = value
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            
            button.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                button.widthAnchor.constraint(equalToConstant: 50),
                button.heightAnchor.constraint(equalToConstant: 40)
            ])
            
            stackView.addArrangedSubview(button)
            valueButtons.append(button)
        }
        
        // Scroll to selected value
        DispatchQueue.main.async {
            if let selectedButton = self.valueButtons.first(where: { $0.tag == selectedValue }) {
                let buttonFrame = selectedButton.convert(selectedButton.bounds, to: self.scrollView)
                let centerX = buttonFrame.midX - self.scrollView.bounds.width / 2
                self.scrollView.setContentOffset(CGPoint(x: max(0, centerX), y: 0), animated: false)
            }
        }
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        let newValue = sender.tag
        selectedValue = newValue
        onValueChanged?(newValue)
        
        // Update button appearances
        valueButtons.forEach { button in
            let isSelected = button.tag == newValue
            button.backgroundColor = isSelected ? .systemBlue : .clear
            button.setTitleColor(isSelected ? .white : .label, for: .normal)
        }
        
        // Scroll to center the selected button
        let buttonFrame = sender.convert(sender.bounds, to: scrollView)
        let centerX = buttonFrame.midX - scrollView.bounds.width / 2
        scrollView.setContentOffset(CGPoint(x: max(0, centerX), y: 0), animated: true)
    }
}

// MARK: – Player Selection Screen

class PlayerSelectionViewController: UIViewController {
    private let tableView = UITableView()
    private let store = DataStore.shared
    private var selectedPlayers: Set<UUID>
    private let completion: (Set<UUID>) -> Void
    
    init(selectedPlayers: Set<UUID>, completion: @escaping (Set<UUID>) -> Void) {
        self.selectedPlayers = selectedPlayers
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Select Players"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(done))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Add Player", style: .plain, target: self, action: #selector(addPlayer))
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "PlayerCell")
        tableView.allowsMultipleSelection = true
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc private func done() {
        completion(selectedPlayers)
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func addPlayer() {
        let alert = UIAlertController(title: "New Player", message: nil, preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Name" }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Add", style: .default) { _ in
            if let name = alert.textFields?.first?.text, !name.isEmpty {
                self.store.addUser(name: name)
                self.tableView.reloadData()
            }
        })
        present(alert, animated: true)
    }
}

extension PlayerSelectionViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return store.users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerCell", for: indexPath)
        let player = store.users[indexPath.row]
        cell.textLabel?.text = player.name
        cell.accessoryType = selectedPlayers.contains(player.id) ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let player = store.users[indexPath.row]
        
        if selectedPlayers.contains(player.id) {
            selectedPlayers.remove(player.id)
        } else {
            selectedPlayers.insert(player.id)
        }
        
        tableView.reloadRows(at: [indexPath], with: .none)
    }
}

// MARK: – Session Detail with Card Views

class SessionDetailViewController: UIViewController {
    private var session: Session
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private let store = DataStore.shared
    private let highHandHeaderView = HighHandHeaderView()

    init(session: Session) {
        self.session = session
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Session"
        view.backgroundColor = .systemGroupedBackground
        setupTable()
        updateHighHandDisplay()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "High Hand", style: .plain, target: self, action: #selector(editHighHand))
    }

    private func setupTable() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(PlayerCardCell.self, forCellReuseIdentifier: "PlayerCardCell")
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.tableHeaderView = highHandHeaderView
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func updateHighHandDisplay() {
        highHandHeaderView.configure(with: session)
    }
    
    @objc private func editHighHand() {
        let vc = HighHandViewController(session: session) { [weak self] updatedSession in
            self?.session = updatedSession
            self?.store.updateSession(updatedSession)
            self?.updateHighHandDisplay()
        }
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }
}

extension SessionDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int { 1 }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return session.playerIds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerCardCell", for: indexPath) as! PlayerCardCell
        let playerId = session.playerIds[indexPath.row]
        let player = store.users.first { $0.id == playerId }!
        
        cell.configure(with: player, session: session)
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let playerId = session.playerIds[indexPath.row]
        let player = store.users.first { $0.id == playerId }!
        
        let vc = PlayerDetailViewController(player: player, session: session)
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension SessionDetailViewController: PlayerCardCellDelegate {
    func didSwipeLeft(on cell: PlayerCardCell, playerId: UUID) {
        // Add additional buy-in
        session.additionalBuyIns[playerId, default: 0] += 1
        store.updateSession(session)
        
        if let indexPath = tableView.indexPath(for: cell) {
            tableView.reloadRows(at: [indexPath], with: .none)
        }
    }
    
    func didSwipeRight(on cell: PlayerCardCell, playerId: UUID) {
        // Set final chips
        let alert = UIAlertController(title: "Final Chips", message: "Enter final chip amount", preferredStyle: .alert)
        alert.addTextField { $0.keyboardType = .decimalPad; $0.placeholder = "Amount" }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default) { _ in
            if let text = alert.textFields?.first?.text, let value = Double(text) {
                self.session.finalChips[playerId] = value
                self.store.updateSession(self.session)
                
                if let indexPath = self.tableView.indexPath(for: cell) {
                    self.tableView.reloadRows(at: [indexPath], with: .none)
                }
            }
        })
        present(alert, animated: true)
    }
}

// MARK: – Player Card Cell

protocol PlayerCardCellDelegate: AnyObject {
    func didSwipeLeft(on cell: PlayerCardCell, playerId: UUID)
    func didSwipeRight(on cell: PlayerCardCell, playerId: UUID)
}

class PlayerCardCell: UITableViewCell {
    weak var delegate: PlayerCardCellDelegate?
    private var playerId: UUID?
    
    private let cardView = UIView()
    private let nameLabel = UILabel()
    private let buyInLabel = UILabel()
    private let additionalBuyInsLabel = UILabel()
    private let statusLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupGestures()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        cardView.backgroundColor = .secondarySystemGroupedBackground
        cardView.layer.cornerRadius = 12
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.layer.shadowRadius = 4
        cardView.layer.shadowOpacity = 0.1
        
        nameLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        buyInLabel.font = .systemFont(ofSize: 14)
        buyInLabel.textColor = .secondaryLabel
        additionalBuyInsLabel.font = .systemFont(ofSize: 14)
        additionalBuyInsLabel.textColor = .systemBlue
        statusLabel.font = .systemFont(ofSize: 12, weight: .medium)
        statusLabel.textAlignment = .right
        
        contentView.addSubview(cardView)
        [nameLabel, buyInLabel, additionalBuyInsLabel, statusLabel].forEach {
            cardView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        cardView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            nameLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            
            statusLabel.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            statusLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            
            buyInLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            buyInLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            
            additionalBuyInsLabel.topAnchor.constraint(equalTo: buyInLabel.bottomAnchor, constant: 4),
            additionalBuyInsLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            additionalBuyInsLabel.bottomAnchor.constraint(lessThanOrEqualTo: cardView.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupGestures() {
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleLeftSwipe))
        leftSwipe.direction = .left
        cardView.addGestureRecognizer(leftSwipe)
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleRightSwipe))
        rightSwipe.direction = .right
        cardView.addGestureRecognizer(rightSwipe)
    }
    
    @objc private func handleLeftSwipe() {
        guard let playerId = playerId else { return }
        delegate?.didSwipeLeft(on: self, playerId: playerId)
    }
    
    @objc private func handleRightSwipe() {
        guard let playerId = playerId else { return }
        delegate?.didSwipeRight(on: self, playerId: playerId)
    }
    
    func configure(with player: Player, session: Session) {
        self.playerId = player.id
        
        nameLabel.text = player.name
        buyInLabel.text = "First Buy-in: $\(session.firstBuyIn)"
        
        let additionalCount = session.additionalBuyIns[player.id] ?? 0
        additionalBuyInsLabel.text = "Additional Buy-ins: \(additionalCount)"
        
        if let finalChips = session.finalChips[player.id], let chips = finalChips {
            statusLabel.text = "Final: $\(Int(chips))"
            statusLabel.textColor = .systemGreen
        } else {
            statusLabel.text = "Playing"
            statusLabel.textColor = .systemOrange
        }
    }
}

// MARK: – High Hand Header View

class HighHandHeaderView: UIView {
    private let titleLabel = UILabel()
    private let typeLabel = UILabel()
    private let cardsLabel = UILabel()
    private let ownerLabel = UILabel()
    private let valueLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 120))
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 12
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.1
        
        titleLabel.text = "High Hand"
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = .systemRed
        
        typeLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        cardsLabel.font = .systemFont(ofSize: 14, weight: .medium)
        cardsLabel.textColor = .secondaryLabel
        ownerLabel.font = .systemFont(ofSize: 14)
        ownerLabel.textColor = .secondaryLabel
        valueLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        valueLabel.textColor = .systemGreen
        
        [titleLabel, typeLabel, cardsLabel, ownerLabel, valueLabel].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            valueLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            typeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            typeLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            cardsLabel.topAnchor.constraint(equalTo: typeLabel.bottomAnchor, constant: 4),
            cardsLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            ownerLabel.topAnchor.constraint(equalTo: cardsLabel.bottomAnchor, constant: 4),
            ownerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            ownerLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -16)
        ])
    }
    
    func configure(with session: Session) {
        typeLabel.text = session.highHandType
        cardsLabel.text = session.highHandCards ?? "Not set"
        valueLabel.text = "$\(Int(session.highHandValue))"
        
        if let ownerId = session.highHandOwner {
            let owner = DataStore.shared.users.first { $0.id == ownerId }
            ownerLabel.text = "Winner: \(owner?.name ?? "Unknown")"
        } else {
            ownerLabel.text = "Winner: Not determined"
        }
    }
}

// MARK: – High Hand Configuration

class HighHandViewController: UIViewController {
    private var session: Session
    private let completion: (Session) -> Void
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private let handTypes = ["Full House", "Four of a Kind", "Straight Flush", "Royal Flush"]
    
    init(session: Session, completion: @escaping (Session) -> Void) {
        self.session = session
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        title = "High Hand"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(save))
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "HandTypeCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "PlayerCell")
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc private func cancel() {
        dismiss(animated: true)
    }
    
    @objc private func save() {
        completion(session)
        dismiss(animated: true)
    }
    
    private func showHandForm(for handType: String) {
        switch handType {
        case "Full House":
            showFullHouseForm()
        case "Four of a Kind":
            showQuadsForm()
        case "Straight Flush":
            showStraightFlushForm()
        case "Royal Flush":
            session.highHandType = handType
            session.highHandCards = "AKQJT"
            tableView.reloadData()
        default:
            break
        }
    }
    
    private func showFullHouseForm() {
        let alert = UIAlertController(title: "Full House", message: "Enter cards", preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Three of a kind (e.g., K)" }
        alert.addTextField { $0.placeholder = "Pair (e.g., 2)" }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default) { _ in
            guard let trips = alert.textFields?[0].text?.uppercased(),
                  let pair = alert.textFields?[1].text?.uppercased(),
                  !trips.isEmpty, !pair.isEmpty else { return }
            
            self.session.highHandType = "Full House"
            self.session.highHandCards = "\(trips)\(trips)\(trips)\(pair)\(pair)"
            self.tableView.reloadData()
        })
        
        present(alert, animated: true)
    }
    
    private func showQuadsForm() {
        let alert = UIAlertController(title: "Four of a Kind", message: "Enter cards", preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Four of a kind (e.g., K)" }
        alert.addTextField { $0.placeholder = "Kicker (e.g., 2)" }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default) { _ in
            guard let quads = alert.textFields?[0].text?.uppercased(),
                  let kicker = alert.textFields?[1].text?.uppercased(),
                  !quads.isEmpty, !kicker.isEmpty else { return }
            
            self.session.highHandType = "Four of a Kind"
            self.session.highHandCards = "\(quads)\(quads)\(quads)\(quads)\(kicker)"
            self.tableView.reloadData()
        })
        
        present(alert, animated: true)
    }
    
    private func showStraightFlushForm() {
        let alert = UIAlertController(title: "Straight Flush", message: "Enter range", preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Low card (e.g., 4)" }
        alert.addTextField { $0.placeholder = "High card (e.g., 8)" }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default) { _ in
            guard let low = alert.textFields?[0].text?.uppercased(),
                  let high = alert.textFields?[1].text?.uppercased(),
                  !low.isEmpty, !high.isEmpty else { return }
            
            self.session.highHandType = "Straight Flush"
            self.session.highHandCards = "\(low)\(high) Straight"
            self.tableView.reloadData()
        })
        
        present(alert, animated: true)
    }
}

extension HighHandViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return handTypes.count
        } else {
            return session.playerIds.count
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String {
        return section == 0 ? "Hand Type" : "Winner"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HandTypeCell", for: indexPath)
            let handType = handTypes[indexPath.row]
            cell.textLabel?.text = handType
            cell.accessoryType = handType == session.highHandType ? .checkmark : .none
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerCell", for: indexPath)
            let playerId = session.playerIds[indexPath.row]
            let player = DataStore.shared.users.first { $0.id == playerId }!
            cell.textLabel?.text = player.name
            cell.accessoryType = session.highHandOwner == playerId ? .checkmark : .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 {
            let handType = handTypes[indexPath.row]
            showHandForm(for: handType)
        } else {
            let playerId = session.playerIds[indexPath.row]
            session.highHandOwner = playerId
            tableView.reloadSections([1], with: .none)
        }
    }
}

// MARK: – Player Detail View

class PlayerDetailViewController: UIViewController {
    private let player: Player
    private let session: Session
    private let tableView = UITableView(frame: .zero, style: .grouped)
    
    init(player: Player, session: Session) {
        self.player = player
        self.session = session
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        title = player.name
        
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DetailCell")
        tableView.allowsSelection = false
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension PlayerDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath)
        
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "First Buy-in"
            cell.detailTextLabel?.text = "$\(session.firstBuyIn)"
        case 1:
            let additionalCount = session.additionalBuyIns[player.id] ?? 0
            cell.textLabel?.text = "Additional Buy-ins"
            cell.detailTextLabel?.text = "\(additionalCount) × $\(session.secondBuyIn) = $\(additionalCount * session.secondBuyIn)"
        case 2:
            if let finalChips = session.finalChips[player.id], let chips = finalChips {
                cell.textLabel?.text = "Final Chips"
                cell.detailTextLabel?.text = "$\(Int(chips))"
            } else {
                cell.textLabel?.text = "Final Chips"
                cell.detailTextLabel?.text = "Not set"
            }
        case 3:
            let firstBuyIn = session.firstBuyIn
            let additionalBuyIns = (session.additionalBuyIns[player.id] ?? 0) * session.secondBuyIn
            let totalSpent = firstBuyIn + additionalBuyIns
            
            cell.textLabel?.text = "Total Spent"
            cell.detailTextLabel?.text = "$\(totalSpent)"
        default:
            break
        }
        
        cell.selectionStyle = .none
        return cell
    }
}
