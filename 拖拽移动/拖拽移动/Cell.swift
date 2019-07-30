//
//  Cell.swift
//  拖拽移动
//
//  Created by 刘志鹏 on 2019/7/30.
//  Copyright © 2019 lzp. All rights reserved.
//

import UIKit

class Cell: UICollectionViewCell {

    let title = UILabel()
    let close = UIButton()
    var deleteClick: ((Cell) -> Void)?
    var model: Model? {
        didSet {
            self.title.text = model?.title
            if (model?.status ?? 0) == 0 {
                close.setTitle("X", for: .normal)
                close.setTitleColor(UIColor.black, for: .normal)
                close.isEnabled = true
            } else {
                close.setTitle("+", for: .normal)
                close.setTitleColor(UIColor.green, for: .normal)
                close.isEnabled = false
            }
        }
    }

    override init(frame: CGRect) {
        let wid = UIScreen.main.bounds.size.width / 3
        super.init(frame: frame)
        title.layer.borderColor = UIColor(hue: 0.4, saturation: 0.4, brightness: 0.4, alpha: 1).cgColor
        title.layer.borderWidth = 1
        title.layer.cornerRadius = 4
        title.backgroundColor = UIColor(hue: 0.4, saturation: 0.4, brightness: 0.4, alpha: 0.5)
        title.textColor = UIColor.red
        title.textAlignment = .center
        title.font = UIFont.systemFont(ofSize: 16)
        self.contentView.addSubview(title)
        title.frame = CGRect(x: 10, y: 5, width: wid - 20, height: 40)

        close.setTitle("X", for: .normal)
        close.setTitleColor(UIColor.black, for: .normal)
        close.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        self.contentView.addSubview(close)
        self.close.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        self.close.addTarget(self, action: #selector(deleAction), for: .touchUpInside)
    }

    @objc func deleAction() {
        deleteClick?(self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
