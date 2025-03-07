//
//  FetchDocumentVC.swift
//  FetchDocument
//
//  Created by Nirzar Gandhi on 05/03/25.
//

import UIKit
import WebKit
import MobileCoreServices
import UniformTypeIdentifiers

class FetchDocumentVC: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var fetchFileBtn: UIButton!
    @IBOutlet weak var webView: WKWebView!
    
    
    // MARK: - Properties
    fileprivate let maxAllowedFilesInt = 10
    fileprivate lazy var arrSelectedFiles = [URL]()
    
    
    // MARK: -
    // MARK: - View init Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Fetch Document"
        
        self.setControlsProperty()
    }
    
    fileprivate func setControlsProperty() {
        
        self.view.backgroundColor = .clear
        self.view.isOpaque = false
        
        // Fetch File Buttton
        self.fetchFileBtn.backgroundColor = .black
        self.fetchFileBtn.titleLabel?.backgroundColor = .black
        self.fetchFileBtn.setTitleColor(.white, for: .normal)
        self.fetchFileBtn.setTitle("Fetch File", for: .normal)
        
        // Web View
        self.webView.backgroundColor = .clear
        self.webView.scrollView.backgroundColor = .clear
        self.webView.isOpaque = false
        self.webView.navigationDelegate = self
    }
}


// MARK: - Call Back
extension FetchDocumentVC {
    
    fileprivate func fetchFiles() {
        
        var documentPickerController = UIDocumentPickerViewController(documentTypes: [kUTTypePDF as String],in: .open)
        
        if #available(iOS 14.0, *) {
            documentPickerController = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.pdf])
        }
        
        documentPickerController.allowsMultipleSelection = true
        documentPickerController.delegate = self
        self.present(documentPickerController, animated: true, completion: nil)
    }
    
    fileprivate func saveFileToDocument(fileName: String, fileData: Data) {
        
        let fileManage = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        let fileURL = fileManage.appendingPathComponent(fileName)
        
        do {
            try fileData.write(to: fileURL)
            
            self.loadURL(url: fileURL)
            
            print("File saved")
            
        } catch {
            print("Error in saving file:", error)
        }
    }
    
    fileprivate func loadURL(url: URL) {
        
        let request = URLRequest(url: url)
        self.webView.load(request)
    }
    
    fileprivate func convertToFileString(fromPath path: URL) -> String {
        
        var fileSize = 0
        
        do {
            let resources = try path.resourceValues(forKeys:[.fileSizeKey])
            fileSize = resources.fileSize ?? 0
        } catch {
            print("Error: \(error)")
        }
        
        // bytes
        if fileSize < 1023 {
            return String(format: "%lu bytes", CUnsignedLong(fileSize))
        }
        
        // KB
        var floatSize = Float(fileSize / 1024)
        if floatSize < 1023 {
            return String(format: "%.1f KB", floatSize)
        }
        
        // MB
        floatSize = floatSize / 1024
        if floatSize < 1023 {
            return String(format: "%.1f MB", floatSize)
        }
        
        // GB
        floatSize = floatSize / 1024
        return String(format: "%.1f GB", floatSize)
    }
}


// MARK: - Button Touch & Action
extension FetchDocumentVC {
    
    @IBAction func fetchPDFBtnTouch(_ sender: Any) {
        self.fetchFiles()
    }
}


// MARK: - UIDocumentMenu & UIDocumentPicker Delegate
extension FetchDocumentVC: UIDocumentPickerDelegate {
    
    internal func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        
        let totalSelectedFilesInt = self.arrSelectedFiles.count + urls.count
        
        guard totalSelectedFilesInt <= self.maxAllowedFilesInt else {
            print("User can select max 10 files")
            return
        }
        
        self.arrSelectedFiles.append(contentsOf: urls)
        
        guard let docURL = urls.first else {
            return
        }
        
        if docURL.startAccessingSecurityScopedResource() {
            
            if let data = try? Data(contentsOf: docURL) {
                let filename = docURL.lastPathComponent
                
                print("file size = \(self.convertToFileString(fromPath: docURL))")
                
                self.saveFileToDocument(fileName: filename, fileData: data)
            }
        }
    }
    
    internal func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        dismiss(animated: true, completion: nil)
    }
}


// MARK: - WKNavigation Delegate
extension FetchDocumentVC : WKNavigationDelegate {
    
    internal func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("Start Request")
    }
    
    internal func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("Failed Request")
    }
    
    internal func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("Finished Request")
    }
}
