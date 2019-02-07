//
//  DocumentBrowserViewController.swift
//  Document_Emoji
//
//  Created by 无敌帅的yyyyy on 2019/2/6.
//  Copyright © 2019年 无敌帅的yyyy. All rights reserved.
//

import UIKit


class DocumentBrowserViewController: UIDocumentBrowserViewController, UIDocumentBrowserViewControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        allowsDocumentCreation = false
        allowsPickingMultipleItems = false
        templates = try? FileManager.default.url(for: .applicationDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        template = template?.appendingPathComponent("untitled.json")
        if template != nil{
            allowsDocumentCreation = FileManager.default.createFile(atPath: template!.absoluteString, contents: Data(), attributes: nil)
        }
    }
    
    var template:URL?
    var templates:URL?
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didRequestDocumentCreationWithHandler importHandler: @escaping (URL?, UIDocumentBrowserViewController.ImportMode) -> Void) {
        importHandler(template,.copy)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didPickDocumentsAt documentURLs: [URL]) {
        guard let sourceURL = documentURLs.first else { return }
        
        // Present the Document View Controller for the first document that was picked.
        // If you support picking multiple items, make sure you handle them all.
        presentDocument(at: sourceURL)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didImportDocumentAt sourceURL: URL, toDestinationURL destinationURL: URL) {
        // Present the Document View Controller for the new newly created document
        presentDocument(at: destinationURL)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, failedToImportDocumentAt documentURL: URL, error: Error?) {
        // Make sure to handle the failed import appropriately, e.g., by presenting an error message to the user.
    }
    
    // MARK: Document Presentation
    
    func presentDocument(at documentURL: URL) {
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let documentMC = storyBoard.instantiateViewController(withIdentifier: "Document")
        if let emojiartVC = documentMC.contents as? ViewController{
            emojiartVC.document = Document(fileURL:documentURL)
        }
        present(documentMC,animated: true)
    }
    //Info.plist
}

