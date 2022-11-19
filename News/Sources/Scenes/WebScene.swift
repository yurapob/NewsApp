import UIKit
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate {
    
    private let url: URL
    private var webView: WKWebView!
    private let spinner = UIActivityIndicatorView(style: .large)

    // MARK: - Initialization

    init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        
        spinner.startAnimating()
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
    }
    
    func webView(_ webView: WKWebView,didFinish navigation: WKNavigation!) {
        spinner.stopAnimating()
    }
}

private extension WebViewController {
    
    func setup() {
        setupNavigationBar()
        setupLayout()
    }
    
    func setupNavigationBar() {
        navigationController?.navigationBar.tintColor = Theme.Colors.black
    }
    func setupLayout() {
        view.addSubview(spinner)
        
        spinner.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
    }
}
