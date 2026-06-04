import UIKit

final class FiltersViewController: UIViewController {

    // MARK: - Public

    var selectedFilter: TrackerFilter = .all
    var onSelect: ((TrackerFilter) -> Void)?

    // MARK: - UI

    private let containerView = UIView()
    private let tableView = UITableView()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupTableView()
        setupConstraints()
    }

    // MARK: - Setup

    private func setupView() {
        view.backgroundColor = .systemBackground

        title = NSLocalizedString("filters.title", comment: "")

        containerView.backgroundColor = UIColor(resource: .backgroundDay)
        containerView.layer.cornerRadius = 16
        containerView.clipsToBounds = true
        containerView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(containerView)
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false

        tableView.dataSource = self
        tableView.delegate = self

        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.rowHeight = 75
        tableView.isScrollEnabled = false
        tableView.showsVerticalScrollIndicator = false

        containerView.addSubview(tableView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([

            containerView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 24
            ),

            containerView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 16
            ),

            containerView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -16
            ),

            containerView.heightAnchor.constraint(equalToConstant: 300),

            tableView.topAnchor.constraint(equalTo: containerView.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }
}

// MARK: - UITableViewDataSource

extension FiltersViewController: UITableViewDataSource {

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {

        TrackerFilter.allCases.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let cell = UITableViewCell(
            style: .default,
            reuseIdentifier: nil
        )

        let filter = TrackerFilter.allCases[indexPath.row]

        cell.backgroundColor = .clear
        cell.selectionStyle = .none

        cell.textLabel?.text = filter.title
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        cell.textLabel?.textColor = UIColor(resource: .blackDay)
        
        cell.tintColor = .systemBlue
        
        if (filter == .completed || filter == .uncompleted)
            && filter == selectedFilter {

            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        
        if indexPath.row != TrackerFilter.allCases.count - 1 {

            let divider = UIView()
            divider.backgroundColor = .separator
            divider.translatesAutoresizingMaskIntoConstraints = false

            cell.contentView.addSubview(divider)

            NSLayoutConstraint.activate([
                divider.leadingAnchor.constraint(
                    equalTo: cell.contentView.leadingAnchor,
                    constant: 16
                ),

                divider.trailingAnchor.constraint(
                    equalTo: cell.contentView.trailingAnchor,
                    constant: -16
                ),

                divider.bottomAnchor.constraint(
                    equalTo: cell.contentView.bottomAnchor
                ),

                divider.heightAnchor.constraint(
                    equalToConstant: 1 / UIScreen.main.scale
                )
            ])
        }

        return cell
    }
}

// MARK: - UITableViewDelegate

extension FiltersViewController: UITableViewDelegate {

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {

        let filter = TrackerFilter.allCases[indexPath.row]

        selectedFilter = filter

        onSelect?(filter)

        dismiss(animated: true)
    }
}
