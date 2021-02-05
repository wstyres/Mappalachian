//
//  TextInputTableViewCell.swift
//  Mappalachian
//
//  Created by Wilson Styres on 2/1/21.
//

import UIKit

class TextInputTableViewCell: UITableViewCell {

    var textField: UITextField = UITextField()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.contentView.addSubview(textField)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("initWithCoder not implemented")
    }
    
    override func layoutSubviews() {
        self.contentView.addSubview(textField)
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            textField.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
            textField.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: self.separatorInset.left),
            textField.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: self.separatorInset.right),
        ])
        textField.translatesAutoresizingMaskIntoConstraints = false
    }

}
