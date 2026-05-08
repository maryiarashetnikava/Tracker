import UIKit

final class NewCategoryViewController: UIViewController {
    
    // MARK: - Public
    
    var onCreate: ((String) -> Void)?
    
    // MARK: - UI
    
    private let textField = UITextField()
    private let createButton = UIButton(type: .system)
    private var categoryToEdit: TrackerCategoryCoreData?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupTextField()
        setupButton()
        setupConstraints()
        
        updateButtonState()
    }
    // MARK: -  Setup UI
    
    private func setupView() {
        view.backgroundColor = .systemBackground
        
        title = categoryToEdit == nil
            ? "Новая категория"
            : "Редактирование категории"
    }
    
    private func setupTextField() {
        textField.placeholder = "Введите название категории"
        textField.backgroundColor = UIColor(resource: .backgroundDay)
        textField.layer.cornerRadius = 16
        
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        textField.leftViewMode = .always
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textField)
        
        textField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
    
    private func setupButton() {
        createButton.setTitle("Готово", for: .normal)
        createButton.backgroundColor = .black
        createButton.setTitleColor(.white, for: .normal)
        createButton.layer.cornerRadius = 16
        createButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        createButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(createButton)
        
        createButton.addTarget(self, action: #selector(createTapped), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 64),
            
            createButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            createButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func createTapped() {
        guard let text = textField.text, !text.isEmpty else { return }
        
        onCreate?(text)
        dismiss(animated: true)
    }
    
    @objc private func textDidChange() {
        updateButtonState()
    }
    
    // MARK: - State
    
    private func updateButtonState() {
        let hasText = !(textField.text?.isEmpty ?? true)
        
        createButton.isEnabled = hasText
        createButton.backgroundColor = hasText ? .black : UIColor(resource: .gray)
    }
    // MARK: - Configuration
    
    func configure(with category: TrackerCategoryCoreData) {
        categoryToEdit = category
        textField.text = category.title
    }
    
}
