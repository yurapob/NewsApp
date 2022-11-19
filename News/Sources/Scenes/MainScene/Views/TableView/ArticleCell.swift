import UIKit
import SnapKit

extension MainScene {
    
    enum ArticleCell {
        
        private static var titleLabelFont: UIFont { Theme.Fonts.neutonBold.withSize(20.0) }
        private static var sourceLabelFont: UIFont { Theme.Fonts.neutonBold.withSize(14.0) }
        private static var descriptionLabelFont: UIFont { Theme.Fonts.neutonLight.withSize(14.0) }
        
        private static let inset: UIEdgeInsets = .init(top: 7.0, left: 20.0, bottom: 7.0, right: 20.0)
        private static var likeButtonSize: CGFloat { 24.0 }
        private static var likeButtonOffset: CGFloat { 7.0 }
        private static var titleTopOffset: CGFloat { 14.0 }
        private static var sourceTopOffset: CGFloat { 7.0 }
        private static var descriptionTopOffset: CGFloat { 14.0 }
        private static var imageViewTopOffset: CGFloat { 7.0 }
        private static var borderViewTopOffset: CGFloat { 7.0 }
        private static var borderHeight: CGFloat { 1.0 }
        
        struct ViewModel: CellViewModel {
            
            let id: String
            let source: String
            let author: String
            let title: String
            let descript: String
            let image: String
            let isFavorite: Bool
            
            func setup(cell: View) {
                cell.source = setSource(source, author)
                cell.title = title
                cell.descript = descript
                cell.image = image
                cell.isFavorite = isFavorite
            }
            
            private func setSource(_ source: String, _ author: String) -> String {
                if source == author {
                    return source
                } else if source != .empty && author != .empty {
                    return source + ", " + author
                } else if source != .empty && author == .empty {
                    return source
                } else if source == .empty && author != .empty {
                    return author
                }
                
                return .empty
            }
            
            var hashValue: Int {
                id.hashValue
            }
            
            func hash(into hasher: inout Hasher) {
                hasher.combine(id)
            }
            
            public static func == (lsh: ViewModel, rsh: ViewModel) -> Bool {
                return lsh.source == rsh.source && lsh.author == rsh.author && lsh.title == rsh.title && lsh.descript == rsh.descript && lsh.image == rsh.image
            }
        }
        
        class View: UITableViewCell {
            
            typealias OnButtonTouchUpInside = (Bool) -> Void
            
            // MARK: - Private properties
            
            private let containerView: UIView = .init()
            private let sourceLabel: UILabel = .init()
            private let titleLabel: UILabel = .init()
            private let descriptionLabel: UILabel = .init()
            private let articleImageView: UIImageView = .init()
            private let likeButton: UIButton = .init()
            private let borderView: UIView = .init()
            
            private var commonBackgroundColor: UIColor { .clear }
            
            public var imageViewHeight: CGFloat = 170.0
            
            // MARK: - Public properties
            
            public var source: String? {
                get { sourceLabel.text }
                set { sourceLabel.text = newValue }
            }
            
            public var title: String? {
                get { titleLabel.text }
                set { titleLabel.text = newValue }
            }
            
            public var descript: String? {
                get { descriptionLabel.text }
                set { descriptionLabel.text = newValue }
            }
            
            public var image: String?
            
            public var isFavorite: Bool? {
                get {
                    if let text = likeButton.titleLabel?.text {
                        return text == "✓"
                    } else {
                        return false
                    }
                }
                set { likeButton.setTitle(newValue ?? false ? "✓" : "+", for: .normal) }
            }
            
            public var onButtonTouchUpInside: OnButtonTouchUpInside?
            
            // MARK: -
            
            override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
                super.init(style: style, reuseIdentifier: reuseIdentifier)
                
                commonInit()
            }
            
            required init?(coder: NSCoder) {
                super.init(coder: coder)
                
                commonInit()
            }
        }
    }
}

// MARK: - Private methods

private extension MainScene.ArticleCell.View {
    typealias NameSpace = MainScene.ArticleCell
    
    func commonInit() {
        setupView()
        setupTitleLabel()
        setupSourceLabel()
        setupDescriptionLabel()
        setupLikeButton()
        setupBorderView()
        setupLayout()
    }
    
    func setupView() {
        backgroundColor = commonBackgroundColor
        selectionStyle = .none
        
        containerView.isUserInteractionEnabled = false
    }
    
