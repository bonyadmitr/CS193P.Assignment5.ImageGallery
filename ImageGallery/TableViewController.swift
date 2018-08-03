//
//  TableViewController.swift
//  ImageGallery
//
//  Created by Evgeniy Ziangirov on 21/07/2018.
//  Copyright © 2018 Evgeniy Ziangirov. All rights reserved.
//

import UIKit

protocol DataForImageGalleryViewController: class {
    var gallery: ImageGallery { get set }
}

class TableViewController: UITableViewController, DataForTableViewController, GalleryCellDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNavigationController()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if splitViewController?.preferredDisplayMode != .primaryOverlay {
            splitViewController?.preferredDisplayMode = .primaryOverlay
        }
    }
    
    var gallery = ImageGallery() {
        didSet {
            galleryInsert.indices.forEach {
                if galleryInsert[$0].identifier == gallery.identifier {
                    galleryInsert[$0] = gallery
                    tableView?.reloadData()
                }
            }
        }
    }
    
    private var galleryInsert = [ImageGallery]()
    private var galleryRemove = [ImageGallery]()
    private var galleries: [[ImageGallery]] {
        return [galleryInsert, galleryRemove]
    }
    
    private func setupTableView() {
        tableView?.separatorStyle = .singleLine
        tableView?.dataSource = self
        tableView?.delegate = self
        
        tableView?.backgroundColor = .lead
        tableView?.sectionHeaderHeight = 48
        tableView?.rowHeight = 48
        tableView?.isOpaque = false
        tableView?.alpha = 0.90
        
        tableView?.register(GalleryCell.self, forCellReuseIdentifier: "galleryTableCell")
    }
    
    private func setupNavigationController() {
        navigationController?.navigationBar.barStyle = .blackTranslucent
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.alpha = 0
        
        navigationItem.title = "Galleries"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: #selector(addMoreGallery))
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 0 else { return }
        for vc in splitViewController?.viewControllers ?? [] {
            if let detailNC = vc.contents as? DataForImageGalleryViewController {
                let galleries = galleryInsert + galleryRemove
                detailNC.gallery = galleries[indexPath.item]
                break
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return galleries.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return galleries[section].count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Galleries"
        case 1: return "Recently Deleted"
        default: return "Default"
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "galleryTableCell", for: indexPath)
        if let galleryCell = cell as? GalleryCell {
            let gallery = galleries[indexPath.section][indexPath.row]
            galleryCell.delegate = self
            galleryCell.textField.text = gallery.title
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            if indexPath.section == 0 {
                let remove = galleryInsert.remove(at: indexPath.row)
                galleryRemove.append(remove)
                tableView.moveRow(at: indexPath, to: IndexPath(row: 0, section: 1))
            } else {
                galleryRemove.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.section == 1 {
            let undelete = UIContextualAction(style: .destructive, title: "Restore") { _, _, completionHandler in
                let gallery = self.galleries[indexPath.section][indexPath.row]
                self.galleryRemove.remove(at: indexPath.row)
                self.galleryInsert.insert(gallery, at: 0)
                completionHandler(true)
                tableView.moveRow(at: indexPath, to: IndexPath(row: 0, section: 0))
                tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
            }
            undelete.backgroundColor = .clover
            return UISwipeActionsConfiguration(actions: [undelete])
        } else {
            return nil
        }
    }
    
    @objc func addMoreGallery(_ sender: UIBarButtonItem) {
        var newGallery = ImageGallery()
        let existingTitles = (galleryInsert + galleryRemove).map { $0.title }
        newGallery.title = "Untitled".madeUnique(withRespectTo: existingTitles)
        galleryInsert.append(newGallery)
        
        let indexPath = IndexPath(row: galleryInsert.count - 1, section: 0)
        tableView.beginUpdates()
        tableView.insertRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
    }
    
    func titleDidChange(_ title: String, in cell: UITableViewCell) {
        if let indexPath = tableView.indexPath(for: cell), indexPath.section == 0 {
            galleryInsert[indexPath.row].title = title
            tableView.reloadData()
        }
    }

}
