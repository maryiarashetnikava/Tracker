import UIKit

final class NewHabitViewController: UIViewController {
    
    // MARK: - Public Properties
    
    var onCreate: ((Tracker) -> Void)?
    var onUpdate: ((Tracker) -> Void)?
    
    var completedDaysCount = 0
    
    // MARK: - Private Properties
    
    private var selectedDays: Set<Weekday> = []
    private var selectedCategory: TrackerCategoryCoreData?
    
    private var trackerToEdit: Tracker?
    
    // MARK: - UI
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let cancelButton = UIButton(type: .system)
    private let createButton = UIButton(type: .system)
    
    private let textField = UITextField()
    
    private let optionsView = UIView()
    
    private let categoryRow = UIView()
    private let scheduleRow = UIView()
    
    private let categoryLabel = UILabel()
    private let categorySubtitleLabel = UILabel()
    private let scheduleLabel = UILabel()
    private let scheduleSubtitleLabel = UILabel()
    
    private let categoryArrow = UIImageView()
    private let scheduleArrow = UIImageView()
    
    private let divider = UIView()
    
    private let emojiTitleLabel = UILabel()
    private let emojiCollectionView: UICollectionView
    
    private let emojis = ["🙂","😻","🌺","🐶","❤️","😱","😇","😡","🥶","🤔","🙌","🍔","🥦","🏓","🥇","🎸","🏝","😪"]
    private var selectedEmojiIndex: IndexPath?
    
    private let colorTitleLabel = UILabel()
    private let colorCollectionView: UICollectionView
    
    private let colors: [UIColor] = [UIColor(resource: .cellColor1),UIColor(resource: .cellColor2),UIColor(resource: .cellColor3),UIColor(resource: .cellColor4),UIColor(resource: .cellColor5),UIColor(resource: .cellColor6),UIColor(resource: .cellColor7),UIColor(resource: .cellColor8),UIColor(resource: .cellColor9),UIColor(resource: .cellColor10),UIColor(resource: .cellColor11),UIColor(resource: .cellColor12),UIColor(resource: .cellColor13),UIColor(resource: .cellColor14),UIColor(resource: .cellColor15),UIColor(resource: .cellColor16),UIColor(resource: .cellColor17),UIColor(resource: .cellColor18)]
    
    private let daysCountLabel = UILabel()
    
    private var selectedColorIndex: IndexPath?
    
    // MARK: - Init
    
    init() {
        let emojiLayout = UICollectionViewFlowLayout()
        emojiLayout.itemSize = CGSize(width: 52, height: 52)
        emojiLayout.minimumInteritemSpacing = 5
        emojiLayout.minimumLineSpacing = 5
        
        emojiCollectionView = UICollectionView(frame: .zero, collectionViewLayout: emojiLayout)
        
        let colorLayout = UICollectionViewFlowLayout()
        colorLayout.itemSize = CGSize(width: 52, height: 52)
        colorLayout.minimumInteritemSpacing = 5
        colorLayout.minimumLineSpacing = 5
        
        colorCollectionView = UICollectionView(frame: .zero, collectionViewLayout: colorLayout)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.backButtonTitle = ""
        
        setupView()
        setupScrollView()
        setupTextField()
        setupOptionsView()
        setupEmojiSection()
        setupColorSection()
        setupGestures()
        setupButtons()
        setupDaysCountLabel()
        setupConstraints()
        
        updateCreateButtonState()
        updateCategoryUI()
        
        fillDataIfNeeded()
    }
    
    // MARK: - Setup
    
