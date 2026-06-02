import UIKit

final class TrackersViewController: UIViewController {
    
    // MARK: - Data

    var currentDate: Date = Date()
    private var searchText = ""
    
    private var selectedFilter: TrackerFilter = .all
    
    private let trackerStore: TrackerStore
    private let recordStore: TrackerRecordStore
    
    var visibleTrackers: [TrackerCoreData] {
        guard let selectedDay = weekDay(from: currentDate) else {
            return []
        }

        return trackerStore.trackers.filter { trackerCD in

            let schedule = trackerCD.schedule as? [Weekday] ?? []
            let matchesDay = schedule.contains(selectedDay)

            let name = trackerCD.name ?? ""
            let matchesSearch =
                searchText.isEmpty ||
                name.lowercased().contains(searchText.lowercased())
            
            let tracker = makeTracker(from: trackerCD)

            let matchesFilter: Bool

            switch selectedFilter {

            case .all:
                matchesFilter = true

            case .today:
                matchesFilter = true

            case .completed:
                matchesFilter = isTrackerCompleted(
                    tracker,
                    on: currentDate
                )

            case .uncompleted:
                matchesFilter = !isTrackerCompleted(
                    tracker,
                    on: currentDate
                )
            }

            return matchesDay && matchesSearch && matchesFilter
        }
    }
    
    var visibleSections: [TrackerSection] {

        let grouped = Dictionary(grouping: visibleTrackers) { tracker in
            tracker.category?.title ?? ""
        }

        return grouped
            .map {
                TrackerSection(
                    title: $0.key,
                    trackers: $0.value
                )
            }
            .sorted {
                $0.title < $1.title
            }
    }

    
    // MARK: - UI
    
    private let emptyImageView = UIImageView()
    private let emptyLabel = UILabel()
    
    private let searchBar = UISearchBar()
    private let datePicker = UIDatePicker()
    
    private let filterButton = UIButton(type: .system)
    
    private var collectionView: UICollectionView!
    
    
    // MARK: - Init

    init(trackerStore: TrackerStore, recordStore: TrackerRecordStore) {
        self.trackerStore = trackerStore
        self.recordStore = recordStore
        super.init(nibName: nil, bundle: nil)
        
        trackerStore.delegate = self
        recordStore.delegate = self
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
        setupFilterButton()
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
        title = NSLocalizedString("trackers.title", comment: "")
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
        searchBar.placeholder = NSLocalizedString("search.placeholder", comment: "")
        searchBar.backgroundImage = UIImage()
        searchBar.searchBarStyle = .minimal
        searchBar.layoutMargins = .zero
        
        searchBar.delegate = self
        
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
        
        collectionView.contentInset.bottom = 100
        
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.reuseIdentifier)
        
        collectionView.register(
            TrackerSectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TrackerSectionHeaderView.reuseIdentifier
        )
        
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
        
        emptyLabel.text = NSLocalizedString("trackers.empty", comment: "")
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
    
    func setupFilterButton() {
        
        filterButton.setTitle(
            NSLocalizedString("filters.title", comment: ""),
            for: .normal
        )

        filterButton.setTitleColor(.white, for: .normal)
        filterButton.backgroundColor = .systemBlue

        filterButton.layer.cornerRadius = 16

        filterButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(filterButton)
        
        filterButton.addTarget(
            self,
            action: #selector(filterButtonTapped),
            for: .touchUpInside
        )
        
        NSLayoutConstraint.activate([

            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            filterButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -16
            ),

            filterButton.widthAnchor.constraint(equalToConstant: 114),
            filterButton.heightAnchor.constraint(equalToConstant: 50)
        ])
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
        return recordStore.isTrackerCompleted(
            trackerId: tracker.id,
            date: normalizedDate(date)
        )
    }
    
    func isFutureDate(_ date: Date) -> Bool {
        return Calendar.current.compare(date, to: Date(), toGranularity: .day) == .orderedDescending
    }
    
    func updateEmptyState() {

        let hasAnyTrackers = !trackerStore.trackers.isEmpty
        let hasVisibleTrackers = !visibleTrackers.isEmpty
        
        filterButton.isHidden =
            visibleTrackers.isEmpty &&
            searchText.isEmpty &&
            selectedFilter == .all

        if hasVisibleTrackers {

            emptyImageView.isHidden = true
            emptyLabel.isHidden = true
            collectionView.isHidden = false

            return
        }

        collectionView.isHidden = true
        emptyImageView.isHidden = false
        emptyLabel.isHidden = false

        if hasAnyTrackers {

            emptyImageView.image = UIImage(resource: .nothing)
            emptyLabel.text = NSLocalizedString(
                "filters.empty",
                comment: ""
            )

        } else {

            emptyImageView.image = UIImage(resource: .dizzy)
            emptyLabel.text = NSLocalizedString(
                "trackers.empty",
                comment: ""
            )
        }
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
    
    @objc private func filterButtonTapped() {

        let vc = FiltersViewController()

        vc.selectedFilter = selectedFilter

        vc.onSelect = { [weak self] filter in
            guard let self else { return }

            self.selectedFilter = filter

            switch filter {

            case .today:
                self.currentDate = Date()
                self.datePicker.date = Date()

            case .all,
                 .completed,
                 .uncompleted:
                break
            }

            self.collectionView.reloadData()
            self.updateEmptyState()
        }

        let nav = UINavigationController(
            rootViewController: vc
        )

        present(nav, animated: true)
    }
    
    private func showDeleteAlert(for trackerCD: TrackerCoreData) {
        
        let alert = UIAlertController(
            title: nil,
            message: NSLocalizedString("tracker.delete.confirmation", comment: ""),
            preferredStyle: .actionSheet
        )

        let deleteAction = UIAlertAction(
            title: NSLocalizedString("tracker.delete", comment: ""),
            style: .destructive
        ) { [weak self] _ in
            
            guard let self else { return }

            self.trackerStore.delete(trackerCD)
        }

        let cancelAction = UIAlertAction(
            title: NSLocalizedString("common.cancel", comment: ""),
            style: .cancel
        )

        alert.addAction(deleteAction)
        alert.addAction(cancelAction)

        present(alert, animated: true)
    }
}


