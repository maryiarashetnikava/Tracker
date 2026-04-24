import UIKit

final class TrackersViewController: UIViewController {
    
    // MARK: - Data
    
    var completedTrackers: Set<TrackerRecord> = []
    var currentDate: Date = Date()
    
    private let trackerStore: TrackerStore
    
    var visibleTrackers: [TrackerCoreData] {
        guard let selectedDay = weekDay(from: currentDate) else {
            return []
        }
        
        return trackerStore.trackers.filter { trackerCD in
            
            guard let data = trackerCD.schedule as? Data,
                  let schedule = try? JSONDecoder().decode([Weekday].self, from: data)
            else {
                return false
            }
            
            return schedule.contains(selectedDay)
        }
    }

    
    // MARK: - UI
    
    private let emptyImageView = UIImageView()
    private let emptyLabel = UILabel()
    
    private let searchBar = UISearchBar()
    private let datePicker = UIDatePicker()
    
    private var collectionView: UICollectionView!
    
    
    // MARK: - Init

    init(trackerStore: TrackerStore) {
        self.trackerStore = trackerStore
        super.init(nibName: nil, bundle: nil)
        
        trackerStore.delegate = self
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupNavigationBar()
        setupSearchBar()
        setupCollectionView()
        setupEmptyState()
        setupTabBarAppearance()
        setupDatePicker()
        
        updateEmptyState()

    }
}

// MARK: - Setup UI

extension TrackersViewController {
    
    func setupView() {
        view.backgroundColor = .systemBackground
        title = "Трекеры"
    }
    
    func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.tintColor = .label
        
        navigationController?.navigationBar.directionalLayoutMargins = NSDirectionalEdgeInsets(
            top: 0,
            leading: 16,
            bottom: 0,
            trailing: 16
        )
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonTapped)
        )
    }
    
    func setupSearchBar() {
        searchBar.placeholder = "Поиск"
        searchBar.backgroundImage = UIImage()
        searchBar.searchBarStyle = .minimal
        searchBar.layoutMargins = .zero
        
        let textField = searchBar.searchTextField
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.heightAnchor.constraint(equalToConstant: 36).isActive = true
        
        view.addSubview(searchBar)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            textField.leadingAnchor.constraint(equalTo: searchBar.leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: searchBar.trailingAnchor)
        ])
    }
    
    func setupCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.reuseIdentifier)
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func setupEmptyState() {
        emptyImageView.image = UIImage(named: "Dizzy")
        emptyImageView.contentMode = .scaleAspectFit
        
        emptyLabel.text = "Что будем отслеживать?"
        emptyLabel.font = UIFont.systemFont(ofSize: 12)
        emptyLabel.textColor = .label
        emptyLabel.textAlignment = .center
        
        view.addSubview(emptyImageView)
        view.addSubview(emptyLabel)
        
        emptyImageView.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            emptyImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyImageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: 20),
            
            emptyLabel.topAnchor.constraint(equalTo: emptyImageView.bottomAnchor, constant: 8),
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        emptyImageView.isHidden = true
        emptyLabel.isHidden = true
    }
    
    func setupDatePicker() {
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
    }
    
    func setupTabBarAppearance() {
        guard let tabBar = tabBarController?.tabBar else { return }
        
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        appearance.backgroundColor = .systemBackground
        appearance.shadowColor = .separator
        
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }
}

// MARK: - State / UI State

extension TrackersViewController {

    
    func isTrackerCompleted(_ tracker: Tracker, on date: Date) -> Bool {
        let record = TrackerRecord(
            trackerId: tracker.id,
            date: normalizedDate(date)
        )
        return completedTrackers.contains(record)
    }
    
    func isFutureDate(_ date: Date) -> Bool {
        return Calendar.current.compare(date, to: Date(), toGranularity: .day) == .orderedDescending
    }
    
    func updateEmptyState() {
        let isEmpty = visibleTrackers.isEmpty
        
        emptyImageView.isHidden = !isEmpty
        emptyLabel.isHidden = !isEmpty
        collectionView.isHidden = isEmpty
    }
}

