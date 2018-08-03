//
//  GalleryCell.swift
//  ImageGallery
//
//  Created by Evgeniy Ziangirov on 23/07/2018.
//  Copyright © 2018 Evgeniy Ziangirov. All rights reserved.
//

import UIKit

protocol GalleryCellDelegate {
    func titleDidChange(_ title: String, in cell: UITableViewCell)
}

class GalleryCell: UITableViewCell, UITextFieldDelegate {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        
        textField.delegate = self
        textField.clearsOnBeginEditing = false
        textField.isUserInteractionEnabled = false
        
        textField.addTarget(self, action: #selector(titleDidChange(_:)), for: .editingDidEnd)
        textField.returnKeyType = .done
        textField.keyboardType = .alphabet
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(editName(_:)))
        tap.numberOfTapsRequired = 2
        self.addGestureRecognizer(tap)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let textField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .lead
        textField.alpha = 0.90
        textField.textColor = .white
        return textField
    }()
    
    var delegate: GalleryCellDelegate?
    
    private var title: String {
        set {
            textField.text = newValue
        }
        get {
            return textField.text ?? ""
        }
    }
    
    private func setupViews() {
        backgroundColor = .lead
        alpha = 0.90
        contentView.addSubview(textField)
        contentView.activateConstraints(withVisualFormat: "H:|-[v0]-|", for: textField)
        contentView.activateConstraints(withVisualFormat: "V:|-[v0]-|", for: textField)
    }

    @objc private func editName(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            textField.isUserInteractionEnabled = true
            textField.becomeFirstResponder()
        }
    }
    
    @objc func titleDidChange(_ sender: UITextField) {
        guard let title = sender.text, title != "" else { return }
        delegate?.titleDidChange(sender.text ?? "", in: self)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textField.isUserInteractionEnabled = false
        return true
    }

}
