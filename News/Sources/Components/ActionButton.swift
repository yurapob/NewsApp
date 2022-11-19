import UIKit

public class ActionButton: UIView {
    
    public typealias OnTouchUpInside = () -> Void

    static let height: CGFloat = 34.0
    
    public enum ButtonStyle {
        case standard
        case light
    }
    
    // MARK: - Private properties -
    private let shadowView: UIView = .init()
    private let containerView: UIView = .init()
    private let button: UIButton = .init(type: .system)
    private let disabledOverlapView: UIView = .init()

    // MARK: - Public properties -
    public var title: String? {
        get { button.title(for: .normal) }
        set { button.setTitle(newValue, for: .normal) }
    }
    
    public var image: UIImage? {
        get { button.image(for: .normal) }
        set { button.setImage(newValue, for: .normal) }
    }

    public var isEnabled: Bool {
        get { button.isEnabled }
        set {
            button.isEnabled = newValue
            renderIsEnabledChange()
        }
    }
    
    public var style: ButtonStyle = .standard {
        didSet {
            renderButtonStyle()
        }
    }
    
    public var onTouchUpInside: OnTouchUpInside?

    // MARK: - Overridden -
    public override init(frame: CGRect) {
        super.init(frame: frame)

        customInit()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)

        customInit()
    }
}

// MARK: - Private methods -
private extension ActionButton {
    func customInit() {
        setupView()
        setupShadowView()
        setupContainerView()
        setupButton()
        setupDisabledOverlapView()
        setupLayout()
    }

    func setupView() {
        backgroundColor = .clear
    }
    
    func setupShadowView() {
        shadowView.backgroundColor = .clear
    }

    func setupContainerView() {
        containerView.backgroundColor = Theme.Colors.black
        containerView.layer.cornerRadius = ActionButton.height / 2
        containerView.layer.masksToBounds = true
    }
    
    func setupButton() {
        button.setTitleColor(Theme.Colors.white, for: .normal)
        button.setTitleColor(Theme.Colors.white, for: .disabled)
        button.backgroundColor = .clear
        button.tintColor = Theme.Colors.white
        button.titleLabel?.font = Theme.Fonts.neutonLight.withSize(14.0)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.5
        button.contentMode = .center

        button.addTarget(self, action: #selector(buttonTouchUpInside), for: .touchUpInside)
    }

    @objc func buttonTouchUpInside() {
        onTouchUpInside?()
    }

    func setupDisabledOverlapView() {
        disabledOverlapView.backgroundColor = .clear
    }

    func setupLayout() {
        addSubview(containerView)
        containerView.addSubview(disabledOverlapView)
        containerView.addSubview(button)
        
        containerView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        button.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(3.0)
            make.height.equalTo(ActionButton.height)
        }

        disabledOverlapView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    func renderIsEnabledChange() {
        if isEnabled {
            containerView.backgroundColor = Theme.Colors.black
        } else {
            containerView.backgroundColor = Theme.Colors.textLightGray
        }
    }
    
    func renderButtonStyle() {
        switch style {
        case .standard:
            button.setTitleColor(Theme.Colors.white, for: .normal)
            button.setTitleColor(Theme.Colors.textGray, for: .disabled)
            button.titleLabel?.font = Theme.Fonts.neutonLight.withSize(14.0)
            containerView.backgroundColor = Theme.Colors.black
        case .light:
            button.setTitleColor(Theme.Colors.white, for: .normal)
            button.titleLabel?.font = Theme.Fonts.neutonBold.withSize(14.0)
            containerView.backgroundColor = Theme.Colors.black
        }
    }
}
