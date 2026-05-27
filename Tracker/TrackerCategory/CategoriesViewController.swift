import UIKit

final class CategoriesViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: TrackerCategoryViewModel
    
    var onCategorySelected: ((TrackerCategoryCoreData) -> Void)?
    
    private let tableView = UITableView()
    private let addButton = UIButton(type: .system)
    
    private let emptyImageView = UIImageView()
    private let emptyLabel = UILabel()
    private let containerView = UIView()
    
    private var tableHeightConstraint: NSLayoutConstraint?
    
    // MARK: - Init
    
    init(viewModel: TrackerCategoryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.hidesBackButton = true
        
        setupView()
        setupContainerView()
        setupTableView()
        setupAddButton()
        setupEmptyState()
        setupConstraints()
        
        bindViewModel()
        updateEmptyState()
        updateTableHeight()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureNavigationBar()
    }
    // MARK: - Setup UI
    
    private func setupView() {
        view.backgroundColor = .systemBackground
        title = NSLocalizedString("categories.title", comment: "")
    }
    
    private func configureNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        appearance.shadowColor = .clear

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance

        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never

        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: UIColor.label
        ]
    }
    
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.rowHeight = 72
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        
        tableView.tableFooterView = UIView()
        
        tableView.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.reuseIdentifier)
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func setupContainerView() {
        containerView.backgroundColor = UIColor(resource: .backgroundDay)
        containerView.layer.cornerRadius = 16
        containerView.clipsToBounds = true
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        
        containerView.addSubview(tableView)
    }
    
    private func setupAddButton() {
        addButton.setTitle(NSLocalizedString("categories.add", comment: ""),for: .normal)
        addButton.backgroundColor = .black
        addButton.setTitleColor(.white, for: .normal)
        addButton.layer.cornerRadius = 16
        addButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        addButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(addButton)
        
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
    }
    
    private func setupEmptyState() {
        emptyImageView.image = UIImage(resource: .dizzy)
        emptyImageView.contentMode = .scaleAspectFit
        
        emptyLabel.numberOfLines = 2

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2
        paragraphStyle.alignment = .center

        emptyLabel.attributedText = NSAttributedString(
            string: NSLocalizedString("categories.empty", comment: ""),
            attributes: [
                .font: UIFont.systemFont(ofSize: 12),
                .paragraphStyle: paragraphStyle
            ]
        )
        emptyImageView.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(emptyImageView)
        view.addSubview(emptyLabel)
    }
    
    private func updateTableHeight() {
        let rowHeight: CGFloat = 75
        let count = CGFloat(viewModel.numberOfCategories)
        
        tableHeightConstraint?.constant = rowHeight * count
    }
    
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(lessThanOrEqualTo: addButton.topAnchor, constant: -16),

            tableView.topAnchor.constraint(equalTo: containerView.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            tableView.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor),

            addButton.topAnchor.constraint(greaterThanOrEqualTo: containerView.bottomAnchor, constant: 16),
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addButton.heightAnchor.constraint(equalToConstant: 60),
            
            emptyImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            emptyLabel.topAnchor.constraint(equalTo: emptyImageView.bottomAnchor, constant: 10),
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 32),
            emptyLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -32)
        ])
        
        tableHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: 0)
        tableHeightConstraint?.isActive = true
                
    }
    
    // MARK: - Binding
    
    private func bindViewModel() {
        viewModel.onCategoriesChanged = { [weak self] in
            self?.tableView.reloadData()
            self?.updateTableHeight()
            self?.updateEmptyState()
            }
        
        viewModel.onCategorySelected = { [weak self] category in
            self?.onCategorySelected?(category)
            self?.dismiss(animated: true)
        }
        
        viewModel.onAddCategoryRequested = { [weak self] in
            let vc = NewCategoryViewController()

            vc.onCreate = { [weak self] title in
                self?.viewModel.addCategory(title: title)
            }

            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .pageSheet
            
            
            if let sheet = nav.sheetPresentationController {
                nav.modalPresentationStyle = .fullScreen
                sheet.prefersGrabberVisible = false
            }
            
            self?.present(nav, animated: true)
        }
        
        viewModel.onEditCategory = { [weak self] category in
            let vc = NewCategoryViewController()
            
            vc.configure(with: category)
            
            vc.onCreate = { [weak self] newTitle in
                self?.viewModel.updateCategory(category, title: newTitle)
            }
            
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .pageSheet
            self?.present(nav, animated: true)
        }
        
        viewModel.onDeleteCategory = { [weak self] category in
            self?.confirmDelete(category: category)
        }
        
    }
    
    // MARK: - Actions
    
    @objc private func addButtonTapped() {
        viewModel.didTapAddCategory()
    }
    
    private func confirmDelete(category: TrackerCategoryCoreData) {
        let alert = UIAlertController(
            title: NSLocalizedString("categories.delete.confirm", comment: ""),
            message: nil,
            preferredStyle: .actionSheet
        )
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("common.delete", comment: ""), style: .destructive) { [weak self] _ in
            self?.viewModel.deleteCategory(category)
        })
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("common.cancel", comment: ""), style: .cancel))
        
        present(alert, animated: true)
    }

    // MARK: - State
    
    private func updateEmptyState() {
        let isEmpty = viewModel.numberOfCategories == 0
        
        emptyImageView.isHidden = !isEmpty
        emptyLabel.isHidden = !isEmpty
        tableView.isHidden = isEmpty
        containerView.isHidden = isEmpty
    }
    
}

// MARK: - UITableView DataSource

extension CategoriesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfCategories
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CategoryCell.reuseIdentifier,
            for: indexPath
        ) as? CategoryCell else {
            return UITableViewCell()
        }
        
        let category = viewModel.category(at: indexPath)
        let isLast = indexPath.row == viewModel.numberOfCategories - 1
        let isSelected = viewModel.isSelected(at: indexPath)

        cell.configure(
            title: category.title ?? "",
            isSelected: isSelected,
            isLast: isLast
        )
        return cell
    }
}

// MARK: - UITableView Delegate

extension CategoriesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectCategory(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView,
                   contextMenuConfigurationForRowAt indexPath: IndexPath,
                   point: CGPoint) -> UIContextMenuConfiguration? {
        
        let category = viewModel.category(at: indexPath)
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            
            let edit = UIAction(title: NSLocalizedString("common.edit", comment: "")) { _ in
                self?.viewModel.didTapEdit(at: indexPath)
            }
            
            let delete = UIAction(title: NSLocalizedString("common.delete", comment: ""), attributes: .destructive) { _ in
                self?.viewModel.didTapDelete(at: indexPath)
            }
            
            return UIMenu(title: "", children: [edit, delete])
        }
    }
}