    private func setupView() {
        view.backgroundColor = .systemBackground
        title = NSLocalizedString("newHabit.title", comment: "")
    }
    
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
    }
    
    private func setupTextField() {
        textField.attributedPlaceholder = NSAttributedString(
            string: NSLocalizedString("tracker.placeholder", comment: ""),
            attributes: [.foregroundColor: UIColor.secondaryLabel]
        )
        textField.backgroundColor = UIColor(resource: .backgroundDay)
        textField.layer.cornerRadius = 16
        textField.font = UIFont.systemFont(ofSize: 17)
        
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        textField.leftViewMode = .always
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(textField)
        
        textField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
    
    private func setupOptionsView() {
        configureOptionsView()
        configureCategoryRow()
        configureScheduleRow()
        configureDivider()
        layoutOptionsView()
    }
    
    private func setupEmojiSection() {
        emojiTitleLabel.text = NSLocalizedString("emoji.title", comment: "")
        emojiTitleLabel.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        
        emojiTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        emojiCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        emojiCollectionView.backgroundColor = .clear
        emojiCollectionView.dataSource = self
        emojiCollectionView.delegate = self
        
        emojiCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "EmojiCell")
        
        contentView.addSubview(emojiTitleLabel)
        contentView.addSubview(emojiCollectionView)
    }
    
    private func setupColorSection() {
        colorTitleLabel.text = NSLocalizedString("color.title", comment: "")
        colorTitleLabel.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        
        colorTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        colorCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        colorCollectionView.backgroundColor = .clear
        colorCollectionView.dataSource = self
        colorCollectionView.delegate = self
        
        colorCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "ColorCell")
        
        contentView.addSubview(colorTitleLabel)
        contentView.addSubview(colorCollectionView)
    }
    
    private func setupButtons() {
        cancelButton.setTitle(NSLocalizedString("common.cancel", comment: ""),for: .normal)
        cancelButton.setTitleColor(.red, for: .normal)
        cancelButton.layer.cornerRadius = 16
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.red.cgColor
        
        createButton.setTitle(NSLocalizedString("common.create", comment: ""),for: .normal)
        createButton.backgroundColor = UIColor(resource: .gray)
        createButton.setTitleColor(.white, for: .normal)
        createButton.layer.cornerRadius = 16
        
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        createButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(cancelButton)
        view.addSubview(createButton)
        
        cancelButton.addAction(UIAction { [weak self] _ in self?.cancelTapped() }, for: .touchUpInside)
        createButton.addAction(UIAction { [weak self] _ in self?.createTapped() }, for: .touchUpInside)
    }
    
    private func setupDaysCountLabel() {
        daysCountLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        daysCountLabel.textAlignment = .center
        daysCountLabel.isHidden = true

        daysCountLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(daysCountLabel)
    }
    
    private func setupGestures() {
        let categoryTap = UITapGestureRecognizer(target: self, action: #selector(categoryTapped))
        categoryRow.addGestureRecognizer(categoryTap)
        
        let scheduleTap = UITapGestureRecognizer(target: self, action: #selector(scheduleTapped))
        scheduleRow.addGestureRecognizer(scheduleTap)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            
            // Scroll
            
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -16),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // TextField
            
            daysCountLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            daysCountLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            textField.topAnchor.constraint(equalTo: daysCountLabel.bottomAnchor, constant: 24),
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 64),
            
            // Options
            
            optionsView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 20),
            optionsView.leadingAnchor.constraint(equalTo: textField.leadingAnchor),
            optionsView.trailingAnchor.constraint(equalTo: textField.trailingAnchor),
            
            categoryRow.topAnchor.constraint(equalTo: optionsView.topAnchor, constant: 8),
            categoryRow.leadingAnchor.constraint(equalTo: optionsView.leadingAnchor),
            categoryRow.trailingAnchor.constraint(equalTo: optionsView.trailingAnchor),
            
            categoryLabel.leadingAnchor.constraint(equalTo: categoryRow.leadingAnchor, constant: 16),
            categoryLabel.topAnchor.constraint(equalTo: categoryRow.topAnchor, constant: 12),

            categorySubtitleLabel.leadingAnchor.constraint(equalTo: categoryLabel.leadingAnchor),
            categorySubtitleLabel.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 4),
            categorySubtitleLabel.bottomAnchor.constraint(equalTo: categoryRow.bottomAnchor, constant: -12),

            categoryArrow.trailingAnchor.constraint(equalTo: categoryRow.trailingAnchor, constant: -16),
            categoryArrow.centerYAnchor.constraint(equalTo: categoryRow.centerYAnchor),
            
            divider.topAnchor.constraint(equalTo: categoryRow.bottomAnchor, constant: 4),
            divider.leadingAnchor.constraint(equalTo: optionsView.leadingAnchor, constant: 16),
            divider.trailingAnchor.constraint(equalTo: optionsView.trailingAnchor, constant: -16),
            divider.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale),
            
            scheduleRow.topAnchor.constraint(equalTo: divider.bottomAnchor),
            scheduleRow.leadingAnchor.constraint(equalTo: optionsView.leadingAnchor),
            scheduleRow.trailingAnchor.constraint(equalTo: optionsView.trailingAnchor),
            scheduleRow.bottomAnchor.constraint(equalTo: optionsView.bottomAnchor, constant: -8),
            
            scheduleLabel.leadingAnchor.constraint(equalTo: scheduleRow.leadingAnchor, constant: 16),
            scheduleLabel.topAnchor.constraint(equalTo: scheduleRow.topAnchor, constant: 16),
            scheduleSubtitleLabel.leadingAnchor.constraint(equalTo: scheduleLabel.leadingAnchor),
            scheduleSubtitleLabel.topAnchor.constraint(equalTo: scheduleLabel.bottomAnchor, constant: 4),
            scheduleSubtitleLabel.bottomAnchor.constraint(equalTo: scheduleRow.bottomAnchor, constant: -16),
            
            scheduleArrow.trailingAnchor.constraint(equalTo: scheduleRow.trailingAnchor, constant: -16),
            scheduleArrow.centerYAnchor.constraint(equalTo: scheduleRow.centerYAnchor),
            
            // Emoji
            
            emojiTitleLabel.topAnchor.constraint(equalTo: optionsView.bottomAnchor, constant: 32),
            emojiTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            emojiCollectionView.topAnchor.constraint(equalTo: emojiTitleLabel.bottomAnchor, constant: 16),
            emojiCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            emojiCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 204),
            
            // Color
            
            colorTitleLabel.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 32),
            colorTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            colorCollectionView.topAnchor.constraint(equalTo: colorTitleLabel.bottomAnchor, constant: 16),
            colorCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            colorCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            colorCollectionView.heightAnchor.constraint(equalToConstant: 230),
            
            colorCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            // Buttons
            
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            createButton.leadingAnchor.constraint(equalTo: cancelButton.trailingAnchor, constant: 8),
            createButton.bottomAnchor.constraint(equalTo: cancelButton.bottomAnchor),
            createButton.heightAnchor.constraint(equalTo: cancelButton.heightAnchor),
            
            cancelButton.widthAnchor.constraint(equalTo: createButton.widthAnchor)
        ])
    }
    
    // MARK: - Configure
    
    func configure(with tracker: Tracker) {
        trackerToEdit = tracker
    }
    
    private func configureOptionsView() {
        optionsView.backgroundColor = UIColor(resource: .backgroundDay)
        optionsView.layer.cornerRadius = 16
        
        contentView.addSubview(optionsView)
        
        categoryRow.isUserInteractionEnabled = true
        scheduleRow.isUserInteractionEnabled = true
    }
    
    private func configureCategoryRow() {
        categoryLabel.text = NSLocalizedString("categories.title", comment: "")
        categoryLabel.font = UIFont.systemFont(ofSize: 17)
        
        categoryArrow.image = UIImage(systemName: "chevron.right")
        categoryArrow.tintColor = .tertiaryLabel
        
        categorySubtitleLabel.font = UIFont.systemFont(ofSize: 17)
        categorySubtitleLabel.textColor = .secondaryLabel
        categorySubtitleLabel.text = ""
        categorySubtitleLabel.numberOfLines = 1
    }
    
    private func configureScheduleRow() {
        scheduleLabel.text = NSLocalizedString("schedule.title", comment: "")
        scheduleLabel.font = UIFont.systemFont(ofSize: 17)
        
        scheduleArrow.image = UIImage(systemName: "chevron.right")
        scheduleArrow.tintColor = .tertiaryLabel
        
        scheduleSubtitleLabel.font = UIFont.systemFont(ofSize: 17)
        scheduleSubtitleLabel.textColor = .secondaryLabel
        scheduleSubtitleLabel.text = ""
    }
    
    private func configureDivider() {
        divider.backgroundColor = UIColor.separator.withAlphaComponent(0.5)
    }
    
    private func layoutOptionsView() {
        optionsView.translatesAutoresizingMaskIntoConstraints = false
        categoryRow.translatesAutoresizingMaskIntoConstraints = false
        scheduleRow.translatesAutoresizingMaskIntoConstraints = false
        
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        categorySubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        categoryArrow.translatesAutoresizingMaskIntoConstraints = false
        scheduleLabel.translatesAutoresizingMaskIntoConstraints = false
        scheduleSubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        scheduleArrow.translatesAutoresizingMaskIntoConstraints = false
        divider.translatesAutoresizingMaskIntoConstraints = false
        
        optionsView.addSubview(categoryRow)
        optionsView.addSubview(divider)
        optionsView.addSubview(scheduleRow)
        
        categoryRow.addSubview(categoryLabel)
        categoryRow.addSubview(categoryArrow)
        categoryRow.addSubview(categorySubtitleLabel)
        
        scheduleRow.addSubview(scheduleLabel)
        scheduleRow.addSubview(scheduleArrow)
        scheduleRow.addSubview(scheduleSubtitleLabel)
    }
    
    // MARK: - Actions
    
    private func cancelTapped() {
        dismiss(animated: true)
    }
    
    private func createTapped() {
        guard let name = textField.text, !name.isEmpty else { return }
        
        let emoji = selectedEmojiIndex.map { emojis[$0.item] } ?? "🙂"
        let color = selectedColorIndex.map { colors[$0.item] } ?? .systemGreen
        
        let tracker = Tracker(
            id: trackerToEdit?.id ?? UUID(),
            name: name,
            color: color,
            emoji: emoji,
            schedule: Array(selectedDays),
            category: selectedCategory
        )
        
        if trackerToEdit != nil {
            onUpdate?(tracker)
        } else {
            onCreate?(tracker)
        }
        
        dismiss(animated: true)
    }
    
    @objc private func categoryTapped() {
        let store = TrackerCategoryStore(context: CoreDataStack.shared.context)
        let viewModel = TrackerCategoryViewModel(
            store: store,
            selectedCategory: selectedCategory
        )
        
        let vc = CategoriesViewController(viewModel: viewModel)
        
        vc.onCategorySelected = { [weak self] category in
            self?.selectedCategory = category
            self?.updateCategoryUI()
            self?.updateCreateButtonState()
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func scheduleTapped() {
        let vc = ScheduleViewController()
        vc.selectedDays = selectedDays
        
        vc.onSave = { [weak self] days in
            self?.selectedDays = days
            self?.updateScheduleLabel()
            self?.updateCreateButtonState()
        }
        
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .pageSheet
        
        present(nav, animated: true)
    }
    
    @objc private func textDidChange() {
        updateCreateButtonState()
    }
    
    private func updateCategoryUI() {
        let hasCategory = selectedCategory != nil
        
        categorySubtitleLabel.text = selectedCategory?.title
        categorySubtitleLabel.isHidden = !hasCategory
    }
    
    private func updateScheduleLabel() {
        if selectedDays.isEmpty {
            scheduleSubtitleLabel.text = ""
            return
        }
        
        let sortedDays = selectedDays.sorted { $0.rawValue < $1.rawValue }
        let shortNames = sortedDays.map { shortName(for: $0) }
        
        scheduleSubtitleLabel.text = shortNames.joined(separator: ", ")
    }
    
    private func updateCreateButtonState() {
        let hasName = !(textField.text?.isEmpty ?? true)
        let hasEmoji = selectedEmojiIndex != nil
        let hasColor = selectedColorIndex != nil
        let hasSchedule = !selectedDays.isEmpty
        
        let isEnabled = hasName && hasEmoji && hasColor && hasSchedule
        
        createButton.isEnabled = isEnabled
        createButton.backgroundColor = isEnabled ? .black : UIColor(resource: .gray)
    }
    
    private func fillDataIfNeeded() {
        
        guard let tracker = trackerToEdit else {
            return
        }
        
        daysCountLabel.isHidden = false
        daysCountLabel.text = String.localizedStringWithFormat(
            NSLocalizedString("tracker.days", comment: ""),
            completedDaysCount
        )
        
        createButton.setTitle(
            NSLocalizedString("common.save", comment: ""),
            for: .normal
        )

        title = NSLocalizedString("tracker.edit.title", comment: "")

        textField.text = tracker.name

        if let emojiIndex = emojis.firstIndex(of: tracker.emoji) {
            selectedEmojiIndex = IndexPath(item: emojiIndex, section: 0)
        }

        if let colorIndex = colors.firstIndex(where: {
            $0.cgColor == tracker.color.cgColor
        }) {
            selectedColorIndex = IndexPath(item: colorIndex, section: 0)
        }

        selectedDays = Set(tracker.schedule)
        
        selectedCategory = tracker.category
        updateCategoryUI()

        updateScheduleLabel()

        emojiCollectionView.reloadData()
        colorCollectionView.reloadData()

        updateCreateButtonState()
    }
    
    // MARK: - Helpers
    
    private func shortName(for day: Weekday) -> String {
        switch day {
        case .monday:
            return NSLocalizedString("weekday.monday.short", comment: "")
        case .tuesday:
            return NSLocalizedString("weekday.tuesday.short", comment: "")
        case .wednesday:
            return NSLocalizedString("weekday.wednesday.short", comment: "")
        case .thursday:
            return NSLocalizedString("weekday.thursday.short", comment: "")
        case .friday:
            return NSLocalizedString("weekday.friday.short", comment: "")
        case .saturday:
            return NSLocalizedString("weekday.saturday.short", comment: "")
        case .sunday:
            return NSLocalizedString("weekday.sunday.short", comment: "")
        }
    }
}

// MARK: - Collection

extension NewHabitViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collectionView == emojiCollectionView ? emojis.count : colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == emojiCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath)
            
            let label = UILabel()
            label.text = emojis[indexPath.item]
            label.font = UIFont.systemFont(ofSize: 32)
            label.textAlignment = .center
            label.frame = cell.contentView.bounds
            
            cell.contentView.subviews.forEach { $0.removeFromSuperview() }
            cell.contentView.addSubview(label)
            
            cell.layer.cornerRadius = 16
            cell.backgroundColor = indexPath == selectedEmojiIndex ? .systemGray5 : .clear
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath)

            let color = colors[indexPath.item]

            cell.contentView.subviews.forEach { $0.removeFromSuperview() }

            let container = UIView()
            container.translatesAutoresizingMaskIntoConstraints = false
            container.layer.cornerRadius = 12

            cell.contentView.addSubview(container)

            NSLayoutConstraint.activate([
                container.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
                container.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
                container.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
                container.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor)
            ])

            let colorView = UIView()
            colorView.translatesAutoresizingMaskIntoConstraints = false
            colorView.backgroundColor = color
            colorView.layer.cornerRadius = 10

            container.addSubview(colorView)

            NSLayoutConstraint.activate([
                colorView.topAnchor.constraint(equalTo: container.topAnchor, constant: 5),
                colorView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -5),
                colorView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 5),
                colorView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -5)
            ])

            if indexPath.item == selectedColorIndex?.item {
                container.layer.borderWidth = 3
                container.layer.borderColor = color.withAlphaComponent(0.2).cgColor
            } else {
                container.layer.borderWidth = 0
            }

            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollectionView {
            selectedEmojiIndex = indexPath
        } else {
            selectedColorIndex = indexPath
        }
        collectionView.reloadData()
        updateCreateButtonState()
    }
}
