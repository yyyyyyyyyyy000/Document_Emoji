//
//  ViewController.swift
//  Drag&Drop
//
//  Created by 无敌帅的yyyyy on 2019/1/25.
//  Copyright © 2019年 无敌帅的yyyy. All rights reserved.
//

import UIKit
import MobileCoreServices
class ViewController: UIViewController ,UIDropInteractionDelegate,UIScrollViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UICollectionViewDragDelegate,UICollectionViewDropDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "modal"{
            let vc = segue.destination.contents as? DocumentViewController
            document?.thumbnail = emojiview.snapshot
            vc?.document = document
        }else if segue.identifier == "embed"{
            documentinfo = segue.destination.contents as? DocumentViewController
        }
    }
    
    @IBAction func takePhoto(_ sender: UIBarButtonItem) {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.mediaTypes = [kUTTypeImage as String]
        picker.allowsEditing = true
        picker.delegate = self
        present(picker,animated: true)
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated:true)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = (info[UIImagePickerController.InfoKey.editedImage] ?? info[UIImagePickerController.InfoKey.originalImage]) as? UIImage{
            let url = image.storeLocallyAsJPEG(named: String(Date.timeIntervalSinceReferenceDate))
            backimage = (url,image)
        }
        dismiss(animated: true)
    }
    
    
    @IBOutlet weak var camera: UIBarButtonItem!{
        didSet{
            camera.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        }
    }
    
    
    @IBOutlet weak var Dropzone: UIView!
    lazy var emojiview = emojiView()
    
    private var documentinfo:DocumentViewController?
    
    
    @IBAction func done(_ sender: UIBarButtonItem? = nil) {
        NotificationCenter.default.removeObserver(EmojiObserver!)
        save()
        document!.thumbnail = emojiview.snapshot
        dismiss(animated: true){
            self.document?.close{success in
                if let observer = self.DocumentObserver{
                    NotificationCenter.default.removeObserver(observer)
                }
            }
        }
    }
    @IBAction func returnback(forsegue:UIStoryboardSegue){
        done()
    }
    
    
    @IBAction func save(_ sender: UIBarButtonItem? = nil) {
        if let data = emojiart?.json{
            if let urls = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("untitled.json"){
            do{
                    try data.write(to: urls)
                    print("s")
                }catch let error{
                    print("\(error)")
                }
            }
        }
       /*func documenthanged(){
            document?.emojiart = emojiart
            if document?.emojiart != nil{
                document?.updateChangeCount(.done)
            }
        }*/
    }
    
    var document:Document?
    private var DocumentObserver: NSObjectProtocol?
    private var EmojiObserver: NSObjectProtocol?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if document?.documentState != .normal{
        DocumentObserver = NotificationCenter.default.addObserver(forName:UIDocument.stateChangedNotification, object: document, queue: OperationQueue.main, using: {notification in
            print("\(self.document!.documentState)")
            if self.document?.documentState == .normal, let vc = self.documentinfo{
                vc.document = self.document
                //self.width1.constant = vc.preferredContentSize.width
                //self.height1.constant = vc.preferredContentSize.height
          
            }
        })
        
        document?.open(completionHandler: {success in
            if success{
                self.title = self.document?.localizedName
                self.emojiart = self.document?.emojiart
                self.EmojiObserver = NotificationCenter.default.addObserver(forName: Notification.Name.Emojichanged, object: self.emojiview, queue: OperationQueue.main, using: {notification in
                    self.save()
                })
            }
        })}
    }
    override func viewDidLoad(){
        super.viewDidLoad()
         Dropzone.addInteraction(UIDropInteraction(delegate: self))
    }
    
    
    
    
    private var addemoji = false
    
    private var emojiart:emojiArt?{
        get{
            if let url = backimage.url{
                let emoji = emojiview.subviews.compactMap{$0 as? UILabel}.compactMap{emojiArt.EmojiInfo(label:$0)}
                return emojiArt(url: url, emojis: emoji)
            }else{
                return nil
            }
        }
        set{
            backimage = (nil,nil)
            emojiview.subviews.compactMap{$0 as? UILabel}.forEach{$0.removeFromSuperview()}
            if let url = newValue?.url{
                imagefetcher = ImageFetcher(fetch: url, handler: {
                    (url,image) in
                    DispatchQueue.main.async {
                        self.backimage = (url,image)
                        newValue?.emoji.forEach{
                            let attributedtext = $0.text.attributedString(withTextStyle: .body, ofSize: CGFloat($0.size))
                            self.emojiview.addlabel(at: CGPoint(x: $0.x, y: $0.y), title: attributedtext)
                        }
                    }
                })
            }
        }
    }
    
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        height.constant = scrollView.contentSize.height
        width.constant = scrollView.contentSize.width
    }
    
    
    @IBOutlet weak var collectionView: UICollectionView!{
        didSet{
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.dragDelegate = self
            collectionView.dropDelegate = self
            collectionView.dragInteractionEnabled = true
        }
    }
    
    @IBAction func beginText(_ sender: UIButton) {
        addemoji = true
        collectionView.reloadSections(IndexSet(integer:0))
    }
    @IBOutlet weak var scrollview: UIScrollView!{
        didSet{
            scrollview.maximumZoomScale = 8
            scrollview.minimumZoomScale = 1/25
            scrollview.delegate = self
            scrollview.addSubview(emojiview)
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return emojiview
    }
    private var backimage:(url:URL?,image:UIImage?){
        set{
            backUrl = newValue.url
            scrollview?.zoomScale = 1
            emojiview.backgroundimage = newValue.image
            let size = newValue.image?.size ?? CGSize.zero
            height?.constant = size.height
            width?.constant = size.width
            emojiview.frame = CGRect(origin: CGPoint.zero, size: size)
            if let dropzone = self.Dropzone, size.width>0, size.height>0{
                scrollview?.zoomScale = max(dropzone.bounds.size.width/size.width,dropzone.bounds.size.height/size.height)
            }
        }
        get{
            return (backUrl,emojiview.backgroundimage)
        }
    }
    
    private var backUrl:URL?
    
    
    var imagefetcher:ImageFetcher!
    var suppress = false
    private func alertaction(for url:URL){
        if !suppress{
            let alert = UIAlertController(title: "fail", message: url.absoluteString, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "keep", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "stop", style: .destructive, handler: {action in
            self.suppress = true}))
            present(alert,animated: true)
        }
        
    }
    
    
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSURL.self) && session.canLoadObjects(ofClass: UIImage.self)
    }
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        imagefetcher = ImageFetcher(handler: {(url,image) in
            DispatchQueue.main.async {
                self.backimage  = (url,image)
            }
            
        })
        session.loadObjects(ofClass: NSURL.self, completion: {urls in
            if let url = urls.first as? URL {
                DispatchQueue.global(qos: .userInitiated).async {
                    if let imageData = try? Data(contentsOf: url.imageURL),let image = UIImage(data: imageData){
                        DispatchQueue.main.async {
                            self.backimage = (url,image)
                        }
                    }else{
                        self.alertaction(for: url)
                    }
                }
                
            }
        })
        session.loadObjects(ofClass: UIImage.self, completion: {images in
            self.imagefetcher.backup = images.first as? UIImage
        })
    }
    
    var emoji = "😀😃😄😁🤣😂😅😆☺️😊😇🙂😍😌😉🙃😘😗😙😚😜😝😛😋".map{String($0)}
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    @IBOutlet weak var height1: NSLayoutConstraint!
    
    @IBOutlet weak var width1: NSLayoutConstraint!
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section{
        case 0: return 1
        case 1:return emoji.count
        default:
            return 0
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 1{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "emojicell", for: indexPath)
            if let celler = cell as? EmojiCollectionViewCell{
                let text = NSAttributedString(string: emoji[indexPath.item], attributes: [.font:UIFont.preferredFont(forTextStyle: .body).scaled(by: 5)])
                celler.emojilabel.attributedText = text
            }
            return cell
        }else if addemoji{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "text", for: indexPath)
            if let inputcell = cell as? TextCollectionViewCell{
                inputcell.resignhandler = {[weak self,unowned inputcell] in
                    if let text = inputcell.textfield.text{
                        self?.emoji = (text.map{String($0)}+self!.emoji).uniquified
                        self?.addemoji = false
                        self?.collectionView.reloadData()
                    }
                }
            }
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "add", for: indexPath)
            return cell
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if addemoji && indexPath.section == 0{
            return CGSize(width: 300, height: 80)
        }else{
            return CGSize(width: 80, height: 80)
        }
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let inputcell = cell as? TextCollectionViewCell{
            inputcell.textfield.becomeFirstResponder()
        }
    }
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        session.localContext = collectionView
        return dragitem(at:indexPath)
    }
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        return dragitem(at: indexPath)
    }
    private func dragitem(at indexPath:IndexPath)->[UIDragItem]{
        if let attributedstring = (collectionView.cellForItem(at: indexPath) as? EmojiCollectionViewCell)?.emojilabel.attributedText{
            let dragitem = UIDragItem(itemProvider: NSItemProvider(object: attributedstring))
            dragitem.localObject = attributedstring
            return [dragitem]
        }else{
            return []
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSAttributedString.self)
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        let isself = (session.localDragSession?.localContext as? UICollectionView) == collectionView
        return UICollectionViewDropProposal(operation: isself ? .move : .copy, intent: .insertAtDestinationIndexPath)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destinationindexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
        for item in coordinator.items{
            if let sourceindexPath = item.sourceIndexPath{
                if let attributedString = item.dragItem.localObject as? NSAttributedString{
                    collectionView.performBatchUpdates({
                        emoji.insert(attributedString.string, at: destinationindexPath.item)
                        emoji.remove(at: sourceindexPath.item)
                        collectionView.deleteItems(at: [sourceindexPath])
                        collectionView.insertItems(at: [destinationindexPath])
                    })
                    
                    coordinator.drop(item.dragItem, toItemAt: destinationindexPath)
                }
            }else{
                let placeholdercontext  = coordinator.drop(item.dragItem, to: UICollectionViewDropPlaceholder(insertionIndexPath: destinationindexPath, reuseIdentifier: "placeholder"))
                item.dragItem.itemProvider.loadObject(ofClass: NSAttributedString.self, completionHandler:{ (provider,error) in
                    DispatchQueue.main.async {
                        if let attributedstring = provider as? NSAttributedString{
                            placeholdercontext.commitInsertion(dataSourceUpdates: {insertindexpath in
                                self.emoji.insert(attributedstring.string, at: insertindexpath.item)
                            })
                        }else{
                            placeholdercontext.deletePlaceholder()
                        }
                    }
                })
            }
        }
    }
    
    @IBOutlet weak var height: NSLayoutConstraint!
    
    @IBOutlet weak var width: NSLayoutConstraint!
    
}

extension emojiArt.EmojiInfo{
    init?(label:UILabel){
        if let attributedText = label.attributedText, let font = attributedText.font{
            x = Int(label.center.x)
            y =  Int(label.center.y)
            text = attributedText.string
            size = Int(font.pointSize)
        }else{
            return nil
        }
        
    }
}