    func setupTitleLabel() {
        titleLabel.font = NameSpace.titleLabelFont
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .left
        titleLabel.backgroundColor = .clear
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.textColor = Theme.Colors.black
    }
    
    func setupSourceLabel() {
        sourceLabel.font = NameSpace.sourceLabelFont
        sourceLabel.numberOfLines = .zero
        sourceLabel.textAlignment = .left
        sourceLabel.backgroundColor = .clear
        sourceLabel.lineBreakMode = .byWordWrapping
        sourceLabel.textColor = Theme.Colors.textGray
    }
    
    func setupDescriptionLabel() {
        descriptionLabel.font = NameSpace.descriptionLabelFont
        descriptionLabel.numberOfLines = .zero
        descriptionLabel.textAlignment = .left
        descriptionLabel.backgroundColor = .clear
        descriptionLabel.lineBreakMode = .byWordWrapping
        descriptionLabel.textColor = Theme.Colors.textGray
    }
    
    func setupLikeButton() {
        likeButton.isUserInteractionEnabled = true
        likeButton.backgroundColor = .clear
        likeButton.layer.cornerRadius = 5
        likeButton.layer.borderWidth = 1
        likeButton.layer.borderColor = UIColor.black.cgColor
        likeButton.setTitleColor(Theme.Colors.black, for: .normal)
        likeButton.titleLabel?.font = Theme.Fonts.neutonBold.withSize(14.0)
        
        likeButton.addTarget(self, action: #selector(buttonTouchUpInside(sender: )), for: .touchUpInside)
    }
    
    @objc func buttonTouchUpInside(sender: UIButton) {
        if let isFavorite = isFavorite {
            onButtonTouchUpInside?(isFavorite)
        }
    }
    
    func setupBorderView() {
        borderView.backgroundColor = Theme.Colors.separatorGray
    }
    
    func setupLayout() {
        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        contentView.addSubview(likeButton)
        containerView.addSubview(sourceLabel)
        containerView.addSubview(descriptionLabel)
        containerView.addSubview(articleImageView)
        containerView.addSubview(borderView)
        
        containerView.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview().inset(NameSpace.inset)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(NameSpace.inset.top)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview().inset(NameSpace.likeButtonSize + NameSpace.likeButtonOffset)
        }
        
        likeButton.snp.makeConstraints { make in
            make.size.equalTo(NameSpace.likeButtonSize)
            make.top.equalToSuperview().offset(NameSpace.inset.top)
            make.trailing.equalToSuperview().inset(NameSpace.inset.right)
        }
        
        sourceLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(NameSpace.sourceTopOffset)
            make.leading.trailing.equalToSuperview()
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(sourceLabel.snp.bottom).offset(NameSpace.descriptionTopOffset)
            make.leading.trailing.equalToSuperview()
        }
        
        articleImageView.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(NameSpace.imageViewTopOffset)
            make.leading.trailing.equalToSuperview()
        }
        
        borderView.snp.makeConstraints { make in
            make.top.equalTo(articleImageView.snp.bottom).offset(NameSpace.borderViewTopOffset)
            make.height.equalTo(NameSpace.borderHeight)
            make.leading.trailing.equalToSuperview()
        }
    }
}

extension MainScene.ArticleCell.ViewModel: UITableViewCellHeightProvider {
    typealias NameSpace = MainScene.ArticleCell
    
    func height(with tableViewWidth: CGFloat) -> CGFloat {
        
        let cellWidth: CGFloat = tableViewWidth - (
            NameSpace.inset.left
            + NameSpace.inset.right
        )
        
        let buttonWidth = NameSpace.likeButtonSize + NameSpace.likeButtonOffset
        let titleHeight: CGFloat = title.height(
            constraintedWidth: cellWidth - buttonWidth,
            font: NameSpace.titleLabelFont
        )
        
        let sourceFontHeight: CGFloat = source.height(
            constraintedWidth: cellWidth,
            font: NameSpace.sourceLabelFont
        )
        
        let descriptionFontHeight: CGFloat = descript.height(
            constraintedWidth: cellWidth,
            font: NameSpace.descriptionLabelFont
        )
        
        let cellHeight: CGFloat = NameSpace.inset.top
            + NameSpace.titleTopOffset
            + titleHeight
            + NameSpace.sourceTopOffset
            + sourceFontHeight
            + NameSpace.descriptionTopOffset
            + descriptionFontHeight
            + NameSpace.borderHeight
            + NameSpace.inset.bottom
        
        return cellHeight
    }
}
