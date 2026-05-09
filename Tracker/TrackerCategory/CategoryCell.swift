import UIKit

final class CategoryCell: UITableViewCell {
    
    static let reuseIdentifier = "CategoryCell"
    
    private let titleLabel = UILabel()
    private let checkmarkImageView = UIImageView()
    private let divider = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        nil
    }
    
    func configure(title: String, isSelected: Bool, isLast: Bool) {
        titleLabel.text = title
        checkmarkImageView.isHidden = !isSelected
        divider.isHidden = isLast
    }
    
    private func setupViews() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        titleLabel.font = UIFont.systemFont(ofSize: 17)
        
        checkmarkImageView.image = UIImage(systemName: "checkmark")
        checkmarkImageView.tintColor = .systemBlue
        
        divider.backgroundColor = .separator
        
        [titleLabel, checkmarkImageView, divider].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            checkmarkImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            checkmarkImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            divider.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            divider.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            divider.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            divider.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale)
        ])
    }
}

