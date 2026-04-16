import UIKit

final class NewHabitViewController: UIViewController {
    
    // MARK: - Public Properties
    
    var onCreate: ((Tracker) -> Void)?
    
    // MARK: - Private Properties
    
    private var selectedDays: Set<Weekday> = []
    
    // MARK: - UI
    
    private let cancelButton = UIButton(type: .system)
    private let createButton = UIButton(type: .system)
    
    private let textField = UITextField()
    
    private let optionsView = UIView()
    
    private let categoryRow = UIView()
    private let scheduleRow = UIView()
    
    private let categoryLabel = UILabel()
    private let scheduleLabel = UILabel()
    
    private let categoryArrow = UIImageView()
    private let scheduleArrow = UIImageView()
    
    private let divider = UIView()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupTextField()
        setupOptionsView()
        setupGestures()
        setupButtons()
        setupConstraints()
    }
    
    // MARK: - Setup UI
    
    private func setupView() {
        view.backgroundColor = .systemBackground
        title = "Новая привычка"
    }
    
    private func setupTextField() {
        textField.attributedPlaceholder = NSAttributedString(
            string: "Введите название трекера",
            attributes: [.foregroundColor: UIColor.secondaryLabel]
        )
        textField.backgroundColor = UIColor(named: "Background [day]")
        textField.layer.cornerRadius = 16
        textField.font = UIFont.systemFont(ofSize: 17)
        
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        textField.leftViewMode = .always
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(textField)
    }
    
    private func setupOptionsView() {
        configureOptionsView()
        configureCategoryRow()
        configureScheduleRow()
        configureDivider()
        layoutOptionsView()
    }
    
    private func setupButtons() {
        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.setTitleColor(.red, for: .normal)
        cancelButton.layer.cornerRadius = 16
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.red.cgColor
        
        createButton.setTitle("Создать", for: .normal)
        createButton.backgroundColor = UIColor(named: "Gray")
        createButton.setTitleColor(.white, for: .normal)
        createButton.layer.cornerRadius = 16
        
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        createButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(cancelButton)
        view.addSubview(createButton)
        
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        createButton.addTarget(self, action: #selector(createTapped), for: .touchUpInside)
    }
    
    private func setupGestures() {
        let categoryTap = UITapGestureRecognizer(target: self, action: #selector(categoryTapped))
        categoryRow.addGestureRecognizer(categoryTap)
        
        let scheduleTap = UITapGestureRecognizer(target: self, action: #selector(scheduleTapped))
        scheduleRow.addGestureRecognizer(scheduleTap)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 64),
            
            optionsView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 20),
            optionsView.leadingAnchor.constraint(equalTo: textField.leadingAnchor),
            optionsView.trailingAnchor.constraint(equalTo: textField.trailingAnchor),
            
            categoryRow.topAnchor.constraint(equalTo: optionsView.topAnchor, constant: 8),
            categoryRow.leadingAnchor.constraint(equalTo: optionsView.leadingAnchor),
            categoryRow.trailingAnchor.constraint(equalTo: optionsView.trailingAnchor),
            
            categoryLabel.leadingAnchor.constraint(equalTo: categoryRow.leadingAnchor, constant: 16),
            categoryLabel.topAnchor.constraint(equalTo: categoryRow.topAnchor, constant: 24),
            categoryLabel.bottomAnchor.constraint(equalTo: categoryRow.bottomAnchor, constant: -24),
            
            categoryArrow.trailingAnchor.constraint(equalTo: categoryRow.trailingAnchor, constant: -16),
            categoryArrow.centerYAnchor.constraint(equalTo: categoryLabel.centerYAnchor),
            
            divider.topAnchor.constraint(equalTo: categoryRow.bottomAnchor, constant: 4),
            divider.leadingAnchor.constraint(equalTo: optionsView.leadingAnchor, constant: 16),
            divider.trailingAnchor.constraint(equalTo: optionsView.trailingAnchor, constant: -16),
            divider.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale),
            
            scheduleRow.topAnchor.constraint(equalTo: divider.bottomAnchor),
            scheduleRow.leadingAnchor.constraint(equalTo: optionsView.leadingAnchor),
            scheduleRow.trailingAnchor.constraint(equalTo: optionsView.trailingAnchor),
            scheduleRow.bottomAnchor.constraint(equalTo: optionsView.bottomAnchor, constant: -8),
            
            scheduleLabel.leadingAnchor.constraint(equalTo: scheduleRow.leadingAnchor, constant: 16),
            scheduleLabel.topAnchor.constraint(equalTo: scheduleRow.topAnchor, constant: 24),
            scheduleLabel.bottomAnchor.constraint(equalTo: scheduleRow.bottomAnchor, constant: -24),
            
            scheduleArrow.trailingAnchor.constraint(equalTo: scheduleRow.trailingAnchor, constant: -16),
            scheduleArrow.centerYAnchor.constraint(equalTo: scheduleLabel.centerYAnchor),
            
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            createButton.leadingAnchor.constraint(equalTo: cancelButton.trailingAnchor, constant: 8),
            createButton.bottomAnchor.constraint(equalTo: cancelButton.bottomAnchor),
            createButton.heightAnchor.constraint(equalTo: cancelButton.heightAnchor),
            
            cancelButton.widthAnchor.constraint(equalTo: createButton.widthAnchor),
        ])
    }
    
    // MARK: - Configure UI
    
    private func configureOptionsView() {
        optionsView.backgroundColor = UIColor(named: "Background [day]")
        optionsView.layer.cornerRadius = 16
        optionsView.clipsToBounds = true
        
        categoryRow.isUserInteractionEnabled = true
        scheduleRow.isUserInteractionEnabled = true
    }
    
    private func configureCategoryRow() {
        categoryLabel.text = "Категория"
        categoryLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        categoryLabel.textColor = .label
        
        categoryArrow.image = UIImage(systemName: "chevron.right")
        categoryArrow.tintColor = .tertiaryLabel
    }
    
    private func configureScheduleRow() {
        scheduleLabel.text = "Расписание"
        scheduleLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        scheduleLabel.textColor = .label
        
        scheduleArrow.image = UIImage(systemName: "chevron.right")
        scheduleArrow.tintColor = .tertiaryLabel
    }
    
    private func configureDivider() {
        divider.backgroundColor = UIColor.separator.withAlphaComponent(0.5)
    }
    
    private func layoutOptionsView() {
        optionsView.translatesAutoresizingMaskIntoConstraints = false
        categoryRow.translatesAutoresizingMaskIntoConstraints = false
        scheduleRow.translatesAutoresizingMaskIntoConstraints = false
        
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        categoryArrow.translatesAutoresizingMaskIntoConstraints = false
        scheduleLabel.translatesAutoresizingMaskIntoConstraints = false
        scheduleArrow.translatesAutoresizingMaskIntoConstraints = false
        divider.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(optionsView)
        
        optionsView.addSubview(categoryRow)
        optionsView.addSubview(divider)
        optionsView.addSubview(scheduleRow)
        
        categoryRow.addSubview(categoryLabel)
        categoryRow.addSubview(categoryArrow)
        
        scheduleRow.addSubview(scheduleLabel)
        scheduleRow.addSubview(scheduleArrow)
    }
    
    // MARK: - Actions
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func createTapped() {
        guard let name = textField.text, !name.isEmpty else { return }
        
        let tracker = Tracker(
            id: UUID(),
            name: name,
            color: .systemGreen,
            emoji: "🙂",
            schedule: Array(selectedDays)
        )
        
        onCreate?(tracker)
        dismiss(animated: true)
    }
    
    @objc private func categoryTapped() {
        print("Категория нажата")
    }
    
    @objc private func scheduleTapped() {
        let vc = ScheduleViewController()
        vc.selectedDays = selectedDays
        
        vc.onSave = { [weak self] days in
            self?.selectedDays = days
        }
        
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .pageSheet
        
        present(nav, animated: true)
    }
}

