//
//  AppDelegate.swift
//  PokerBuyin
//
//  Created by NARESH KUMAR  6/30/25.
//
//

import UIKit

// MARK: - AppDelegate

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
//        FirebaseApp.configure()
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = AdvancedLaunchScreenViewController()
        window?.makeKeyAndVisible()
        return true
    }
}

class AdvancedLaunchScreenViewController: UIViewController {
    
    private let particleEmitter = CAEmitterLayer()
    private let logoContainer = UIView()
    private let pokerChipView = UIView()
    private let chipCenterView = UIView()
    private let cardSuitStack = UIStackView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let backgroundGradientLayer = CAGradientLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAdvancedUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        performAdvancedAnimations()
    }
    
    private func setupAdvancedUI() {
        // Custom gradient background
        setupGradientBackground()
        
        // Setup floating chip particles
        setupPokerChipParticles()
        
        // Logo container setup (poker chip design)
        logoContainer.translatesAutoresizingMaskIntoConstraints = false
        logoContainer.alpha = 0
        view.addSubview(logoContainer)
        
        // Create poker chip design
        setupPokerChip()
        
        // Card suits decoration
        setupCardSuits()
        
        // Title setup with poker styling
        titleLabel.text = "Poker BuyIns"
        titleLabel.font = UIFont(name: "Futura-Bold", size: 36) ?? UIFont.systemFont(ofSize: 36, weight: .heavy)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.alpha = 0
        titleLabel.layer.shadowColor = UIColor.black.cgColor
        titleLabel.layer.shadowRadius = 3
        titleLabel.layer.shadowOpacity = 0.8
        titleLabel.layer.shadowOffset = CGSize(width: 2, height: 2)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        // Subtitle setup
        subtitleLabel.text = "పేకాటే కాదు, లెక్కలు కూడా క్లియర్!"
        subtitleLabel.font = UIFont(name: "Futura-Medium", size: 18) ?? UIFont.systemFont(ofSize: 18, weight: .medium)
        subtitleLabel.textColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0) // Gold color
        subtitleLabel.textAlignment = .center
        subtitleLabel.alpha = 0
        subtitleLabel.layer.shadowColor = UIColor.black.cgColor
        subtitleLabel.layer.shadowRadius = 2
        subtitleLabel.layer.shadowOpacity = 0.6
        subtitleLabel.layer.shadowOffset = CGSize(width: 1, height: 1)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(subtitleLabel)
        
        // Constraints
        NSLayoutConstraint.activate([
            logoContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -80),
            logoContainer.widthAnchor.constraint(equalToConstant: 120),
            logoContainer.heightAnchor.constraint(equalToConstant: 120),
            
            cardSuitStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cardSuitStack.topAnchor.constraint(equalTo: logoContainer.bottomAnchor, constant: 20),
            
            titleLabel.topAnchor.constraint(equalTo: cardSuitStack.bottomAnchor, constant: 25),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupGradientBackground() {
        // Base color: RGB(20, 125, 140)
        let baseColor = UIColor(red: 20/255.0, green: 125/255.0, blue: 140/255.0, alpha: 1.0)
        
        // Create gradient variations of the base color
        backgroundGradientLayer.colors = [
            UIColor(red: 15/255.0, green: 95/255.0, blue: 105/255.0, alpha: 1.0).cgColor,  // Darker variation
            baseColor.cgColor,                                                              // Base color
            UIColor(red: 10/255.0, green: 75/255.0, blue: 85/255.0, alpha: 1.0).cgColor   // Darkest variation
        ]
        backgroundGradientLayer.locations = [0.0, 0.5, 1.0]
        backgroundGradientLayer.frame = view.bounds
        view.layer.insertSublayer(backgroundGradientLayer, at: 0)
    }
    
    private func setupPokerChip() {
        // Main chip outer circle with border - RGB(14, 110, 192)
        pokerChipView.backgroundColor = UIColor(red: 14/255.0, green: 110/255.0, blue: 192/255.0, alpha: 1.0)
        pokerChipView.layer.cornerRadius = 60
        pokerChipView.layer.borderWidth = 4
        // Border color - RGB(8, 66, 143)
        pokerChipView.layer.borderColor = UIColor(red: 8/255.0, green: 66/255.0, blue: 143/255.0, alpha: 1.0).cgColor
        pokerChipView.translatesAutoresizingMaskIntoConstraints = false
        logoContainer.addSubview(pokerChipView)
        
        // Add the authentic trim edge scallops/spokes around the rim
        addAuthenticRimEdges()
        
        // Inner center circle with thick border
        chipCenterView.backgroundColor = UIColor.white
        chipCenterView.layer.cornerRadius = 25 // Smaller center circle
        chipCenterView.layer.borderWidth = 4
        chipCenterView.layer.borderColor = UIColor(red: 14/255.0, green: 110/255.0, blue: 192/255.0, alpha: 1.0).cgColor // Same chip color
        chipCenterView.translatesAutoresizingMaskIntoConstraints = false
        // Add subtle shadow to create recessed effect
        chipCenterView.layer.shadowColor = UIColor.black.cgColor
        chipCenterView.layer.shadowRadius = 2
        chipCenterView.layer.shadowOpacity = 0.2
        chipCenterView.layer.shadowOffset = CGSize(width: 0, height: 1)
        pokerChipView.addSubview(chipCenterView)
        
        // Raised dollar sign - embossed effect
        let dollarLabel = UILabel()
        dollarLabel.text = "$"
        dollarLabel.font = UIFont.systemFont(ofSize: 28, weight: .black)
        dollarLabel.textColor = UIColor(red: 14/255.0, green: 110/255.0, blue: 192/255.0, alpha: 1.0)
        dollarLabel.textAlignment = .center
        dollarLabel.translatesAutoresizingMaskIntoConstraints = false
        // Add embossed shadow effect
        dollarLabel.layer.shadowColor = UIColor.black.cgColor
        dollarLabel.layer.shadowRadius = 1
        dollarLabel.layer.shadowOpacity = 0.3
        dollarLabel.layer.shadowOffset = CGSize(width: 1, height: 1)
        chipCenterView.addSubview(dollarLabel)
        
        NSLayoutConstraint.activate([
            pokerChipView.centerXAnchor.constraint(equalTo: logoContainer.centerXAnchor),
            pokerChipView.centerYAnchor.constraint(equalTo: logoContainer.centerYAnchor),
            pokerChipView.widthAnchor.constraint(equalToConstant: 120),
            pokerChipView.heightAnchor.constraint(equalToConstant: 120),
            
            chipCenterView.centerXAnchor.constraint(equalTo: pokerChipView.centerXAnchor),
            chipCenterView.centerYAnchor.constraint(equalTo: pokerChipView.centerYAnchor),
            chipCenterView.widthAnchor.constraint(equalToConstant: 50), // Smaller inner circle
            chipCenterView.heightAnchor.constraint(equalToConstant: 50),
            
            dollarLabel.centerXAnchor.constraint(equalTo: chipCenterView.centerXAnchor),
            dollarLabel.centerYAnchor.constraint(equalTo: chipCenterView.centerYAnchor)
        ])
    }
    
    private func addAuthenticRimEdges() {
        // Create authentic poker chip trim edges - 8 scalloped spokes around the rim
        let spokeCount = 8
        let chipRadius: CGFloat = 60
        let innerRadius: CGFloat = 45 // Start closer to center
        let outerRadius: CGFloat = 56 // End closer to edge
        
        for i in 0..<spokeCount {
            let spokeAngle = (CGFloat(i) / CGFloat(spokeCount)) * 2 * CGFloat.pi
            let spokeWidth: CGFloat = (2 * CGFloat.pi * chipRadius) / (CGFloat(spokeCount) * 2) // Half the circumference divided by spoke count
            
            // Create scalloped spoke path
            let spokePath = UIBezierPath()
            
            // Start angle for this spoke
            let startAngle = spokeAngle - (spokeWidth / chipRadius) / 2
            let endAngle = spokeAngle + (spokeWidth / chipRadius) / 2
            
            // Create arc from inner to outer radius
            spokePath.addArc(withCenter: CGPoint(x: 60, y: 60), // Center of chip
                           radius: innerRadius,
                           startAngle: startAngle,
                           endAngle: endAngle,
                           clockwise: true)
            
            spokePath.addArc(withCenter: CGPoint(x: 60, y: 60),
                           radius: outerRadius,
                           startAngle: endAngle,
                           endAngle: startAngle,
                           clockwise: false)
            
            spokePath.close()
            
            // Create shape layer for spoke
            let spokeLayer = CAShapeLayer()
            spokeLayer.path = spokePath.cgPath
            spokeLayer.fillColor = UIColor.white.withAlphaComponent(0.8).cgColor
            spokeLayer.strokeColor = UIColor.clear.cgColor
            
            pokerChipView.layer.addSublayer(spokeLayer)
        }
    }
    
    private func setupCardSuits() {
        cardSuitStack.axis = .horizontal
        cardSuitStack.distribution = .equalSpacing
        cardSuitStack.spacing = 20
        cardSuitStack.alpha = 0
        cardSuitStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cardSuitStack)
        
        let suits = ["♠️", "♥️", "♣️", "♦️"]
        let colors = [UIColor.white, UIColor.red, UIColor.white, UIColor.red]
        
        for (index, suit) in suits.enumerated() {
            let suitLabel = UILabel()
            suitLabel.text = suit
            suitLabel.font = UIFont.systemFont(ofSize: 28)
            suitLabel.textColor = colors[index]
            suitLabel.textAlignment = .center
            suitLabel.layer.shadowColor = UIColor.black.cgColor
            suitLabel.layer.shadowRadius = 2
            suitLabel.layer.shadowOpacity = 0.8
            suitLabel.layer.shadowOffset = CGSize(width: 1, height: 1)
            cardSuitStack.addArrangedSubview(suitLabel)
        }
    }
    
    private func setupPokerChipParticles() {
        particleEmitter.emitterPosition = CGPoint(x: view.bounds.width / 2, y: -50)
        particleEmitter.emitterShape = .line
        particleEmitter.emitterSize = CGSize(width: view.bounds.width, height: 1)
        
        let cell = CAEmitterCell()
        cell.birthRate = 1
        cell.lifetime = 25.0
        cell.velocity = 30
        cell.velocityRange = 15
        cell.emissionLongitude = .pi
        cell.spinRange = 10
        cell.scale = 0.3
        cell.scaleRange = 0.2
        cell.color = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 0.3).cgColor // Gold chips
        cell.alphaSpeed = -0.04
        cell.contents = createPokerChipImage().cgImage
        
        particleEmitter.emitterCells = [cell]
        view.layer.addSublayer(particleEmitter)
    }
    
    private func createPokerChipImage() -> UIImage {
        let size = CGSize(width: 40, height: 40)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        
        // Draw chip body with custom blue color
        UIColor(red: 14/255.0, green: 110/255.0, blue: 192/255.0, alpha: 1.0).setFill()
        UIBezierPath(ovalIn: CGRect(origin: .zero, size: size)).fill()
        
        // Draw inner circle
        UIColor.white.setFill()
        let innerRect = CGRect(x: 12, y: 12, width: 16, height: 16)
        UIBezierPath(ovalIn: innerRect).fill()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    private func performAdvancedAnimations() {
        // Reduced total animation time from ~3.5s to ~2.2s
        
        // Poker chip entrance with rotation and scale - reduced from 1.2s to 0.8s
        logoContainer.transform = CGAffineTransform(scaleX: 0.3, y: 0.3).rotated(by: CGFloat.pi)
        
        UIView.animate(withDuration: 0.8, delay: 0.2, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: .curveEaseOut) {
            self.logoContainer.alpha = 1
            self.logoContainer.transform = CGAffineTransform.identity
        }
        
        // Add optimized pulsing glow effect to chip
        addPokerChipGlow()
        
        // Card suits cascade animation - starts earlier and faster
        animateCardSuits()
        
        // Title slide in with bounce - reduced from 0.9s to 0.6s, starts earlier
        titleLabel.transform = CGAffineTransform(translationX: 0, y: 60).scaledBy(x: 0.8, y: 0.8)
        UIView.animate(withDuration: 0.6, delay: 0.5, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.6, options: .curveEaseOut) {
            self.titleLabel.alpha = 1
            self.titleLabel.transform = CGAffineTransform.identity
        }
        
        // Subtitle golden fade-in - reduced from 0.8s to 0.5s, starts earlier
        UIView.animate(withDuration: 0.5, delay: 0.8, options: .curveEaseIn) {
            self.subtitleLabel.alpha = 1
        }
        
        // Transition after reduced delay - from 3.5s to 2.2s
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            self.transitionToMainApp()
        }
    }
    
    private func addPokerChipGlow() {
        pokerChipView.layer.shadowColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0).cgColor
        pokerChipView.layer.shadowRadius = 25
        pokerChipView.layer.shadowOpacity = 0
        pokerChipView.layer.shadowOffset = .zero
        
        // Reduced glow animation from 2.0s to 1.5s
        let glowAnimation = CABasicAnimation(keyPath: "shadowOpacity")
        glowAnimation.fromValue = 0
        glowAnimation.toValue = 0.9
        glowAnimation.duration = 1.5
        glowAnimation.autoreverses = true
        glowAnimation.repeatCount = .infinity
        pokerChipView.layer.add(glowAnimation, forKey: "chipGlow")
        
        // Reduced rotation animation from 8.0s to 6.0s
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0
        rotateAnimation.toValue = CGFloat.pi * 2
        rotateAnimation.duration = 6.0
        rotateAnimation.repeatCount = .infinity
        pokerChipView.layer.add(rotateAnimation, forKey: "chipRotate")
    }
    
    private func animateCardSuits() {
        let suitViews = cardSuitStack.arrangedSubviews
        
        for (index, suitView) in suitViews.enumerated() {
            suitView.transform = CGAffineTransform(translationX: 0, y: -30).scaledBy(x: 0.5, y: 0.5)
            
            // Reduced duration from 0.6s to 0.4s, starts earlier
            UIView.animate(withDuration: 0.4, delay: 0.4 + Double(index) * 0.08, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseOut) {
                self.cardSuitStack.alpha = 1
                suitView.transform = CGAffineTransform.identity
            }
            
            // Reduced bounce effect duration from 1.5s to 1.0s
            UIView.animate(withDuration: 1.0, delay: 1.0 + Double(index) * 0.15, options: [.repeat, .autoreverse, .curveEaseInOut]) {
                suitView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            }
        }
    }
    
    private func transitionToMainApp() {
        // Create tab bar controller with proper setup to prevent navigation animations
        let tabBar = createTabBarController()
        
        let keyWindow: UIWindow?
        if let scene = view.window?.windowScene {
            keyWindow = scene.windows.first(where: { $0.isKeyWindow })
        } else if let windowScene = UIApplication.shared.connectedScenes
                    .first(where: { $0.activationState == .foregroundActive && $0 is UIWindowScene }) as? UIWindowScene {
            keyWindow = windowScene.windows.first(where: { $0.isKeyWindow })
        } else {
            keyWindow = UIApplication.shared.delegate?.window ?? nil
        }
        guard let window = keyWindow else { return }
        
        // Add tab bar view as subview first (this prevents any root controller animations)
        tabBar.view.frame = window.bounds
        tabBar.view.alpha = 0
        window.addSubview(tabBar.view)
        
        // Fade to tab bar
        UIView.animate(withDuration: 0.3, animations: {
            tabBar.view.alpha = 1
        }) { _ in
            // Now set as root controller and clean up
            window.rootViewController = tabBar
            // The old launch screen controller will be automatically deallocated
        }
    }
    
    private func createTabBarController() -> UITabBarController {
        // Pre-configure navigation bar appearance globally to prevent any animations
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
        
        // Apply globally to prevent any transition animations
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().prefersLargeTitles = false
        
        // Create placeholder view controllers with proper setup
        let currentVC = CurrentSessionViewController()
        currentVC.view.backgroundColor = .systemBackground
        currentVC.title = "Current Session"
        // Disable any potential view animations
        currentVC.view.layer.removeAllAnimations()
        let currentNav = UINavigationController(rootViewController: currentVC)
        currentNav.tabBarItem = UITabBarItem(title: "Current", image: UIImage(systemName: "gamecontroller.fill"), tag: 0)
        
        let usersVC = UsersViewController()
        usersVC.view.backgroundColor = .systemBackground
        usersVC.title = "Players"
        usersVC.view.layer.removeAllAnimations()
        let usersNav = UINavigationController(rootViewController: usersVC)
        usersNav.tabBarItem = UITabBarItem(title: "Players", image: UIImage(systemName: "person.3.fill"), tag: 1)
        
        let sessionsVC = SessionsViewController()
        sessionsVC.view.backgroundColor = .systemBackground
        sessionsVC.title = "History"
        sessionsVC.view.layer.removeAllAnimations()
        let sessionsNav = UINavigationController(rootViewController: sessionsVC)
        sessionsNav.tabBarItem = UITabBarItem(title: "History", image: UIImage(systemName: "clock.fill"), tag: 2)
        
        let tabBar = UITabBarController()
        tabBar.viewControllers = [currentNav, usersNav, sessionsNav]
        tabBar.tabBar.tintColor = .systemBlue
        tabBar.tabBar.backgroundColor = .systemBackground
        
        // Force immediate appearance configuration for all navigation controllers
        for navController in tabBar.viewControllers as! [UINavigationController] {
            navController.navigationBar.standardAppearance = appearance
            navController.navigationBar.scrollEdgeAppearance = appearance
            navController.navigationBar.compactAppearance = appearance
            navController.navigationBar.prefersLargeTitles = false
            
            // Disable navigation bar animations completely
            navController.navigationBar.layer.removeAllAnimations()
            navController.view.layer.removeAllAnimations()
            
            // Force layout immediately to prevent any transition animations
            navController.navigationBar.setNeedsLayout()
            navController.navigationBar.layoutIfNeeded()
        }
        
        // Disable any potential tab bar animations
        tabBar.view.layer.removeAllAnimations()
        tabBar.tabBar.layer.removeAllAnimations()
        
        return tabBar
    }
}