// MARK: - CollectionView DataSource

extension TrackersViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return visibleSections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleSections[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCell.reuseIdentifier,
            for: indexPath
        ) as? TrackerCell else {
            return UICollectionViewCell()
        }
        
        let trackerCD = visibleSections[indexPath.section]
            .trackers[indexPath.item]
        let tracker = makeTracker(from: trackerCD)
        
        let count = recordStore.fetchRecords().filter {
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
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {

        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }

        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: TrackerSectionHeaderView.reuseIdentifier,
            for: indexPath
        ) as? TrackerSectionHeaderView else {
            return UICollectionReusableView()
        }

        header.titleLabel.text = visibleSections[indexPath.section].title

        return header
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
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {

        return CGSize(
            width: collectionView.bounds.width,
            height: 40
        )
    }
}

// MARK: - CollectionView Delegate

extension TrackersViewController: UICollectionViewDelegate {
    
    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {

        let editAction = UIAction(
            title: NSLocalizedString("tracker.edit", comment: "")
        ) { [weak self] _ in

            guard let self else { return }

            let trackerCD = self.visibleSections[indexPath.section]
                .trackers[indexPath.item]
            let tracker = self.makeTracker(from: trackerCD)
            
            let count = recordStore.fetchRecords().filter {
                $0.trackerId == tracker.id
            }.count

            let vc = NewHabitViewController()
            
            vc.completedDaysCount = count
            vc.configure(with: tracker)
            
            vc.onUpdate = { [weak self] updatedTracker in
                self?.trackerStore.update(updatedTracker)
            }

            let nav = UINavigationController(rootViewController: vc)

            self.present(nav, animated: true)
        }
        
        let deleteAction = UIAction(
            title: NSLocalizedString("tracker.delete", comment: ""),
            attributes: .destructive
        ) { [weak self] _ in

            guard let self else { return }

            let trackerCD = self.visibleSections[indexPath.section]
                .trackers[indexPath.item]

            self.showDeleteAlert(for: trackerCD)
        }

        return UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: nil
        ) { _ in
            UIMenu(children: [
                editAction,
                deleteAction
            ])
        }
    }
}
// MARK: - TrackerCell Delegate

extension TrackersViewController: TrackerCellDelegate {
    
    func didTapPlusButton(in cell: TrackerCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return
        }
        
        let trackerCD = visibleSections[indexPath.section]
            .trackers[indexPath.item]
        let tracker = makeTracker(from: trackerCD)
        
        let date = datePicker.date
        
        if isFutureDate(date) {
                return
            }
        
        let isCompleted = isTrackerCompleted(tracker, on: date)
        
        if isCompleted {
            recordStore.deleteRecord(trackerId: tracker.id, date: normalizedDate(date))
        } else {
            recordStore.addRecord(trackerId: tracker.id, date: normalizedDate(date))
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

// MARK: - TrackerRecordStore Delegate

extension TrackersViewController: TrackerRecordStoreDelegate {
    func didUpdateRecords() {
        collectionView.reloadData()
    }
}
// MARK: - UISearchBar Delegate

extension TrackersViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar,
                   textDidChange searchText: String) {

        self.searchText = searchText

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
        
        let schedule = trackerCD.schedule as? [Weekday] ?? []

        return Tracker(
            id: trackerCD.id ?? UUID(),
            name: trackerCD.name ?? "",
            color: trackerCD.color as? UIColor ?? .black,
            emoji: trackerCD.emoji ?? "",
            schedule: schedule,
            category: trackerCD.category
        )
    }
}

