//
//  LevelPickerView.swift
//  Mappalachian
//
//  Created by Wilson Styres on 2/20/21.
//

import UIKit

protocol LevelPickerDelegate {
    func selectLevel(ordinal: Int)
}

class LevelPickerView: UIView {
    var blurView: UIVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .prominent))
    var stackView: UIStackView = UIStackView()
    var delegate: LevelPickerDelegate?
    
    var levelNames: [String] = [] {
        didSet {
            let animation = CATransition()
            animation.duration = 0.25
            animation.type = .fade
            
            layer.add(animation, forKey: "fadeLevels")
            
            let existingViews = stackView.arrangedSubviews
            for view in existingViews {
                view.removeFromSuperview()
            }

            for (index, name) in levelNames.enumerated() {
                let button = UIButton()
                button.setTitle(name, for: .normal)
                button.titleLabel?.font = UIFont.monospacedSystemFont(ofSize: button.titleLabel!.font.pointSize, weight: .medium)
                button.setTitleColor(.label, for: .normal)
                button.heightAnchor.constraint(equalToConstant: 50).isActive = true
                button.tag = index
                button.addTarget(self, action: #selector(selectedLevel(sender:)), for: .touchUpInside)

                stackView.addArrangedSubview(button)
            }
        }
    }
    
    var selectedLevel: Int? {
        didSet {
            if let oldLevel = oldValue, oldLevel >= 0 && oldLevel < stackView.arrangedSubviews.count {
                stackView.arrangedSubviews[oldLevel].backgroundColor = nil
            }

            if let newLevel = selectedLevel, newLevel >= 0 && newLevel < stackView.arrangedSubviews.count {
                stackView.arrangedSubviews[newLevel].backgroundColor = UIColor.systemBackground
                delegate?.selectLevel(ordinal: newLevel)
            }
        }
    }
    
    init() {
        super.init(frame: .zero)
        
        stackView.axis = .vertical
        blurView.contentView.addSubview(stackView)
        self.addSubview(blurView)
        
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: self.topAnchor),
            blurView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            blurView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        ])
        blurView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: blurView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: blurView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: blurView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: blurView.trailingAnchor),
        ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        blurView.layer.cornerRadius = 10
        blurView.layer.masksToBounds = true
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.layer.shadowOpacity = 0.4
        self.layer.shadowRadius = 3.0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func selectedLevel(sender: UIButton) {
        let selectedIndex = sender.tag
        if selectedIndex >= 0 && selectedIndex < levelNames.count {
            self.selectedLevel = selectedIndex
        }
    }

}
