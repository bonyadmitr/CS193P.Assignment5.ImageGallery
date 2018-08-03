//
//  ImageGalleryViewController.swift
//  ImageGallery
//
//  Created by Evgeniy Ziangirov on 18/07/2018.
//  Copyright © 2018 Evgeniy Ziangirov. All rights reserved.
//

import UIKit

protocol DataForTableViewController: class {
    var gallery: ImageGallery { get set }
}

class ImageGalleryViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDropDelegate, UICollectionViewDragDelegate, DataForImageGalleryViewController, UIDropInteractionDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupNavigationController()
        addTrashButton()
        
        // MARK: - DOTO: Notifications
    }
    
    var gallery = ImageGallery() {
        didSet {
            for vc in splitViewController?.viewControllers ?? [] {
                if let masterNC = vc.contents as? DataForTableViewController {
                    masterNC.gallery = gallery
                    break
                }
            }
            navigationItem.title = gallery.title
            collectionView?.reloadData()
        }
    }
    
    private let trashBarButtonItem: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .trash, target: nil, action: nil)
    }()
    
    private var flowLayout: UICollectionViewFlowLayout? {
        return collectionView?.collectionViewLayout as? UICollectionViewFlowLayout
    }
    
    private lazy var maximumCellWidth: CGFloat = {
        return defaultCellWidth / 2 - 1
    }()
    
    private lazy var minimumCellWidth: CGFloat = {
        return defaultCellWidth / 3 - 1
    }()
    
    private lazy var imageCellScale: CGFloat = {
        return 1.0
    }()
    
    private lazy var defaultCellWidth: CGFloat = {
        return min(view.bounds.height, view.bounds.width)
    }()
    
    private func setupCollectionView() {
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.dragDelegate = self
        
        collectionView?.backgroundColor = .lead
        
        collectionView?.register(ImageCell.self, forCellWithReuseIdentifier: "cellId")
        let gesture = UIPinchGestureRecognizer(target: self, action: #selector(scaleCell))
        collectionView?.addGestureRecognizer(gesture)
    }
    
    private func setupNavigationController() {
        navigationController?.navigationBar.barStyle = .blackTranslucent
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.alpha = 0
    }
    
    private func addTrashButton() {
        navigationController?.navigationBar.addInteraction(UIDropInteraction(delegate: self))
        navigationItem.rightBarButtonItem = trashBarButtonItem
    }
    
    @objc private func scaleCell(_ reconizer: UIPinchGestureRecognizer) {
        guard minimumCellWidth <= maximumCellWidth else { return }
        switch reconizer.state {
        case .changed, .ended:
            let scaledWidth = imageCellScale * reconizer.scale
            if (minimumCellWidth...maximumCellWidth).contains(minimumCellWidth * scaledWidth) {
                imageCellScale = scaledWidth
                flowLayout?.invalidateLayout()
            }
            reconizer.scale = 1
        default:
            break
        }
    }
    
    // MARK: - UIContentContainer
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        let isPortrait = size.width < size.height
        defaultCellWidth = isPortrait ? view.bounds.height : view.bounds.width
        flowLayout?.invalidateLayout()
    }
    
    // MARK: - UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return gallery.images.count
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath)
        if let imageCell = cell as? ImageCell {
            let image = gallery.images[indexPath.item]
            imageCell.imageURL = image.imagePath
        }
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView,
                                 didSelectItemAt indexPath: IndexPath) {
        let detailVC = ImageViewController(nibName: nil, bundle: nil)
        let item = gallery.images[indexPath.item]
        detailVC.imageURL = item.imagePath
        navigationController?.pushViewController(detailVC, animated: false)
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = (defaultCellWidth / 3 - 1) * imageCellScale
        return CGSize(width: cellWidth, height: cellWidth / gallery.images[indexPath.item].aspectRatio)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    // MARK: - UICollectionViewDragDelegate
    
    func collectionView(_ collectionView: UICollectionView,
                        itemsForBeginning session: UIDragSession,
                        at indexPath: IndexPath) -> [UIDragItem] {
        session.localContext = collectionView
        return dragItems(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        itemsForAddingTo session: UIDragSession,
                        at indexPath: IndexPath,
                        point: CGPoint) -> [UIDragItem] {
        return dragItems(at: indexPath)
    }
    
    private func dragItems(at indexPath: IndexPath) -> [UIDragItem] {
        if let imageURL = (collectionView?.cellForItem(at: indexPath) as? ImageCell)?.imageURL as NSURL? {
            let dragItem = UIDragItem(itemProvider: NSItemProvider(object: imageURL))
            dragItem.localObject = imageURL
            return [dragItem]
        } else {
            return []
        }
    }
    
    // MARK: - UICollectionViewDropDelegate
    
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        let validValues = [
            session.canLoadObjects(ofClass: NSURL.self),
            session.canLoadObjects(ofClass: NSURL.self) && session.canLoadObjects(ofClass: UIImage.self)
        ]
        return collectionView.hasActiveDrag ? validValues[0] : validValues[1]
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        dropSessionDidUpdate session: UIDropSession,
                        withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        let isSelf = (session.localDragSession?.localContext as? UICollectionView) == collectionView
        
        return UICollectionViewDropProposal(operation: isSelf ? .move : .copy, intent: .insertAtDestinationIndexPath)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        performDropWith coordinator: UICollectionViewDropCoordinator
        ) {
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
        for item in coordinator.items {
            if let sourceIndexPath = item.sourceIndexPath {
                if let url = item.dragItem.localObject as? URL {
                    collectionView.performBatchUpdates({
                        let aspectRatio = gallery.images[sourceIndexPath.item].aspectRatio
                        let image = ImageGallery.Image(imagePath: url, aspectRatio: aspectRatio)
                        gallery.images.remove(at: sourceIndexPath.item)
                        gallery.images.insert(image, at: destinationIndexPath.item)
                        collectionView.deleteItems(at: [sourceIndexPath])
                        collectionView.insertItems(at: [destinationIndexPath])
                    })
                    coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
                }
            } else {
                let placeholderContext = coordinator.drop(
                    item.dragItem,
                    to: UICollectionViewDropPlaceholder(
                        insertionIndexPath: destinationIndexPath,
                        reuseIdentifier: "cellId"
                    )
                )
                var aspectRatio = CGFloat()
                item.dragItem.itemProvider.loadObject(ofClass: UIImage.self) { provider, error in
                    DispatchQueue.main.async {
                        if let image = provider as? UIImage {
                            aspectRatio = image.size.aspectRatio
                        }
                    }
                }
                item.dragItem.itemProvider.loadObject(ofClass: NSURL.self) { (provider, err) in
                    DispatchQueue.main.async {
                        if let imageURL = (provider as? URL)?.embeddedImageURL {
                            placeholderContext.commitInsertion(dataSourceUpdates: { insertionIndexPath in
                                let image = ImageGallery.Image(imagePath: imageURL, aspectRatio: aspectRatio)
                                self.gallery.images.insert(image, at: insertionIndexPath.item)
                            })
                        } else {
                            placeholderContext.deletePlaceholder()
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - UIDropInteractionDelegate
    
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: URL.self)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        if let view = trashBarButtonItem.value(forKey: "view") as? UIView {
        let dropPoint = session.location(in: view)
            if abs(dropPoint.x) <= view.bounds.width && dropPoint.y <= view.bounds.height {
                return UIDropProposal(operation: .move)
            }
        }
        return UIDropProposal(operation: .cancel)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        guard let item = session.items.first else { return }
        guard let droppedImageURL = item.localObject as? URL else { return }
        var index: Int = 0
        gallery.images.indices.forEach {
            if gallery.images[$0].imagePath == droppedImageURL {
                index = $0
            }
        }
        collectionView?.performBatchUpdates({
            let indexPath = IndexPath(item: index, section: 0)
            gallery.images.remove(at: index)
            collectionView?.deleteItems(at: [indexPath])
        })
    }

}