// MARK: - Actions

extension TrackersViewController {
    
    @objc func addButtonTapped() {
        let vc = NewHabitViewController()
        
        vc.onCreate = { [weak self] tracker in
            guard let self else { return }
            
            self.trackerStore.add(tracker)
        }
        
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .pageSheet
        
        present(nav, animated: true)
    }
    
    @objc private func dateChanged() {
        currentDate = datePicker.date
        collectionView.reloadData()
        updateEmptyState()
    }
}

// MARK: - Data Manipulation

extension TrackersViewController {
    func completeTracker(_ tracker: Tracker, on date: Date) {
        let record = TrackerRecord(
            trackerId: tracker.id,
            date: normalizedDate(date)
        )
        completedTrackers.insert(record)
    }
    
    func uncompleteTracker(_ tracker: Tracker, on date: Date) {
        let record = TrackerRecord(
            trackerId: tracker.id,
            date: normalizedDate(date)
        )
        completedTrackers.remove(record)
    }
}

// MARK: - CollectionView DataSource

extension TrackersViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleTrackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCell.reuseIdentifier,
            for: indexPath
        ) as? TrackerCell else {
            return UICollectionViewCell()
        }
        
        let trackerCD = visibleTrackers[indexPath.item]
        let tracker = makeTracker(from: trackerCD)
        
        let count = completedTrackers.filter {
            $0.trackerId == tracker.id
        }.count

        let isCompleted = isTrackerCompleted(tracker, on: currentDate)
        let isFuture = isFutureDate(currentDate)

        cell.configure(
            with: tracker,
            isCompleted: isCompleted,
            count: count,
            isFuture: isFuture
        )

        cell.delegate = self
        
        return cell
    }
}

// MARK: - CollectionView Layout

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    
    func createLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 8
        return layout
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let insets: CGFloat = 16 * 2
        let spacing: CGFloat = 8
        
        let width = (collectionView.bounds.width - insets - spacing) / 2
        
        return CGSize(width: width, height: 130)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        
        UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
}
// MARK: - TrackerCell Delegate

extension TrackersViewController: TrackerCellDelegate {
    
    func didTapPlusButton(in cell: TrackerCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return
        }
        
        let trackerCD = visibleTrackers[indexPath.item]
        let tracker = makeTracker(from: trackerCD)
        
        let date = datePicker.date
        
        if isFutureDate(date) {
                return
            }
        
        let isCompleted = isTrackerCompleted(tracker, on: date)
        
        if isCompleted {
            uncompleteTracker(tracker, on: date)
        } else {
            completeTracker(tracker, on: date)
        }
        
        collectionView.reloadItems(at: [indexPath])
    }
}
// MARK: - TrackerStore Delegate

extension TrackersViewController: TrackerStoreDelegate {

    func didUpdate() {
        collectionView.reloadData()
        updateEmptyState()
    }
    
}

// MARK: - Helpers

extension TrackersViewController {
    
    func weekday(from date: Date) -> Int {
        return Calendar.current.component(.weekday, from: date)
    }
    
    func weekDay(from date: Date) -> Weekday? {
        let value = Calendar.current.component(.weekday, from: date)
        return Weekday(rawValue: value)
    }
    
    func normalizedDate(_ date: Date) -> Date {
        Calendar.current.startOfDay(for: date)
    }
    
    func makeTracker(from trackerCD: TrackerCoreData) -> Tracker {
        
        let schedule: [Weekday]

        if let data = trackerCD.schedule as? Data,
           let decoded = try? JSONDecoder().decode([Weekday].self, from: data) {
            schedule = decoded
        } else {
            schedule = []
        }

        return Tracker(
            id: trackerCD.id ?? UUID(),
            name: trackerCD.name ?? "",
            color: trackerCD.color as? UIColor ?? .black,
            emoji: trackerCD.emoji ?? "",
            schedule: schedule
        )
    }
}

