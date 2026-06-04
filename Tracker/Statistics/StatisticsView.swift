import UIKit

final class StatisticsView: UIView {

    // MARK: - UI

    private let valueLabel = UILabel()
    private let titleLabel = UILabel()
    
    private let gradientLayer = CAGradientLayer()
    private let shapeLayer = CAShapeLayer()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
        setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        gradientLayer.frame = bounds

        let path = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: 16
        )

        shapeLayer.path = path.cgPath
        shapeLayer.lineWidth = 1
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.black.cgColor

        gradientLayer.mask = shapeLayer
    }

    // MARK: - Public

    func configure(value: Int, title: String) {
        valueLabel.text = "\(value)"
        titleLabel.text = title
    }
}

private extension StatisticsView {

    func setupView() {

        layer.cornerRadius = 16

        backgroundColor = .systemBackground

        valueLabel.font = UIFont.boldSystemFont(ofSize: 34)
        valueLabel.textColor = .label

        titleLabel.font = UIFont.systemFont(
            ofSize: 12,
            weight: .medium
        )

        titleLabel.textColor = .label

        addSubview(valueLabel)
        addSubview(titleLabel)

        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        gradientLayer.colors = [
            UIColor.systemRed.cgColor,
            UIColor.systemGreen.cgColor,
            UIColor.systemBlue.cgColor
        ]

        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)

        layer.insertSublayer(
            gradientLayer,
            at: 0
        )
    }

    func setupConstraints() {

        NSLayoutConstraint.activate([

            heightAnchor.constraint(equalToConstant: 90),

            valueLabel.topAnchor.constraint(
                equalTo: topAnchor,
                constant: 16
            ),

            valueLabel.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: 16
            ),

            titleLabel.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: 16
            ),

            titleLabel.bottomAnchor.constraint(
                equalTo: bottomAnchor,
                constant: -16
            )
        ])
    }
}
