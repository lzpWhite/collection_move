//
//  ViewController.swift
//  拖拽移动
//
//  Created by 刘志鹏 on 2019/7/30.
//  Copyright © 2019 lzp. All rights reserved.
//

import UIKit

class Model {
    var title = ""
    var type = 0  // 0 表示在删除的分组
    var status = 0 // 0 表示删除， 1添加
}

class ViewController: UIViewController {
    var dataSource: [[Model]] = []

    let collection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: UIScreen.main.bounds.size.width / 3, height: 50)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.register(Cell.self, forCellWithReuseIdentifier: "Cell")
        return cv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        var first: [Model] = []
        for item in 0..<10 {
            let model = Model()
            model.type = [1, 2, 3].randomElement() ?? 1
            model.title = "删除 \(item)"
            model.status = 0
            first.append(model)
        }

        var second: [Model] = []
        for item in 0..<10 {
            let model = Model()
            model.type = 1
            model.title = "第二个规划 \(item)"
            model.status = 1
            second.append(model)
        }

        var disange: [Model] = []
        for item in 0..<10 {
            let model = Model()
            model.type = 1
            model.title = "第三个规划 \(item)"
            model.status = 1
            disange.append(model)
        }

        var disige: [Model] = []
        for item in 0..<10 {
            let model = Model()
            model.type = 1
            model.title = "第四个规划 \(item)"
            model.status = 1
            disige.append(model)
        }

        self.collection.backgroundColor = .white
        self.collection.delegate = self
        self.collection.dataSource = self
        dataSource = [first, second, disange, disige]
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction(longPress:)))
        collection.addGestureRecognizer(longGesture)
        collection.frame = CGRect(x: 0, y: 100, width: self.view.frame.size.width, height: self.view.frame.size.height - 100)
        self.view.addSubview(collection)

        // Do any additional setup after loading the view.
    }

    @objc public func longPressAction(longPress: UILongPressGestureRecognizer) {
        switch longPress.state {
        case .began:
            guard let index = collection.indexPathForItem(at: longPress.location(in: collection)) else { return }
            guard let model = self.getModel(indexPath: index), model.status == 0 else { return }
            guard let cell = collection.cellForItem(at: index) else { return }
            collection.bringSubviewToFront(cell)
            collection.beginInteractiveMovementForItem(at: index)
        case .changed:
            // 控制是否可以拖拽到某个组内
            let point = longPress.location(in: self.collection)
            if let index = self.collection.indexPathForItem(at: point), index.section == 0 {
                collection.updateInteractiveMovementTargetPosition(point)
            }
        case .ended:
            collection.endInteractiveMovement()
        default:
            collection.cancelInteractiveMovement()
        }
    }

}

extension Array where Element: Equatable {

    public mutating func remove(object: Element) {
        if let index = firstIndex(of: object) {
            remove(at: index)
        }
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.dataSource.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return getSectionArray(section: section)?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? Cell {
            cell.model = getModel(indexPath: indexPath)
            cell.deleteClick = { [weak self] (dcell) in
                self?.deleAddClick(cell: dcell)
            }
            return cell
        }
        return UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        guard let model = getModel(indexPath: indexPath) else { return false }
        return model.status == 0
    }

    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard let model = getModel(indexPath: sourceIndexPath) else { return }
        var modes = getSectionArray(section: sourceIndexPath.section)
        modes?.remove(at: sourceIndexPath.item)
        modes?.insert(model, at: destinationIndexPath.item)
        self.dataSource[sourceIndexPath.section] = modes ?? []
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let model = self.getModel(indexPath: indexPath), model.status != 0 else { return }
        guard var models = self.getSectionArray(section: indexPath.section) else { return }
        guard var first = self.getSectionArray(section: 0) else { return }
        model.status = 0
        first.append(model)
        models.remove(at: indexPath.item)
        self.dataSource[0] = first
        self.dataSource[indexPath.section] = models
        self.collection.reloadData()
    }

    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        UIView.animate(withDuration: 0.28) { [weak cell] in
            cell?.transform = CGAffineTransform.init(scaleX: 1.2, y: 1.2)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        UIView.animate(withDuration: 0.28) { [weak cell] in
            cell?.transform = CGAffineTransform.init(scaleX: 1, y: 1)
        }
    }

    func getModel(indexPath: IndexPath) -> Model? {
        guard indexPath.section < self.dataSource.count else { return nil }
        guard indexPath.item < self.dataSource[indexPath.section].count else { return nil }
        return self.dataSource[indexPath.section][indexPath.item]
    }

    func getSectionArray(section: Int) -> [Model]? {
        guard section < self.dataSource.count else { return nil }
        return self.dataSource[section]
    }

    @objc func deleAddClick(cell: Cell) {
        guard let indexPath = collection.indexPath(for: cell) else { return }
        guard var models = self.getSectionArray(section: indexPath.section) else { return }
        guard let model = self.getModel(indexPath: indexPath) else { return }
        guard var old = self.getSectionArray(section: model.type) else { return }
        model.status = 1
        old.append(model)
        models.remove(at: indexPath.item)

        self.dataSource[indexPath.section] = models
        self.dataSource[model.type] = old
        self.collection.reloadData()
    }

}
