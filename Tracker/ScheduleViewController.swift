import UIKit

final class ScheduleViewController: UIViewController {
    
    // MARK: - Public Properties
    
    var selectedDays: Set<Weekday> = []
    var onSave: ((Set<Weekday>) -> Void)?
    
    // MARK: - UI
    
    private let tableView = UITableView()
    private let containerView = UIView()
    private let doneButton = UIButton(type: .system)
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupTableView()
        setupButton()
        setupConstraints()
    }
    
    // MARK: - Setup UI
    
    private func setupView() {
        view.backgroundColor = .systemBackground
        title = "Расписание"
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.isScrollEnabled = false
        tableView.bounces = false
        
        containerView.backgroundColor = UIColor(named: "Background [day]")
        containerView.layer.cornerRadius = 16
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(containerView)
        containerView.addSubview(tableView)
    }
    
    private func setupButton() {
        doneButton.setTitle("Готово", for: .normal)
        doneButton.backgroundColor = .black
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.layer.cornerRadius = 16
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(doneButton)
        
        doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: containerView.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            tableView.heightAnchor.constraint(equalToConstant: CGFloat(Weekday.orderedCases.count) * 70),
            
            doneButton.topAnchor.constraint(greaterThanOrEqualTo: containerView.bottomAnchor, constant: 16),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 60),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func doneTapped() {
        onSave?(selectedDays)
        dismiss(animated: true)
    }
    
    @objc private func switchChanged(_ sender: UISwitch) {
        let day = Weekday.orderedCases[sender.tag]
        
        if sender.isOn {
            selectedDays.insert(day)
        } else {
            selectedDays.remove(day)
        }
    }
}

// MARK: - UITableViewDataSource

extension ScheduleViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Weekday.orderedCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)

        cell.backgroundColor = .clear
        cell.selectionStyle = .none

        let day = Weekday.orderedCases[indexPath.row]
        cell.textLabel?.text = day.title
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17)

        let switchView = UISwitch()
        switchView.onTintColor = .systemBlue
        switchView.isOn = selectedDays.contains(day)
        switchView.tag = indexPath.row
        switchView.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)

        cell.accessoryView = switchView

        if indexPath.row != Weekday.orderedCases.count - 1 {
            let divider = UIView()
            divider.backgroundColor = .separator
            divider.translatesAutoresizingMaskIntoConstraints = false
            
            cell.contentView.addSubview(divider)
            
            NSLayoutConstraint.activate([
                divider.leadingAnchor.constraint(equalTo: cell.layoutMarginsGuide.leadingAnchor),
                divider.trailingAnchor.constraint(equalTo: cell.layoutMarginsGuide.trailingAnchor),
                divider.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
                divider.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale)
            ])
        }

        return cell
    }
}

// MARK: - UITableViewDelegate

extension ScheduleViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        70
    }
}
