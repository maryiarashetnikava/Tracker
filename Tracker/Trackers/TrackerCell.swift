import UIKit

protocol TrackerCellDelegate: AnyObject {
    func didTapPlusButton(in cell: TrackerCell)
}

final class TrackerCell: UICollectionViewCell {
    
    static let reuseIdentifier = "TrackerCell"
    
    weak var delegate: TrackerCellDelegate?
    
// MARK: - UI
    
    private let cardView = UIView()
    private let titleLabel = UILabel()
    
    private let emojiContainer = UIView()
    private let emojiLabel = UILabel()
    
    private let plusButton = UIButton(type: .system)
    private let countLabel = UILabel()
    
// MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
        setupAppearance()
        setupConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
// MARK: - Configuration
    
    func configure(with tracker: Tracker, isCompleted: Bool, count: Int, isFuture: Bool) {
        titleLabel.text = tracker.name
        emojiLabel.text = tracker.emoji
        
        cardView.backgroundColor = tracker.color
        plusButton.backgroundColor = tracker.color
        
        let imageName = isCompleted ? "checkmark" : "plus"
        plusButton.setImage(UIImage(systemName: imageName), for: .normal)
        
        countLabel.text = daysText(for: count)
        
        plusButton.isEnabled = !isFuture
        plusButton.alpha = isFuture ? 0.5 : 1.0
    }

// MARK: - Actions
    
    @objc private func plusTapped() {
        delegate?.didTapPlusButton(in: self)
    }
}

// MARK: - Setup Views

private extension TrackerCell {
    
    func setupViews() {
        contentView.addSubview(cardView)
        
        cardView.addSubview(titleLabel)
        cardView.addSubview(emojiContainer)
        emojiContainer.addSubview(emojiLabel)
        
        contentView.addSubview(plusButton)
        contentView.addSubview(countLabel)
    }
}

// MARK: - Setup Appearance

private extension TrackerCell {
    
    func setupAppearance() {
        
        cardView.backgroundColor = .systemGreen
        cardView.layer.cornerRadius = 12
        
        titleLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 2
        
        emojiContainer.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        emojiContainer.layer.cornerRadius = 16
        
        emojiLabel.font = UIFont.systemFont(ofSize: 16)
        
        plusButton.setImage(UIImage(systemName: "plus"), for: .normal)
        plusButton.tintColor = .white
        plusButton.backgroundColor = .systemGreen
        plusButton.layer.cornerRadius = 17
        plusButton.addTarget(self, action: #selector(plusTapped), for: .touchUpInside)
        
        countLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        countLabel.textColor = .label
        
    }
    
    func daysText(for count: Int) -> String {
        return String.localizedStringWithFormat(
            NSLocalizedString("tracker.days", comment: ""),
            count
        )
    }
}

// MARK: - Setup Constraints

private extension TrackerCell {
    
    func setupConstraints() {
        [cardView, titleLabel, emojiContainer, emojiLabel, plusButton, countLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([

            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.heightAnchor.constraint(equalToConstant: 90),

            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),

            emojiContainer.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            emojiContainer.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            emojiContainer.widthAnchor.constraint(equalToConstant: 32),
            emojiContainer.heightAnchor.constraint(equalToConstant: 32),

            emojiLabel.centerXAnchor.constraint(equalTo: emojiContainer.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiContainer.centerYAnchor),

            plusButton.widthAnchor.constraint(equalToConstant: 34),
            plusButton.heightAnchor.constraint(equalToConstant: 34),
            plusButton.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 8),
            plusButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            plusButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            countLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            countLabel.centerYAnchor.constraint(equalTo: plusButton.centerYAnchor)
        ])
    }
}
